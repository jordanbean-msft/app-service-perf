using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using AppServicePerf.Data;
using AppServicePerf.Models;

namespace AppServicePerf.Pages.Images
{
    public class IndexModel : PageModel
    {
        private readonly AppServicePerf.Data.AppServicePerfContext _context;

        public IndexModel(AppServicePerf.Data.AppServicePerfContext context)
        {
            _context = context;
        }

        public IList<Image> Image { get;set; }

        public async Task OnGetAsync()
        {
            Image = await _context.Images.ToListAsync();
        }
    }
}
