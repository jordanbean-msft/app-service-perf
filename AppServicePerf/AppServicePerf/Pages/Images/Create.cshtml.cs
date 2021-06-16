using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Rendering;
using AppServicePerf.Data;
using AppServicePerf.Models;
using Microsoft.AspNetCore.Http;
using Azure.Storage.Blobs;
using System.IO;
using System.Web;
using Microsoft.Extensions.Caching.Distributed;

namespace AppServicePerf.Pages.Images
{
    public class CreateModel : PageModel
    {
        private readonly AppServicePerf.Data.AppServicePerfContext _context;
        private readonly BlobServiceClient _blobServiceClient;
        private readonly IDistributedCache _distributedCache;
        public string FileName { get; set; }

        public CreateModel(AppServicePerfContext context, BlobServiceClient blobServiceClient, IDistributedCache distributedCache)
        {
            _context = context;
            _blobServiceClient = blobServiceClient;
            _distributedCache = distributedCache;
            FileName = "Not Available";
        }

        public IActionResult OnGet()
        {
            return Page();
        }

        [BindProperty]
        public Image Image { get; set; }

        // To protect from overposting attacks, see https://aka.ms/RazorPagesCRUD
        public async Task<IActionResult> OnPostAsync(IFormFile file)
        {
            if (!ModelState.IsValid)
            {
                return Page();
            }

            string untrustedFileName = Path.GetFileName(file.FileName);

            FileName = HttpUtility.HtmlEncode(untrustedFileName);

            var client = _blobServiceClient.GetBlobContainerClient("images");

            try {
                var result = await client.UploadBlobAsync(FileName, file.OpenReadStream());
            } 
            catch (Exception ex) {
                Exception newException = new($"Unable to upload file {file.FileName} to blob storage.", ex);
                throw newException;
            }
            string imageFileHash;

            using (var memoryStream = new MemoryStream()) {
                try {
                    await file.CopyToAsync(memoryStream);
                }
                catch (Exception ex) {
                    Exception newException = new($"Unable to compute hash on file {file.FileName}.", ex);
                    throw newException;
                }

                byte[] tempImageArray = memoryStream.ToArray();

                using (var sha1 = new System.Security.Cryptography.SHA1CryptoServiceProvider()) {
                    imageFileHash = string.Concat(sha1.ComputeHash(tempImageArray).Select(x => x.ToString("X2")));
                }
            }

            Image.Uri = new Uri(client.Uri, FileName);
            Image.FileName = FileName;
            Image.Hash = imageFileHash;

            _context.Images.Add(Image);

            try {
                await _context.SaveChangesAsync();
            }
            catch (Exception ex) {
                Exception newException = new($"Unable to save new file {file.FileName} to database.", ex);
                throw newException;
            }

            try { 
            await _distributedCache.RemoveAsync("images");
            }
            catch (Exception ex) {
                Exception newException = new($"Unable to update cache for {file.FileName}.", ex);
                throw newException;
            }

            return RedirectToPage("./Index");
        }
    }
}
