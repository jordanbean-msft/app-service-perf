using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using AppServicePerf.Data;
using AppServicePerf.Models;
using Microsoft.Extensions.Caching.Distributed;
using System.Text.Json;
using StackExchange.Redis;

namespace AppServicePerf.Pages.Images {
    public class IndexModel : PageModel {
        private readonly AppServicePerfContext _context;
        private readonly IDistributedCache _distributedCache;

        public IndexModel(AppServicePerfContext context, IDistributedCache distributedCache) {
            _context = context;
            _distributedCache = distributedCache;
        }

        public IList<Image> Images { get; set; }

        public async Task OnGetAsync() {
            string jsonImages;

            try {
                jsonImages = _distributedCache.GetString("images");
            }
            catch (RedisConnectionException ex) {
                Exception newException = new($"Unable to connect to cache.", ex);
                throw newException;
            }

            if (jsonImages == null) {
                IList<Image> images;

                try {
                    images = await _context.Images.ToListAsync();
                }
                catch (Exception ex) {
                    Exception newException = new($"Unable to read from database.", ex);
                    throw newException;
                }

                jsonImages = JsonSerializer.Serialize<IList<Image>>(images);
                var options = new DistributedCacheEntryOptions();
                options.SetAbsoluteExpiration(DateTimeOffset.Now.AddMinutes(1));
                try {
                    _distributedCache.SetString("images", jsonImages, options);
                }
                catch (Exception ex) {
                    Exception newException = new($"Unable to update cache.", ex);
                    throw newException;
                }
            }

            JsonSerializerOptions opt = new JsonSerializerOptions() {
                PropertyNameCaseInsensitive = true
            };

            Images = JsonSerializer.Deserialize<IList<Image>>(jsonImages, opt);
        }
    }
}
