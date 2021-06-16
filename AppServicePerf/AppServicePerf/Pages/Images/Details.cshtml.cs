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
using Azure.Storage.Blobs.Models;
using Microsoft.AspNetCore.Http;
using System.IO;

namespace AppServicePerf.Pages.Images {
    public class DetailsModel : PageModel {
        private readonly AppServicePerf.Data.AppServicePerfContext _context;
        private readonly BlobServiceClient _blobServiceClient;

        public DetailsModel(AppServicePerf.Data.AppServicePerfContext context, BlobServiceClient blobServiceClient) {
            _context = context;
            _blobServiceClient = blobServiceClient;
        }

        public Image Image { get; set; }

        public async Task<IActionResult> OnGetAsync(int? id) {
            if (id == null) {
                return NotFound();
            }

            Image = await _context.Images.FirstOrDefaultAsync(m => m.ID == id);

            if (Image == null) {
                return NotFound();
            }
            else {
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
            }
            return Page();
        }
    }
}
