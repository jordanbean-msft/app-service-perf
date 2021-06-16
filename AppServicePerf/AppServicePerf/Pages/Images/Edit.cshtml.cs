using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using AppServicePerf.Data;
using AppServicePerf.Models;
using Microsoft.Extensions.Caching.Distributed;
using Azure.Storage.Blobs;
using System.IO;
using System.Web;
using Microsoft.AspNetCore.Http;

namespace AppServicePerf.Pages.Images {
    public class EditModel : PageModel {
        private readonly AppServicePerfContext _context;
        private readonly BlobServiceClient _blobServiceClient;
        private readonly IDistributedCache _distributedCache;

        public EditModel(AppServicePerfContext context, BlobServiceClient blobServiceClient, IDistributedCache distributedCache) {
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

            var containerClient = _blobServiceClient.GetBlobContainerClient("images");
            BlobClient blobClient;
            try {
                blobClient = containerClient.GetBlobClient(Image.FileName);
            }
            catch (Exception ex) {
                Exception newException = new($"Unable to find file {Image.FileName} in blob storage.", ex);
                throw newException;
            }

            using (var memoryStream = new MemoryStream()) {
                try {
                    await blobClient.DownloadToAsync(memoryStream);
                }
                catch (Exception ex) {
                    Exception newException = new($"Unable to download file {Image.FileName} from blob storage.", ex);
                    throw newException;
                }
                Image.File = memoryStream.ToArray();
            }

            return Page();
        }

        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see https://aka.ms/RazorPagesCRUD.
        public async Task<IActionResult> OnPostAsync(IFormFile file) {
            if (!ModelState.IsValid) {
                return Page();
            }

            _context.Attach(Image).State = EntityState.Modified;

            if (file != null) {
                string tempFileHash;

                using (var sha1 = new System.Security.Cryptography.SHA1CryptoServiceProvider()) {
                    using (var memoryStream = new MemoryStream()) {
                        try {
                            await file.CopyToAsync(memoryStream);
                        }
                        catch (Exception ex) {
                            Exception newException = new($"Unable to read file {file.FileName} into memory.", ex);
                            throw newException;
                        }
                        byte[] tempImageArray = memoryStream.ToArray();

                        tempFileHash = string.Concat(sha1.ComputeHash(tempImageArray).Select(x => x.ToString("X2")));
                    }
                }

                if (Image.Hash != tempFileHash) {
                    string untrustedFileName = Path.GetFileName(file.FileName);

                    string fileName = HttpUtility.HtmlEncode(untrustedFileName);

                    var client = _blobServiceClient.GetBlobContainerClient("images");

                    try {
                        var result = await client.UploadBlobAsync(fileName, file.OpenReadStream());
                    }
                    catch (Exception ex) {
                        Exception newException = new($"Unable to upload new file {file.FileName} to blob storage.", ex);
                        throw newException;
                    }
                    Image.Uri = new Uri(client.Uri, fileName);
                    Image.FileName = fileName;
                }
            }

            try {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException ex) {
                if (!ImageExists(Image.ID)) {
                    return NotFound();
                }
                else {
                    Exception newException = new($"Unable to upload new file {file.FileName} to database.", ex);
                    throw newException;
                }
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

        private bool ImageExists(int id) {
            return _context.Images.Any(e => e.ID == id);
        }
    }
}
