using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using RoseFashionBE.Models;
using System.Web.Http.Cors;
using System.Web;
using System.IO;

namespace RoseFashionBE.Controllers
{
    [EnableCors(origins: "*", headers: "*", methods: "*")]
    [RoutePrefix("api/product")]
    public class ProductController : ApiController
    {
        const string serverAddress = "http://localhost:62098";
        [HttpPost]
        public IHttpActionResult AddProduct(ProductModel newproduct)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    //kiểm tra sản phẩm đã tồn tại chưa
                    bool existedproduct = entity.Products.Any(p => p.Name == newproduct.Name);
                    if (existedproduct == true) return BadRequest("This product already exists.");

                    newproduct.ProductID = "PR-" + (entity.Products.Count() + 1);
                    var randomcode = Guid.NewGuid();
                    string imagename = newproduct.ProductID + "-" + randomcode + ".png";
                    string imagepath = serverAddress + "/images/" + imagename;
                    entity.Products.Add(new Product
                    {
                        ProductID = newproduct.ProductID,
                        Name = newproduct.Name,
                        CategoryID = newproduct.CategoryID,
                        Image = imagepath,
                        Price = newproduct.Price,
                        DiscountPercent = newproduct.DiscountPercent,
                        ImportDate = DateTime.Now.Date
                    });
                    entity.SaveChanges();

                    for (int i = 0; i < newproduct.Size.Count(); i++)
                    {
                        entity.Product_Size_Quantity.Add(new Product_Size_Quantity
                        {
                            ProductID = newproduct.ProductID,
                            Size = newproduct.Size[i],
                            Quantity = newproduct.Quantity[i]
                        });
                        entity.SaveChanges();
                    }               
                    return Ok(imagename);
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpPut]
        public IHttpActionResult EditProduct(ProductModel editedproduct)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {

                    //kiểm tra sản phẩm có tồn tại hay không
                    var existedproduct = entity.Products.Where(p => p.ProductID == editedproduct.ProductID).FirstOrDefault();
                    if (existedproduct == null) return BadRequest("Product not found.");
                    //nếu có => thay đổi các thuộc tính

                    //bỏ ảnh cũ thay ảnh mới
                    if (RemoveOldImage(existedproduct.Image) == false) return BadRequest("Fail to remove image");
                    existedproduct.Name = editedproduct.Name;
                    var randomcode = Guid.NewGuid();
                    string imagename = editedproduct.ProductID + "-" + randomcode + ".png";
                    existedproduct.Image = serverAddress + "/images/" + imagename;
                    existedproduct.CategoryID = editedproduct.CategoryID;
                    existedproduct.Price = editedproduct.Price;
                    existedproduct.DiscountPercent = editedproduct.DiscountPercent;
                    for (int i = 0; i < editedproduct.Size.Count(); i++)
                    {
                        string size = editedproduct.Size[i];
                        var currentquantity = entity.Product_Size_Quantity.Where(p => p.ProductID == editedproduct.ProductID && p.Size == size).FirstOrDefault();
                        currentquantity.Quantity = editedproduct.Quantity[i];
                    }
                    entity.SaveChanges();
                    return Ok(imagename);
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpDelete]
        public IHttpActionResult DeleteProduct(string productid)
        {
            try
            {
                using(var entity = new RoseFashionDBEntities())
                {
                    var existedproduct = entity.Products.Where(p => p.ProductID == productid).FirstOrDefault();
                    if (existedproduct == null) return BadRequest("Product not found.");
                    existedproduct.IsDeleted = true;
                    entity.SaveChanges();
                    return Ok("Remove product successfully.");
                }
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpPost]
        [Route("remove")]
        public IHttpActionResult DeleteMultipleProduct(string[] pids)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    for (int i = 0; i < pids.Count(); i++)
                    {
                        string id = pids[i];
                        var existedproduct = entity.Products.Where(p => p.ProductID == id).FirstOrDefault();
                        if (existedproduct == null) return BadRequest("Product not found.");
                        existedproduct.IsDeleted = true;
                        entity.SaveChanges();
                    }
                    return Ok("Remove products successfully.");
                }
            }
            catch (Exception ex)
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
                    ProductModel result = null;
                    result = entity.Products.Where(p => p.ProductID == pid && p.IsDeleted == false)
                        .Select(p => new ProductModel()
                        {
                            ProductID = p.ProductID,
                            Name = p.Name,
                            Image = p.Image,
                            CategoryID = p.CategoryID,
                            Price = p.Price,
                            DiscountPercent = p.DiscountPercent
                        }).FirstOrDefault();
                    if (result == null) return BadRequest("Product not found.");
                    else
                    {
                        //mảng dùng để sắp xếp size và số lượng
                        string[] sizeorder = new string[] { "S", "M", "L", "XL", "XXL" };

                        //tìm các size của sản phẩm và số lượng tương ứng với mỗi size 
                        result.Size = entity.Product_Size_Quantity.Where(p => p.ProductID == pid)
                            .Select(p => p.Size).ToArray();
                        result.Quantity = entity.Product_Size_Quantity.Where(p => p.ProductID == pid)                          
                            .Select(p => p.Quantity).ToArray();

                        //tạo list lưu vị trí của từng phần tử của mảng sizeorder trong mảng product.Size vừa tìm được
                        //vd: product.Size = [M, L, S, X, XXL] thì phần tử sizeorder[0] = S sẽ có index là 2 
                        //==> indexarr     = [2, 0, 1, 3, 4]
                        List<int> indexarr = new List<int>();
                        for (int i = 0; i < sizeorder.Count(); i++)
                        {                            
                            indexarr.Add(Array.IndexOf(sizeorder, result.Size[i]));
                        }

                        //tạo mảng tạm để lưu giá trị hiện tại của mảng product.Size 
                        int[] temp = new int[sizeorder.Count()];
                        Array.Copy(result.Quantity, temp, sizeorder.Count());
                        //sắp xếp lại giá trị quantity theo thứ tự của mảng indexarr
                        //result.Quantity[0] sẽ chứa số lượng của size S 
                        //nhưng theo indexarr thì vị trí chứa số lượng của size S hiện tại đang nằm ở index = 2
                        //==> result.Quantity[0] = temp[2]
                        for (int i = 0; i < temp.Count(); i++)
                        {
                            result.Quantity[i] = temp[indexarr[i]];
                        }
                        //sắp xếp giá trị của mảng product.Size theo mảng sizeorder
                        result.Size = result.Size.OrderBy(s => Array.IndexOf(sizeorder, s)).ToArray();
                        return Ok(result);
                    }
                }
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        void GetProductSizeAndQuantity(ProductModel product, string pid)
        {
            using(var entity = new RoseFashionDBEntities())
            {
                //mảng dùng để sắp xếp size và số lượng
                string[] sizeorder = new string[] { "S", "M", "L", "XL", "XXL" };

                //tìm các size của sản phẩm và số lượng tương ứng với mỗi size 
                product.Size = entity.Product_Size_Quantity.Where(p => p.ProductID == pid)
                    .Select(p => p.Size).ToArray();
                product.Quantity = entity.Product_Size_Quantity.Where(p => p.ProductID == pid)
                    .Select(p => p.Quantity).ToArray();

                //tạo list lưu vị trí của từng phần tử của mảng sizeorder trong mảng product.Size vừa tìm được
                //vd: product.Size = [M, L, S, X, XXL] thì phần tử sizeorder[0] = S sẽ có index là 2 
                //==> indexarr     = [2, 0, 1, 3, 4]
                List<int> indexarr = new List<int>();
                for (int i = 0; i < sizeorder.Count(); i++)
                {
                    indexarr.Add(Array.IndexOf(sizeorder, product.Size[i]));
                }

                //tạo mảng tạm để lưu giá trị hiện tại của mảng product.Size 
                int[] temp = new int[sizeorder.Count()];
                Array.Copy(product.Quantity, temp, sizeorder.Count());
                //sắp xếp lại giá trị quantity theo thứ tự của mảng indexarr
                //result.Quantity[0] sẽ chứa số lượng của size S 
                //nhưng theo indexarr thì vị trí chứa số lượng của size S hiện tại đang nằm ở index = 2
                //==> result.Quantity[0] = temp[2]
                for (int i = 0; i < temp.Count(); i++)
                {
                    product.Quantity[i] = temp[indexarr[i]];
                }
                //sắp xếp giá trị của mảng product.Size theo mảng sizeorder
                product.Size = product.Size.OrderBy(s => Array.IndexOf(sizeorder, s)).ToArray();
            }
        }

        [HttpGet]
        public IHttpActionResult GetAllProduct()
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    var result = entity.Products.Where(p => p.IsDeleted == false).Select(p => new ProductModel
                    {
                        ProductID = p.ProductID,
                        Name = p.Name,
                        Image = p.Image,
                        Price = p.Price,
                        CategoryID = p.CategoryID,
                        DiscountPercent = p.DiscountPercent,
                        ImportDate = p.ImportDate
                    }).ToList();
                    for(int i = 0; i < result.Count; i++)
                    {
                        string id = result[i].ProductID;
                        result[i].Quantity = new int[1];
                        result[i].Quantity[0] = entity.Product_Size_Quantity.Where(p => p.ProductID == id).Sum(p => p.Quantity);
                        GetProductSizeAndQuantity(result[i], id);
                        if (entity.Product_Size_Quantity.Any(p => p.ProductID == id && p.Quantity > 0))
                        {
                            result[i].SoldOut = false;   
                        }
                        else result[i].SoldOut = true;
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
        public IHttpActionResult FindProduct(string keyword)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    var result = entity.Products.Where(c => c.Name.Contains(keyword) && c.IsDeleted == false)
                        .Select(c => new ProductModel
                        {
                            ProductID = c.ProductID,
                            Name = c.Name,
                            Image = c.Image,
                            Price = c.Price,
                            CategoryID = c.CategoryID,
                            DiscountPercent = c.DiscountPercent
                        }).ToList();
                    //.Select(p => p.ProductID).ToList();
                    return Ok(result);
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpGet]
        public IHttpActionResult GetProductByCategory(string categoryid)
        {
            try
            {
                using(var entity = new RoseFashionDBEntities())
                {
                    var result = entity.Products.Where(p => (p.CategoryID == categoryid ||
                    p.Category.MainCategory == categoryid) && p.IsDeleted == false)
                        //.Select(p => p.ProductID).ToList();
                        .Select(p => new ProductModel
                        {
                            ProductID = p.ProductID,
                            Name = p.Name,
                            Image = p.Image,
                            Price = p.Price,
                            CategoryID = p.CategoryID,
                            DiscountPercent = p.DiscountPercent
                        }).ToList();
                    for (int i = 0; i < result.Count; i++)
                    {
                        string id = result[i].ProductID;
                        if (entity.Product_Size_Quantity.Any(p => p.ProductID == id && p.Quantity > 0))
                        {
                            result[i].SoldOut = false;
                        }
                        else result[i].SoldOut = true;
                    }
                    return Ok(result);
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpGet]
        [Route("topsale")]
        public IHttpActionResult GetTopSales()
        {
            try
            {
                using(var entity = new RoseFashionDBEntities())
                {
                    var topsale = entity.fn_GetTopSales(8).Select(p=>p.PID).ToList();
                    List<ProductModel> result = new List<ProductModel>();
                    for (int i = 0; i < topsale.Count(); i++)
                    {
                        string pid = topsale[i];
                        var product = entity.Products.Where(p => p.ProductID == pid)
                            .Select(p=> new ProductModel {
                                ProductID = p.ProductID,
                                Name = p.Name,
                                Image = p.Image,
                                Price = p.Price,
                                DiscountPercent = p.DiscountPercent
                            }).FirstOrDefault();
                        result.Add(product);
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
        [Route("newproducts")]
        public IHttpActionResult GetNewestProducts()
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    var topsale = entity.fn_GetNewestProduct(8).Select(p => p.PID).ToList();
                    List<ProductModel> result = new List<ProductModel>();
                    for (int i = 0; i < topsale.Count(); i++)
                    {
                        string pid = topsale[i];
                        var product = entity.Products.Where(p => p.ProductID == pid)
                            .Select(p => new ProductModel
                            {
                                ProductID = p.ProductID,
                                Name = p.Name,
                                Image = p.Image,
                                Price = p.Price,
                                DiscountPercent = p.DiscountPercent
                            }).FirstOrDefault();
                        result.Add(product);
                    }
                    return Ok(result);
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        /*[HttpGet]
        [Route("page")]
        public IHttpActionResult GetOnePage(string[] idlist)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    List<ProductModel> result = new List<ProductModel>();
                    for(int i = 0; i < idlist.Length; i++)
                    {
                        string id = idlist[i];
                        ProductModel item = entity.Products.Where(p => p.ProductID == id)
                            .Select(p => new ProductModel
                            {
                                ProductID = p.ProductID,
                                Name = p.Name,
                                Image = p.Image,
                                Price = p.Price,
                                DiscountPercent = p.DiscountPercent
                            }).FirstOrDefault();
                        result.Add(item);
                    }
                    return Ok(result);
                }
            }
            catch (Exception err)
            {
                return InternalServerError(err);
            }
        }

        [HttpGet]
        [Route("list")]
        public IHttpActionResult GetAllProductID()
        {
            try
            {
                using(var entity = new RoseFashionDBEntities())
                {
                    var result = entity.Products.Select(p => p.ProductID).ToList();
                    return Ok(result);
                }
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }*/

        [HttpPost]
        [Route("imgupload")]
        public IHttpActionResult UploadImage()
        {
            try
            {
                var httpRequest = HttpContext.Current.Request;
                var imagename = httpRequest.Params["imagename"];
                var image = httpRequest.Files[0];
                var newPath = HttpContext.Current.Server.MapPath("~/images/" + imagename);
                image.SaveAs(newPath);
                return Ok();
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        private bool RemoveOldImage(string imagepath)
        {
            try
            {
                string temp = imagepath.Replace(serverAddress, "~");
                string serverpath = HttpContext.Current.Server.MapPath(temp);
                if (File.Exists(serverpath))
                {
                    File.Delete(serverpath);
                }
                else
                {
                    return false;
                }
                return true;
            }
            catch(Exception ex)
            {
                return false;
            }
        }

        [HttpPost]
        [Route("defaultrating")]
        public IHttpActionResult DefaultRating(string cartid)
        {
            try
            {
                using(var entity = new RoseFashionDBEntities())
                {
                    var items = entity.Cart_Product.Where(cp => cp.CartID == cartid).ToList();
                    for(int i = 0; i < items.Count; i++)
                    {
                        string pid = items[i].ProductID;
                        string userid = items[i].Cart.UserID;
                        var existed = entity.Ratings.Where(r => r.UserID == userid && r.ProductID == pid).FirstOrDefault();
                        if (existed == null)
                        {
                            entity.Ratings.Add(new Rating()
                            {
                                UserID = userid,
                                ProductID = pid,
                                Star = 3
                            });
                        }
                    }
                    entity.SaveChanges();
                    return Ok();
                }
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpGet]
        [Route("purchased")]
        public IHttpActionResult CheckingPurchasedProduct(string userid, string productid)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    bool result = false;
                    var existed = entity.fn_CheckingIfProductWasPurchasedByUser(userid, productid).FirstOrDefault();
                    if (existed != null) result = true;
                    return Ok(result);
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpGet]
        [Route("ratinglist")]
        public IHttpActionResult GetProductRatingList(string pid)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    var result = entity.Ratings.Where(r => r.ProductID == pid)
                        .Select(r=>new RatingModel()
                        {
                            UserName = r.User.FullName,
                            Title = r.Title,
                            Comment = r. Comment,
                            Star = r.Star,
                            RatingDate = r.RatingDate
                        }).ToList();
                    return Ok(result);
                }
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpPost]
        [Route("addrating")]
        public IHttpActionResult AddUserRating(RatingModel newrating)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    var oldrating = entity.Ratings.Where(r => r.UserID == newrating.UserID && r.ProductID == newrating.ProductID).FirstOrDefault();
                    if (oldrating!=null)
                    {
                        oldrating.Title = newrating.Title;
                        oldrating.Comment = newrating.Comment;
                        oldrating.Star = newrating.Star;
                        oldrating.RatingDate = DateTime.Now.Date;
                        entity.SaveChanges();
                    }
                    else
                    {
                        entity.Ratings.Add(new Rating()
                        {
                            UserID = newrating.UserID,
                            ProductID = newrating.ProductID,
                            Title = newrating.Title,
                            Comment = newrating.Comment,
                            Star = newrating.Star,
                            RatingDate = DateTime.Now.Date
                        });
                        entity.SaveChanges();
                    }
                    return Ok();
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpGet]
        [Route("totalrating")]
        public IHttpActionResult GetTotalRatingOfProduct(string pid)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    double result = 0;
                    var ratinglist = entity.Ratings.Where(r => r.ProductID == pid).ToList();
                    if (ratinglist.Count > 0) {
                        result = ratinglist.Sum(r => r.Star) / ratinglist.Count;
                    }
                    return Ok(result);
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpGet]
        [Route("onerating")]
        public IHttpActionResult GetOneUserRating(string userid, string pid)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    var result = entity.Ratings.Where(r => r.UserID == userid && r.ProductID == pid)
                        .Select(r => new RatingModel()
                        {
                            UserID = r.UserID,
                            ProductID = r.ProductID,
                            Title = r.Title,
                            Comment = r.Comment,
                            Star = r.Star
                        }).FirstOrDefault();
                    if (result == null)
                    {
                        result = new RatingModel();
                        result.UserID = userid;
                        result.ProductID = pid;
                    }
                    return Ok(result);
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpGet]
        [Route("recommend")]
        public IHttpActionResult GetRecommendedProduct(string userid)
        {
            try
            {
                using(var entity = new RoseFashionDBEntities())
                {
                    //chọn top 10 sp mà user có rating dự đoán cao
                    var recommendedproducts = entity.fn_GetRecommendedProduct(userid).ToList();

                    var result = new List<ProductModel>();
                    foreach(string productid in recommendedproducts)
                    {
                        var item = entity.Products.Where(p => p.ProductID == productid)
                            .Select(p => new ProductModel()
                            {
                                ProductID = p.ProductID,
                                Name = p.Name,
                                Image = p.Image,
                                Price = p.Price,
                                CategoryID = p.CategoryID,
                                DiscountPercent = p.DiscountPercent
                            }).FirstOrDefault();
                        result.Add(item);
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
