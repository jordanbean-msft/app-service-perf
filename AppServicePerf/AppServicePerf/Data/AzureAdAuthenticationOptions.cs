using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace AppServicePerf.Data {
    public class AzureAdAuthenticationOptions {
        public string TenantId { get; set; }
        public string ClientId { get; set; }
        public string ClientSecret { get; set; }
    }
}
