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
        /*private bool AddOneProduct(RoseFashionDBEntities entity, ProductModel newproduct, string size, int quantity)
        {
            try
            {
                entity.Products.Add(new Product
                {
                    ProductID = "PR-" + (entity.Products.Count() + 1),
                    Name = newproduct.Name,
                    Color = newproduct.Color,
                    Size = size,
                    CategoryID = newproduct.CategoryID,
                    Description = newproduct.Description,
                    Quantity = quantity,
                    Image = newproduct.Image,
                    Price = newproduct.Price
                });
                entity.SaveChanges();
                return true;
            }
            catch(Exception ex)
            {
                return false;
            }
        }*/

        /*private bool UpdateOneProduct(RoseFashionDBEntities entity, ProductModel newproduct, string size, int quantity)
        {
            try
            {
                var exist  = entity.Products.Where(p => p.ProductID == newproduct.ProductID).FirstOrDefault();
                entity.Products.Add(new Product
                {
                    ProductID = "PR-" + (entity.Products.Count() + 1),
                    Name = newproduct.Name,
                    Color = newproduct.Color,
                    Size = size,
                    CategoryID = newproduct.CategoryID,
                    Description = newproduct.Description,
                    Quantity = quantity,
                    Image = newproduct.Image,
                    Price = newproduct.Price
                });
                entity.SaveChanges();
                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
        }*/

        [HttpPost]
        public IHttpActionResult AddProduct(ProductModel newproduct)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    //kiểm tra sản phẩm đã tồn tại chưa
                    bool existedproduct = entity.Products.Any(p => p.Name == newproduct.Name && p.Color == newproduct.Color);
                    if (existedproduct == true) return BadRequest("This product already exists.");

                    newproduct.ProductID = "PR-" + (entity.Products.Count() + 1);
                    entity.Products.Add(new Product
                    {
                        ProductID = newproduct.ProductID,
                        Name = newproduct.Name,
                        Color = newproduct.Color,
                        CategoryID = newproduct.CategoryID,
                        //Description = newproduct.Description,
                        Image = newproduct.Image,
                        Price = newproduct.Price
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
                    return Ok("Add new product successfully.");
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
                    existedproduct.Name = editedproduct.Name;
                    existedproduct.Color = editedproduct.Color;
                    existedproduct.Image = editedproduct.Image;
                    existedproduct.CategoryID = editedproduct.CategoryID;
                    existedproduct.Description = editedproduct.Description;
                    existedproduct.Price = editedproduct.Price;
                    for (int i = 0; i < editedproduct.Size.Count(); i++)
                    {
                        string size = editedproduct.Size[i];
                        var currentquantity = entity.Product_Size_Quantity.Where(p => p.ProductID == editedproduct.ProductID && p.Size == size).FirstOrDefault();
                        currentquantity.Quantity = editedproduct.Quantity[i];
                    }
                    entity.SaveChanges();
                    return Ok("Update product successfully.");
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

        [HttpGet]
        public IHttpActionResult GetProductDetail(string pid)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    ProductModel result = null;
                    result = entity.Products.Where(p => p.ProductID == pid)
                        .Select(p => new ProductModel()
                        {
                            ProductID = p.ProductID,
                            Name = p.Name,
                            Color = p.Color,
                            Image = p.Image,
                            CategoryID = p.CategoryID,
                            Description = p.Description,
                            Price = p.Price,
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

        [HttpGet]
        public IHttpActionResult GetProductListForAdmin()
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
                        Color = p.Color,
                        Price = p.Price
                    }).ToList();
                    return Ok(result);
                }
            }
            catch(Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpGet] IHttpActionResult GetProductByCategory(string categoryid)
        {
            try
            {
                using(var entity = new RoseFashionDBEntities())
                {
                    var result = entity.Products.Where(p => (p.CategoryID == categoryid || 
                    p.Category.MainCategory == categoryid) && p.IsDeleted == false)
                        .Select(p => new ProductModel
                        {
                            ProductID = p.ProductID,
                            Name = p.Name,
                            Image = p.Image,
                            Color = p.Color,
                            Price = p.Price
                        }).ToList();
                    return Ok(result);
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }
    }
}
