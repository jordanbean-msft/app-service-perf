using Azure.Core;
using Azure.Identity;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore.Diagnostics;
using System.Collections.Generic;
using System.Data.Common;
using System.Threading;
using System.Threading.Tasks;

namespace AppServicePerf.Data {
    public class AzureAdAuthenticationDbConnectionInterceptor : DbConnectionInterceptor {
        private static readonly string[] _azureSqlScopes = new[] {
            "https://database.windows.net//.default"
        };

        private static readonly TokenCredential _credential = new ChainedTokenCredential(
            new ManagedIdentityCredential());

        public override InterceptionResult ConnectionOpening(DbConnection connection, ConnectionEventData eventData, InterceptionResult result) {
            var sqlConnection = (SqlConnection)connection;
            if(DoesConnectionNeedAccessToken(sqlConnection)) {
                var tokenRequestContext = new TokenRequestContext(_azureSqlScopes);
                var token = _credential.GetToken(tokenRequestContext, default);

                sqlConnection.AccessToken = token.Token;
            }
            
            return base.ConnectionOpening(connection, eventData, result);
        }

        public override async ValueTask<InterceptionResult> ConnectionOpeningAsync(DbConnection connection, ConnectionEventData eventData, InterceptionResult result, CancellationToken cancellationToken = default) {
            var sqlConnection = (SqlConnection)connection;
            if (DoesConnectionNeedAccessToken(sqlConnection)) {
                var tokenRequestContext = new TokenRequestContext(_azureSqlScopes);
                var token = await _credential.GetTokenAsync(tokenRequestContext, cancellationToken);

                sqlConnection.AccessToken = token.Token;
            }

            return await base.ConnectionOpeningAsync(connection, eventData, result, cancellationToken);
        }
        private static bool DoesConnectionNeedAccessToken(SqlConnection connection) {
            var connectionStringBuilder = new SqlConnectionStringBuilder(connection.ConnectionString);
            return connectionStringBuilder.DataSource.Contains("database.windows.net", System.StringComparison.OrdinalIgnoreCase) && string.IsNullOrEmpty(connectionStringBuilder.UserID);
        }
    }
}