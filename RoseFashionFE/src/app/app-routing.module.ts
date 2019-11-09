import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { AddProductComponent } from './ProductManagerment/add-product/add-product.component';
import { ViewProductListComponent } from './ProductManagerment/view-product-list/view-product-list.component';
import { UpdateProductComponent } from './ProductManagerment/update-product/update-product.component';
import { AddProductToCartComponent } from './ProductManagerment/add-product-to-cart/add-product-to-cart.component';
import { EditcategoryComponent } from './CategoryManagerment/editcategory/editcategory.component';
import { ShowcategoryComponent } from './CategoryManagerment/showcategory/showcategory.component'
const routes: Routes = [
  {path:'add-product', component: AddProductComponent},
  {path:'view-product-list', component: ViewProductListComponent},
  {path:'update-product/:productid', component: UpdateProductComponent},
  {path:'add-product-to-cart/:productid', component: AddProductToCartComponent},
  {path:'add-product', component: AddProductComponent},
  {path:'editcategory/:id', component: EditcategoryComponent},
  {path:'showcategory', component: ShowcategoryComponent}
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
