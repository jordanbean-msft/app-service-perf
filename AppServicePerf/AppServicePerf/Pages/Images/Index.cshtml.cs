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

namespace AppServicePerf.Pages.Images
{
    public class IndexModel : PageModel
    {
        private readonly AppServicePerf.Data.AppServicePerfContext _context;
        private readonly IDistributedCache _distributedCache;

        public IndexModel(AppServicePerfContext context, IDistributedCache distributedCache)
        {
            _context = context;
            _distributedCache = distributedCache;
        }

        public IList<Image> Images { get;set; }

        public async Task OnGetAsync()
        {
            string jsonImages = _distributedCache.GetString("images");

            if(jsonImages == null) {
                IList<Image> images = await _context.Images.ToListAsync();
                jsonImages = JsonSerializer.Serialize<IList<Image>>(images);
                var options = new DistributedCacheEntryOptions();
                options.SetAbsoluteExpiration(DateTimeOffset.Now.AddMinutes(1));
                _distributedCache.SetString("images", jsonImages, options);
            }

            JsonSerializerOptions opt = new JsonSerializerOptions() {
                PropertyNameCaseInsensitive = true
            };

            Images = JsonSerializer.Deserialize<IList<Image>>(jsonImages, opt);
        }
    }
}
