using AppServicePerf.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using Microsoft.Extensions.Configuration;
using StackExchange.Redis;

namespace AppServicePerf.Controllers {
    [Authorize]
    public class HomeController : Controller {
        private readonly ILogger<HomeController> _logger;
        private static IConfiguration Configuration { get; set; }

        public HomeController(ILogger<HomeController> logger, IConfiguration configuration) {
            _logger = logger;
            if (Configuration != null)
                Configuration = configuration;
        }

        public IActionResult Index() {
            return View();
        }

        public IActionResult Privacy() {
            return View();
        }

        [AllowAnonymous]
        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error() {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

        public ActionResult RedisCache() {
            IDatabase cache = GetDatabase();

            return View();
        }

        private const string SecretName = "CacheConnection";

        private static long lastReconnectTicks = DateTimeOffset.MinValue.UtcTicks;
        private static DateTimeOffset firstErrorTime = DateTimeOffset.MinValue;
        private static DateTimeOffset previousErrorTime = DateTimeOffset.MinValue;

        private static readonly object reconnectLock = new object();

        public static TimeSpan ReconnectMinFrequency => TimeSpan.FromSeconds(60);

        public static TimeSpan ReconnectErrorThreshold => TimeSpan.FromSeconds(30);

        public static int RetryMaxAttempts => 5;

        private static Lazy<ConnectionMultiplexer> lazyConnection = CreateConnection();

        public static ConnectionMultiplexer Connection {
            get {
                return lazyConnection.Value;
            }
        }

        private static Lazy<ConnectionMultiplexer> CreateConnection() {
            return new Lazy<ConnectionMultiplexer>(() => {
                string cacheConnection = Configuration[SecretName];
                return ConnectionMultiplexer.Connect(cacheConnection);
            });
        }

        private static void CloseConnection(Lazy<ConnectionMultiplexer> oldConnection) {
            if (oldConnection == null)
                return;

            try {
                oldConnection.Value.Close();
            }
            catch (Exception) {

            }
        }

        public static void ForceReconnect() {
            var utcNow = DateTimeOffset.UtcNow;
            long previousTicks = Interlocked.Read(ref lastReconnectTicks);
            var previousReconnectTime = new DateTimeOffset(previousTicks, TimeSpan.Zero);
            TimeSpan elapsedSinceLastReconnect = utcNow - previousReconnectTime;

            if(elapsedSinceLastReconnect < ReconnectMinFrequency) {
                return;
            }

            lock(reconnectLock) {
                utcNow = DateTimeOffset.UtcNow;
                elapsedSinceLastReconnect = utcNow - previousReconnectTime;

                if(firstErrorTime == DateTimeOffset.MinValue) {
                    firstErrorTime = utcNow;
                    previousErrorTime = utcNow;
                    return;
                }

                if (elapsedSinceLastReconnect < ReconnectMinFrequency)
                    return;

                TimeSpan elapsedSinceFirstError = utcNow - firstErrorTime;
                TimeSpan elapsedSinceMostRecentError = utcNow - previousErrorTime;

                bool shouldReconnect = elapsedSinceFirstError >= ReconnectErrorThreshold
                    && elapsedSinceMostRecentError <= ReconnectErrorThreshold;

                previousErrorTime = utcNow;

                if (!shouldReconnect)
                    return;

                firstErrorTime = DateTimeOffset.MinValue;
                previousErrorTime = DateTimeOffset.MinValue;

                Lazy<ConnectionMultiplexer> oldConnection = lazyConnection;
                CloseConnection(oldConnection);
                lazyConnection = CreateConnection();
                Interlocked.Exchange(ref lastReconnectTicks, utcNow.UtcTicks);
            }
        }

        private static T BasicRetry<T>(Func<T> func) {
            int reconnectRetry = 0;
            int disposedRetry = 0;

            while(true) {
                try {
                    return func();
                }
                catch(Exception ex) when (ex is RedisConnectionException || ex is SocketException) {
                    reconnectRetry++;
                    if (reconnectRetry > RetryMaxAttempts)
                        throw;
                    ForceReconnect();
                }
                catch(ObjectDisposedException) {
                    disposedRetry++;
                    if (disposedRetry > RetryMaxAttempts)
                        throw;
                }
            }
        }

        public static IDatabase GetDatabase() {
            return BasicRetry(() => Connection.GetDatabase());
        }

        public static System.Net.EndPoint[] GetEndPoints() {
            return BasicRetry(() => Connection.GetEndPoints());
        }

        public static IServer GetServer(string host, int port) {
            return BasicRetry(() => Connection.GetServer(host, port));
        }
    }
}
