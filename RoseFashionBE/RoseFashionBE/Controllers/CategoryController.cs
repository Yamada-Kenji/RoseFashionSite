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
    public class CategoryController : ApiController
    {
        [HttpGet]
        public IHttpActionResult GetAllCategory()
        {
            using (var entity = new RoseFashionDBEntities())
            {
                IList<CategoryModel> result = entity.Categories.Select(ct => new CategoryModel
                    {
                        CategoryID = ct.CategoryID,
                        Name = ct.Name,
                        MainCategory = ct.MainCategory
                    }).ToList();
                return Ok(result);
            }
        }
        [HttpGet]
        public IHttpActionResult GetCategoryFromMainCategory(string maincategory)
        {
            using(var entity = new RoseFashionDBEntities())
            {
                IList<CategoryModel> result = entity.Categories.Where(ct => ct.MainCategory == maincategory)
                    .Select(ct => new CategoryModel
                    {
                        CategoryID = ct.CategoryID,
                        Name = ct.Name,
                        MainCategory = ct.MainCategory
                    }).ToList();
                return Ok(result);
            }
        }
    }
}
