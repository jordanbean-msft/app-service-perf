using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using AppServicePerf.Data;
using AppServicePerf.Models;
using Azure.Storage.Blobs;
using System.IO;
using System.Web;
using Microsoft.Extensions.Caching.Distributed;

namespace AppServicePerf.Pages.Images {
    public class DeleteModel : PageModel {
        private readonly AppServicePerfContext _context;
        private readonly BlobServiceClient _blobServiceClient;
        private readonly IDistributedCache _distributedCache;

        public DeleteModel(AppServicePerfContext context, BlobServiceClient blobServiceClient, IDistributedCache distributedCache) {
            _context = context;
            _blobServiceClient = blobServiceClient;
            _distributedCache = distributedCache;
        }

        [BindProperty]
        public Image Image { get; set; }

        public async Task<IActionResult> OnGetAsync(int? id) {
            if (id == null) {
                return NotFound();
            }

            Image = await _context.Images.FirstOrDefaultAsync(m => m.ID == id);

            if (Image == null) {
                return NotFound();
            }
            return Page();
        }

        public async Task<IActionResult> OnPostAsync(int? id) {
            if (id == null) {
                return NotFound();
            }

            Image = await _context.Images.FindAsync(id);

            if (Image != null) {
                var client = _blobServiceClient.GetBlobContainerClient("images");

                try {
                    var result = await client.DeleteBlobIfExistsAsync(Image.FileName);
                }
                catch (Exception ex) {
                    Exception newException = new($"Unable to delete file {Image.FileName} from blob storage.", ex);
                    throw newException;
                }

                _context.Images.Remove(Image);

                try {
                    await _context.SaveChangesAsync();
                }
                catch (Exception ex) {
                    Exception newException = new($"Unable to save new file {Image.FileName} to database.", ex);
                    throw newException;
                }
                try {
                    await _distributedCache.RemoveAsync("images");
                }
                catch (Exception ex) {
                    Exception newException = new($"Unable to update cache for {Image.FileName}.", ex);
                    throw newException;
                }
            }

            return RedirectToPage("./Index");
        }
    }
}
