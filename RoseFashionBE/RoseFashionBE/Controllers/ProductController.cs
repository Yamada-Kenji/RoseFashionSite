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

        [HttpPost]
        public IHttpActionResult AddProduct(ProductModel newproduct)
        {
            try
            {
                using(var entity = new RoseFashionDBEntities())
                {
                    for (int i = 0; i < newproduct.Size.Count(); i++)
                    {
                        entity.Products.Add(new Product
                        {
                            ProductID = "PR-" + (entity.Products.Count() + 1),
                            Name = newproduct.Name,
                            Color = newproduct.Color,
                            Size = newproduct.Size[i],
                            CategoryID = newproduct.CategoryID,
                            Description = newproduct.Description,
                            Quantity = newproduct.Quantity,
                            Image = newproduct.Image,
                            Price = newproduct.Prices
                        });
                    }
                    entity.SaveChanges();
                    return Ok("Add new product successfully.");
                }                
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpGet]
        public IHttpActionResult GetProductDetail()
        {
            return Ok();
        }
    }
}
