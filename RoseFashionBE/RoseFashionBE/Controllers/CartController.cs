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
        [HttpGet]
        public IHttpActionResult GetLastUsedCartID(string userid)
        {
            try
            {
                using(var entity = new RoseFashionDBEntities())
                {

                    var oldcartid = entity.Carts.Where(c => c.UserID == userid && c.IsUsing == true).Select(c => c.CartID).FirstOrDefault();
                    if(oldcartid == null)
                    {
                        string newcartid = "CR-" + (entity.Carts.Count() + 1);
                        entity.Carts.Add(new Cart
                        {
                            CartID = newcartid,
                            UserID = userid,
                            IsUsing = true
                        });
                        entity.SaveChanges();
                        return Ok(newcartid);
                    }
                    return Ok(oldcartid);
                }
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpPut]
        public IHttpActionResult UpdateCart(string cartid, CartModel[] items)
        {
            try
            {
                if (items == null)
                {
                    return Ok("OK");
                }
                using(var entity = new RoseFashionDBEntities())
                {
                    for(int i = 0; i < items.Length; i++)
                    {
                        var oneitem = items[i];
                        var olditem = entity.Cart_Product
                            .Where(cp => cp.ProductID == oneitem.ProductID && cp.Size == oneitem.Size).FirstOrDefault();
                        if (olditem != null) olditem.Amount = oneitem.Amount;
                        else
                        {
                            entity.Cart_Product.Add(new Cart_Product
                            {
                                CartID = cartid,
                                ProductID = oneitem.ProductID,
                                Size = oneitem.Size,
                                Amount = oneitem.Amount,
                                SalePrice = oneitem.SalePrice
                            });
                        }
                        entity.SaveChanges();
                    }
                }
                return Ok("OK");
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpGet]
        public IHttpActionResult GetItemsInCart(string cartid)
        {
            try
            {
                using(var entity = new RoseFashionDBEntities())
                {
                    var result = entity.Cart_Product.Where(cp => cp.CartID == cartid)
                             .Select(cp => new CartModel
                             {
                                 CartID = cp.CartID,
                                 ProductID = cp.ProductID,
                                 Name = cp.Product.Name,
                                 Image = cp.Product.Image,
                                 Size = cp.Size,
                                 Quantity = cp.Product.Product_Size_Quantity.Where(q => q.ProductID == cp.ProductID).Select(q => q.Quantity).FirstOrDefault(),
                                 Amount = cp.Amount,
                                 SalePrice = cp.Product.Price
                             }).ToList();
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
