using RoseFashionBE.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Cors;

namespace RoseFashionBE.Controllers
{
    [EnableCors(origins: "*", headers: "*", methods: "*")]
    public class CartController : ApiController
    {
        public IHttpActionResult GetLastUsedCart(string userid)
        {
            try
            {
                using(var entity = new RoseFashionDBEntities())
                {
                    var result = entity.Carts.Where(c => c.UserID == userid && c.IsUsing == true).FirstOrDefault();
                    if(result == null)
                    {

                    }
                    else
                    {

                    }
                    return Ok(result);
                }
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        public IHttpActionResult AddProductsToCart(CartModel[] products)
        {
            try
            {

                return Ok();
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        public IHttpActionResult GetCartDetail(CartModel[] items)
        {
            try
            {
                using(var entity = new RoseFashionDBEntities())
                {
                    List<ProductModel> result = new List<ProductModel>();
                    for(int i = 0; i < items.Count(); i++)
                    {
                        ProductModel oneproduct = entity.Products.Where(p => p.ProductID == items[i].ProductID)
                            .Select(p => new ProductModel
                            {
                                ProductID = p.ProductID,
                                Name = p.Name,
                                Image = p.Image,
                                Price = p.Price
                            }).FirstOrDefault();
                        result.Add(oneproduct);
                    }
                    return Ok(result);
                }
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }
    }
}
