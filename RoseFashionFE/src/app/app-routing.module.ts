import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { AddProductComponent } from './ProductManagerment/add-product/add-product.component';
import { ViewProductListComponent } from './ProductManagerment/view-product-list/view-product-list.component';
import { UpdateProductComponent } from './ProductManagerment/update-product/update-product.component';
import { AddProductToCartComponent } from './ProductManagerment/add-product-to-cart/add-product-to-cart.component';
import { ViewCartComponent } from './CartManagement/view-cart/view-cart.component';
import { ViewProductListForCustomerComponent } from './ProductManagerment/view-product-list-for-customer/view-product-list-for-customer.component';


const routes: Routes = [
  {path:'add-product', component: AddProductComponent},
  {path:'view-product-list', component: ViewProductListComponent},
  {path:'update-product/:productid', component: UpdateProductComponent},
  {path:'add-product-to-cart/:productid', component: AddProductToCartComponent},
  {path: 'view-cart', component: ViewCartComponent},
  {path: 'view-product-list-for-customer', component: ViewProductListForCustomerComponent}
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
