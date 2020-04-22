//------------------------------------------------------------------------------
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
    using System.Collections.Generic;
    
    public partial class Product
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Product()
        {
            this.Cart_Product = new HashSet<Cart_Product>();
            this.Product_Size_Quantity = new HashSet<Product_Size_Quantity>();
            this.Ratings = new HashSet<Rating>();
        }
    
        public string ProductID { get; set; }
        public string Name { get; set; }
        public string Color { get; set; }
        public string CategoryID { get; set; }
        public string Description { get; set; }
        public string Image { get; set; }
        public long Price { get; set; }
        public bool IsDeleted { get; set; }
        public int DiscountPercent { get; set; }
        public System.DateTime ImportDate { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Cart_Product> Cart_Product { get; set; }
        public virtual Category Category { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Product_Size_Quantity> Product_Size_Quantity { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Rating> Ratings { get; set; }
    }
}
