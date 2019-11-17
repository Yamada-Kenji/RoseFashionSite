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
    public class BillController : ApiController
    {
        [HttpPost]
        public IHttpActionResult AddBillForGuest(CartModel[] items, string userid)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    // tạo cart mới
                    string cartid = "CR-" + (entity.Carts.Count() + 1); 
                    entity.Carts.Add(new Cart
                    {
                        CartID = cartid,
                        UserID = userid,
                        IsUsing = false,
                    });
                    // lưu sản phẩm vào cart vừa tạo
                    for (int i = 0; i < items.Length; i++)
                    {
                        entity.Cart_Product.Add(new Cart_Product {
                            CartID = cartid,
                            ProductID = items[i].ProductID,
                            Amount = items[i].Amount
                        });
                    }
                    // tạo hóa đơn cho cart vừa tạo
                    entity.Bills.Add(new Bill {
                        BillID = "BL-" + (entity.Bills.Count() + 1),
                        CartID = cartid,
                        Date = DateTime.Now.Date
                    });
                    entity.SaveChanges();
                    return Ok("Add bill successfully.");
                }
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpGet]
        public IHttpActionResult GetAllBillInfo()
        {
            try
            {
                using(var entity = new RoseFashionDBEntities())
                {
                    var result = entity.Bills.Select(b => new BillModel
                    {
                        BillID = b.BillID,
                        CartID = b.CartID,
                        Date = b.Date
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
