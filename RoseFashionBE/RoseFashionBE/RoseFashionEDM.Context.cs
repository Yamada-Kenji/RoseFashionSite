﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace RoseFashionBE
{
    using System;
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    using System.Data.Entity.Core.Objects;
    using System.Linq;
    
    public partial class RoseFashionDBEntities : DbContext
    {
        public RoseFashionDBEntities()
            : base("name=RoseFashionDBEntities")
        {
        }
    
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            throw new UnintentionalCodeFirstException();
        }
    
        public virtual DbSet<Cart> Carts { get; set; }
        public virtual DbSet<Cart_Product> Cart_Product { get; set; }
        public virtual DbSet<Category> Categories { get; set; }
        public virtual DbSet<Product_Size_Quantity> Product_Size_Quantity { get; set; }
        public virtual DbSet<sysdiagram> sysdiagrams { get; set; }
        public virtual DbSet<User> Users { get; set; }
        public virtual DbSet<Discount> Discounts { get; set; }
        public virtual DbSet<District> Districts { get; set; }
        public virtual DbSet<Province> Provinces { get; set; }
        public virtual DbSet<Recommendation> Recommendations { get; set; }
        public virtual DbSet<Similarity> Similarities { get; set; }
        public virtual DbSet<Rating> Ratings { get; set; }
        public virtual DbSet<Bill> Bills { get; set; }
        public virtual DbSet<Product> Products { get; set; }
    
        public virtual int sp_alterdiagram(string diagramname, Nullable<int> owner_id, Nullable<int> version, byte[] definition)
        {
            var diagramnameParameter = diagramname != null ?
                new ObjectParameter("diagramname", diagramname) :
                new ObjectParameter("diagramname", typeof(string));
    
            var owner_idParameter = owner_id.HasValue ?
                new ObjectParameter("owner_id", owner_id) :
                new ObjectParameter("owner_id", typeof(int));
    
            var versionParameter = version.HasValue ?
                new ObjectParameter("version", version) :
                new ObjectParameter("version", typeof(int));
    
            var definitionParameter = definition != null ?
                new ObjectParameter("definition", definition) :
                new ObjectParameter("definition", typeof(byte[]));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_alterdiagram", diagramnameParameter, owner_idParameter, versionParameter, definitionParameter);
        }
    
        public virtual int sp_creatediagram(string diagramname, Nullable<int> owner_id, Nullable<int> version, byte[] definition)
        {
            var diagramnameParameter = diagramname != null ?
                new ObjectParameter("diagramname", diagramname) :
                new ObjectParameter("diagramname", typeof(string));
    
            var owner_idParameter = owner_id.HasValue ?
                new ObjectParameter("owner_id", owner_id) :
                new ObjectParameter("owner_id", typeof(int));
    
            var versionParameter = version.HasValue ?
                new ObjectParameter("version", version) :
                new ObjectParameter("version", typeof(int));
    
            var definitionParameter = definition != null ?
                new ObjectParameter("definition", definition) :
                new ObjectParameter("definition", typeof(byte[]));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_creatediagram", diagramnameParameter, owner_idParameter, versionParameter, definitionParameter);
        }
    
        public virtual int sp_dropdiagram(string diagramname, Nullable<int> owner_id)
        {
            var diagramnameParameter = diagramname != null ?
                new ObjectParameter("diagramname", diagramname) :
                new ObjectParameter("diagramname", typeof(string));
    
            var owner_idParameter = owner_id.HasValue ?
                new ObjectParameter("owner_id", owner_id) :
                new ObjectParameter("owner_id", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_dropdiagram", diagramnameParameter, owner_idParameter);
        }
    
        public virtual ObjectResult<sp_helpdiagramdefinition_Result> sp_helpdiagramdefinition(string diagramname, Nullable<int> owner_id)
        {
            var diagramnameParameter = diagramname != null ?
                new ObjectParameter("diagramname", diagramname) :
                new ObjectParameter("diagramname", typeof(string));
    
            var owner_idParameter = owner_id.HasValue ?
                new ObjectParameter("owner_id", owner_id) :
                new ObjectParameter("owner_id", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<sp_helpdiagramdefinition_Result>("sp_helpdiagramdefinition", diagramnameParameter, owner_idParameter);
        }
    
        public virtual ObjectResult<sp_helpdiagrams_Result> sp_helpdiagrams(string diagramname, Nullable<int> owner_id)
        {
            var diagramnameParameter = diagramname != null ?
                new ObjectParameter("diagramname", diagramname) :
                new ObjectParameter("diagramname", typeof(string));
    
            var owner_idParameter = owner_id.HasValue ?
                new ObjectParameter("owner_id", owner_id) :
                new ObjectParameter("owner_id", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<sp_helpdiagrams_Result>("sp_helpdiagrams", diagramnameParameter, owner_idParameter);
        }
    
        public virtual int sp_renamediagram(string diagramname, Nullable<int> owner_id, string new_diagramname)
        {
            var diagramnameParameter = diagramname != null ?
                new ObjectParameter("diagramname", diagramname) :
                new ObjectParameter("diagramname", typeof(string));
    
            var owner_idParameter = owner_id.HasValue ?
                new ObjectParameter("owner_id", owner_id) :
                new ObjectParameter("owner_id", typeof(int));
    
            var new_diagramnameParameter = new_diagramname != null ?
                new ObjectParameter("new_diagramname", new_diagramname) :
                new ObjectParameter("new_diagramname", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_renamediagram", diagramnameParameter, owner_idParameter, new_diagramnameParameter);
        }
    
        public virtual int sp_upgraddiagrams()
        {
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("sp_upgraddiagrams");
        }
    
        [DbFunction("RoseFashionDBEntities", "fn_GetProductRatingFromTopSimilarUser")]
        public virtual IQueryable<fn_GetProductRatingFromTopSimilarUser_Result> fn_GetProductRatingFromTopSimilarUser(string userid, string productid)
        {
            var useridParameter = userid != null ?
                new ObjectParameter("userid", userid) :
                new ObjectParameter("userid", typeof(string));
    
            var productidParameter = productid != null ?
                new ObjectParameter("productid", productid) :
                new ObjectParameter("productid", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.CreateQuery<fn_GetProductRatingFromTopSimilarUser_Result>("[RoseFashionDBEntities].[fn_GetProductRatingFromTopSimilarUser](@userid, @productid)", useridParameter, productidParameter);
        }
    
        [DbFunction("RoseFashionDBEntities", "fn_GetRecommendedProduct")]
        public virtual IQueryable<string> fn_GetRecommendedProduct(string userid)
        {
            var useridParameter = userid != null ?
                new ObjectParameter("userid", userid) :
                new ObjectParameter("userid", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.CreateQuery<string>("[RoseFashionDBEntities].[fn_GetRecommendedProduct](@userid)", useridParameter);
        }
    
        [DbFunction("RoseFashionDBEntities", "fn_GetTwoVetor")]
        public virtual IQueryable<fn_GetTwoVetor_Result> fn_GetTwoVetor(string userid1, string userid2)
        {
            var userid1Parameter = userid1 != null ?
                new ObjectParameter("userid1", userid1) :
                new ObjectParameter("userid1", typeof(string));
    
            var userid2Parameter = userid2 != null ?
                new ObjectParameter("userid2", userid2) :
                new ObjectParameter("userid2", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.CreateQuery<fn_GetTwoVetor_Result>("[RoseFashionDBEntities].[fn_GetTwoVetor](@userid1, @userid2)", userid1Parameter, userid2Parameter);
        }
    
        [DbFunction("RoseFashionDBEntities", "fn_GetUnRatedProduct")]
        public virtual IQueryable<string> fn_GetUnRatedProduct(string userid)
        {
            var useridParameter = userid != null ?
                new ObjectParameter("userid", userid) :
                new ObjectParameter("userid", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.CreateQuery<string>("[RoseFashionDBEntities].[fn_GetUnRatedProduct](@userid)", useridParameter);
        }
    
        [DbFunction("RoseFashionDBEntities", "fn_GetTopSales")]
        public virtual IQueryable<fn_GetTopSales_Result> fn_GetTopSales(Nullable<int> quantity)
        {
            var quantityParameter = quantity.HasValue ?
                new ObjectParameter("quantity", quantity) :
                new ObjectParameter("quantity", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.CreateQuery<fn_GetTopSales_Result>("[RoseFashionDBEntities].[fn_GetTopSales](@quantity)", quantityParameter);
        }
    
        [DbFunction("RoseFashionDBEntities", "fn_GetNewestProduct")]
        public virtual IQueryable<fn_GetNewestProduct_Result> fn_GetNewestProduct(Nullable<int> quantity)
        {
            var quantityParameter = quantity.HasValue ?
                new ObjectParameter("quantity", quantity) :
                new ObjectParameter("quantity", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.CreateQuery<fn_GetNewestProduct_Result>("[RoseFashionDBEntities].[fn_GetNewestProduct](@quantity)", quantityParameter);
        }
    
        public virtual int proc_RemoveOldRecommendation(string userid)
        {
            var useridParameter = userid != null ?
                new ObjectParameter("userid", userid) :
                new ObjectParameter("userid", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("proc_RemoveOldRecommendation", useridParameter);
        }
    
        [DbFunction("RoseFashionDBEntities", "fn_CheckingIfProductWasPurchasedByUser")]
        public virtual IQueryable<fn_CheckingIfProductWasPurchasedByUser_Result> fn_CheckingIfProductWasPurchasedByUser(string userid, string productid)
        {
            var useridParameter = userid != null ?
                new ObjectParameter("userid", userid) :
                new ObjectParameter("userid", typeof(string));
    
            var productidParameter = productid != null ?
                new ObjectParameter("productid", productid) :
                new ObjectParameter("productid", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.CreateQuery<fn_CheckingIfProductWasPurchasedByUser_Result>("[RoseFashionDBEntities].[fn_CheckingIfProductWasPurchasedByUser](@userid, @productid)", useridParameter, productidParameter);
        }
    }
}
