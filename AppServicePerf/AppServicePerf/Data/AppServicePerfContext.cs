using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using AppServicePerf.Models;

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
