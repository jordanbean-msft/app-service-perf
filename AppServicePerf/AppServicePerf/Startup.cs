﻿using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Mvc.Authorization;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Identity.Web;
using Microsoft.Identity.Web.UI;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using AppServicePerf.Data;
using Microsoft.Extensions.Azure;
using Azure.Identity;

namespace AppServicePerf {
    public class Startup {
        public Startup(IConfiguration configuration) {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services) {
            services.AddAzureClients(builder => {
                builder.UseCredential(new DefaultAzureCredential());

                FeatureFlagStorage storageFeatureFlag = Enum.Parse<FeatureFlagStorage>(Configuration.GetValue<string>("FeatureFlagStorage"));

                switch(storageFeatureFlag) {
                    case FeatureFlagStorage.MANAGED_IDENTITY:
                        builder.AddBlobServiceClient(Configuration.GetSection("Storage"));
                        break;
                    case FeatureFlagStorage.STORAGE_ACCOUNT_KEY:
                        builder.AddBlobServiceClient(Configuration.GetConnectionString("StorageAccount"));
                        break;
                    default:
                        throw new NotImplementedException();
                }
                builder.ConfigureDefaults(Configuration.GetSection("AzureDefaults"));
            });
            services.AddAuthentication(OpenIdConnectDefaults.AuthenticationScheme)
                .AddMicrosoftIdentityWebApp(Configuration.GetSection("AzureAd"));

            services.AddAuthorization(options => {
                // By default, all incoming requests will be authorized according to the default policy
                options.FallbackPolicy = options.DefaultPolicy;
            });

            services.AddStackExchangeRedisCache(options => {
                options.Configuration = Configuration.GetConnectionString("RedisCache");
            });

            services.AddRazorPages()
                .AddMvcOptions(options => { })
                .AddMicrosoftIdentityUI();

            services.AddDbContext<AppServicePerfContext>(options => {                
                FeatureFlagSql sqlFeatureFlag = Enum.Parse<FeatureFlagSql>(Configuration.GetValue<string>("FeatureFlagSql"));
                
                switch(sqlFeatureFlag) {
                    case FeatureFlagSql.MANAGED_IDENTITY:
                        options.UseSqlServer(Configuration.GetConnectionString("AppServicePerfManagedIdentityContext"));
                        options.AddInterceptors(new AzureAdAuthenticationDbConnectionInterceptor());
                        break;
                    case FeatureFlagSql.SQL_AUTHENTICATION:
                        options.UseSqlServer(Configuration.GetConnectionString("AppServicePerfSqlPasswordContext"));
                        break;
                    default:
                        throw new NotImplementedException();
                }
                }
            );

            services.AddDatabaseDeveloperPageExceptionFilter();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env) {
            if (env.IsDevelopment()) {
                app.UseDeveloperExceptionPage();
            }
            else {
                app.UseExceptionHandler("/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }

            app.UseHttpsRedirection();
            app.UseStaticFiles();

            app.UseRouting();

            app.UseAuthentication();
            app.UseAuthorization();

            app.UseEndpoints(endpoints => {
                endpoints.MapRazorPages();
                endpoints.MapControllers();
            });
        }

        private enum FeatureFlagStorage { MANAGED_IDENTITY, STORAGE_ACCOUNT_KEY }
        private enum FeatureFlagSql { MANAGED_IDENTITY, SQL_AUTHENTICATION }
    }
} 