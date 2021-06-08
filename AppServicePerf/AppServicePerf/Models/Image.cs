using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace AppServicePerf.Models {
    public class Image {
        public int ID { get; set; }
        public string Name { get; set; }
        public Uri Uri { get; set; }
        public string FileName { get; set; }

        public string Hash { get; set; }

        [NotMapped]
        public byte[] File { get; set; }
    }
}
