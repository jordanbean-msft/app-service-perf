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

namespace AppServicePerf.Pages.Images
{
    public class CreateModel : PageModel
    {
        private readonly AppServicePerf.Data.AppServicePerfContext _context;
        private readonly BlobServiceClient _blobServiceClient;
        public string FileName { get; set; }

        public CreateModel(AppServicePerf.Data.AppServicePerfContext context, BlobServiceClient blobServiceClient)
        {
            _context = context;
            _blobServiceClient = blobServiceClient;
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
            var result = await client.UploadBlobAsync(FileName, file.OpenReadStream());

            Image.Uri = new Uri(client.Uri, FileName); 

            _context.Images.Add(Image);
            await _context.SaveChangesAsync();

            return RedirectToPage("./Index");
        }
    }
}
