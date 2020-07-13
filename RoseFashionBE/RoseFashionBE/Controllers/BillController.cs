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
    [RoutePrefix("api/bill")]
    public class BillController : ApiController
    {
        /*[HttpPost]
        public IHttpActionResult AddBillForGuest(CartModel[] items, BillModel billinfo, string guestid)
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
                        UserID = guestid,
                        IsUsing = false,
                    });
                    // lưu sản phẩm vào cart vừa tạo
                    for (int i = 0; i < items.Length; i++)
                    {
                        entity.Cart_Product.Add(new Cart_Product {
                            CartID = cartid,
                            ProductID = items[i].ProductID,
                            Size = items[i].Size,
                            Amount = items[i].Amount,
                            SalePrice = items[i].SalePrice
                        });
                    }
                    // tạo hóa đơn cho cart vừa tạo
                    entity.Bills.Add(new Bill {
                        BillID = "BL-" + (entity.Bills.Count() + 1),
                        CartID = billinfo.CartID,
                        Date = DateTime.Now.Date,
                        ReceiverName = billinfo.ReceiverName,
                        ReceiverPhone = billinfo.ReceiverPhone,
                        DeliveryAddress = billinfo.DeliveryAddress,
                        DiscountCode = billinfo.DiscountCode,
                        TotalPrice = billinfo.TotalPrice
                    });
                    entity.SaveChanges();
                    return Ok("OK");
                }
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }*/

        [HttpPost]
        public IHttpActionResult AddBill(BillModel billinfo)
        {
            try
            {
                using(var entity = new RoseFashionDBEntities())
                {
                    entity.Bills.Add(new Bill
                    {
                        BillID = "BL-" + (entity.Bills.Count() + 1),
                        CartID = billinfo.CartID,
                        PaymentMethod = billinfo.PaymentMethod,
                        OrderDate = DateTime.Now.Date,
                        DeliveryDate = DateTime.Now.Date,
                        ReceiverName = billinfo.ReceiverName,
                        ReceiverPhone = billinfo.ReceiverPhone,
                        DeliveryAddress = billinfo.DeliveryAddress,
                        ProvinceName = billinfo.ProvinceName,
                        DistrictName = billinfo.DistrictName,
                        TotalPrice = billinfo.TotalPrice,
                        DeliveryFee = billinfo.DeliveryFee,
                        Status = billinfo.Status,
                        IsDeleted = false
                    });
                    var usercart = entity.Carts.Where(c => c.CartID == billinfo.CartID).FirstOrDefault();
                    usercart.IsUsing = false;
                    entity.SaveChanges();
                    return Ok("OK");
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

                    var result = entity.Bills.Where(b => b.IsDeleted == false).Select(b => new BillModel
                    {
                        BillID = b.BillID,
                        CartID = b.CartID,
                        ReceiverName = b.ReceiverName,
                        OrderDate = b.OrderDate,
                        DeliveryDate = b.DeliveryDate,
                        TotalPrice = b.TotalPrice,
                        Status = b.Status
                    }).ToList();
                    return Ok(result);
                }
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpGet]
        public IHttpActionResult GetUserBills(string userid)
        {
            try
            {
                using(var entity = new RoseFashionDBEntities())
                {
                    var cartidlist = entity.Carts.Where(c => c.UserID == userid && c.IsUsing == false)
                        .Select(c => c.CartID).ToList();
                    List<BillModel> result = new List<BillModel>();
                    for (int i = 0; i < cartidlist.Count(); i++)
                    {
                        string cartid = cartidlist[i];
                        var bill = entity.Bills.Where(b => b.CartID == cartid)
                            .Select(b => new BillModel
                            {
                                BillID = b.BillID,
                                OrderDate = b.OrderDate,
                                TotalPrice = b.TotalPrice,
                                Status = b.Status
                            }).FirstOrDefault();
                        result.Add(bill);
                    }
                    return Ok(result);
                }
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpGet]
        public IHttpActionResult GetBillOneInfo(string billid)
        {
            try
            {
                using(var entity = new RoseFashionDBEntities())
                {
                    var result = entity.Bills.Where(b => b.BillID == billid)
                        .Select(b => new BillModel
                        {
                            BillID = b.BillID,
                            CartID = b.CartID,
                            PaymentMethod = b.PaymentMethod,
                            ReceiverName = b.ReceiverName,
                            ReceiverPhone = b.ReceiverPhone,
                            DeliveryAddress = b.DeliveryAddress,
                            ProvinceName = b.ProvinceName,
                            DistrictName = b.DistrictName,
                            OrderDate = b.OrderDate,
                            DeliveryDate = b.DeliveryDate,
                            DiscountCode = b.DiscountCode,
                            DeliveryFee = b.DeliveryFee,
                            TotalPrice = b.TotalPrice,
                            Status = b.Status
                        }).FirstOrDefault();
                    return Ok(result);
                }
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpPost]
        [Route("updatebill")]
        public IHttpActionResult UpdateBill(BillModel billinfo)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    var bill = entity.Bills.Where(s => s.BillID == billinfo.BillID).FirstOrDefault();
                    string oldstatus = bill.Status;
                    bill.Status = billinfo.Status;
                    bill.DeliveryDate = billinfo.DeliveryDate;
                    entity.SaveChanges();
                    return Ok(oldstatus);
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpDelete]
        public IHttpActionResult RemoveBill(string billid)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    var oldbill = entity.Bills.Where(s => s.BillID == billid).FirstOrDefault();
                    if (oldbill != null) oldbill.IsDeleted = true;
                    entity.SaveChanges();
                    return Ok();
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }
    }
}
