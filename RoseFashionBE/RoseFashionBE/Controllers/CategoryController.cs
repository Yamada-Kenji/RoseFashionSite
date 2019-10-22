﻿using RoseFashionBE.Models;
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

        [HttpPost]
        public IHttpActionResult AddCategory(CategoryModel newcategory)
        {
            try
            {
                using (var entity = new RoseFashionDBEntities())
                {
                    entity.Categories.Add(new Category()
                    {
                        CategoryID = "Cata" + (entity.Categories.Count() + 1),
                        Name = newcategory.Name,
                        MainCategory = newcategory.MainCategory
                    });
                    entity.SaveChanges();
                    return Ok("Add new category successfully.");
                }
            }
            catch (Exception ex)
            {
                return InternalServerError(ex);
            }
        }

        [HttpPut]
        public IHttpActionResult EditCategory(CategoryModel updatecategory)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest("Invalid data.");
            }
            using (var entity = new RoseFashionDBEntities())
            {
                var IDCategory = entity.Categories.Where(c => c.CategoryID.Equals(updatecategory.CategoryID)).FirstOrDefault();
                if (IDCategory != null)
                {
                    IDCategory.Name = updatecategory.Name;
                    IDCategory.MainCategory = updatecategory.MainCategory;
                    entity.SaveChanges();
                    return Ok("Edit category successfully!");
                }
                return NotFound();

            }
        }

    }
}
