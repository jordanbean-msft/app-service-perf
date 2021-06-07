using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using AppServicePerf.Models;
using Microsoft.Data.SqlClient;
using Azure.Identity;
using Azure.Core;

namespace AppServicePerf.Data
{
    public class AppServicePerfContext : DbContext
    {
        public AppServicePerfContext (DbContextOptions<AppServicePerfContext> options)
            : base(options)
        {
        }

        public DbSet<Image> Images { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder) {
            modelBuilder.Entity<Image>().ToTable("Image");
        }
    }
}
