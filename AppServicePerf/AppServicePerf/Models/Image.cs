using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace AppServicePerf.Models {
    public class Image {
        public int ID { get; set; }
        public string Name { get; set; }
        public Uri Uri { get; set; }
        public string FileName { get; set; }
    }
}
