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
                            //Quantity = newproduct.Quantity,
                            Image = newproduct.Image,
                            Price = newproduct.Price
                        });
                        entity.SaveChanges();
                    }
                    return Ok("Add new product successfully.");
                }                
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpGet]
        public IHttpActionResult GetProductDetail(string pid)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    string[] a = new string[] { "a","b" };
                    ProductModel result = null;
                    result = entity.Products.Where(p => p.ProductID == pid)
                        .Select(p => new ProductModel()
                        {
                            ProductID = p.ProductID,
                            Name = p.Name,
                            Color = p.Color,
                            CategoryID = p.CategoryID,
                            Description = p.Description,
                            Price = p.Price,
                    }).FirstOrDefault();
                    if (result == null) return BadRequest("Product not found.");
                    else
                    {
                        result.Size = entity.Products.Where(p => p.Name == result.Name && p.Color == result.Color).Select(p => p.Size).ToArray();
                        result.Quantity = new int[result.Size.Count()];
                        for (int i = 0; i < result.Size.Count(); i++)
                        {
                            string size = result.Size[i];
                            result.Quantity[i] = entity.Products.Where(p => p.Name == result.Name && p.Color == result.Color && p.Size == size).Select(p => p.Quantity).FirstOrDefault();
                        }
                        return Ok(result);
                    }
                }
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }
    }
}
