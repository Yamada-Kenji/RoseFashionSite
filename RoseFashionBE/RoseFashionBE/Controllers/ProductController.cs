using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using RoseFashionBE.Models;
using System.Web.Http.Cors;

namespace RoseFashionBE.Controllers
{
    [EnableCors(origins: "*", headers: "*", methods: "*")]
    public class ProductController : ApiController
    {
        [HttpPost]
        public IHttpActionResult SaveImage(CategoryModel category)
        {
            using(var entity = new RoseFashionDBEntities())
            {
                entity.Categories.Add(new Category()
                {
                    CategoryID = (entity.Categories.Count() + 1).ToString(),
                    Name = category.Name
                });
                entity.SaveChanges();
                return Ok("Save image successfully.");
            }            
        }

        [HttpGet]
        public IHttpActionResult GetImage(string id)
        {
            using (var entity = new RoseFashionDBEntities())
            {
                return Ok(entity.Categories.Where(c => c.CategoryID == id).Select(c => c.Name).FirstOrDefault());
            }
        }
    }
}
