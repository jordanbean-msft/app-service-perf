using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace AppServicePerf.Data {
    public static class DbInitializer {
        public static void Initialize(AppServicePerfContext context) {
            if(context.Images.Any()) {
                return;
            }
        }
    }
}
