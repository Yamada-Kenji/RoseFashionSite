import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { AddProductComponent } from './ProductManagement/add-product/add-product.component';


import { EditcategoryComponent } from './CategoryManagerment/editcategory/editcategory.component';
import { ShowcategoryComponent } from './CategoryManagerment/showcategory/showcategory.component'
import { ViewCartComponent } from './CartManagement/view-cart/view-cart.component';
import { ViewProductListForCustomerComponent } from './ProductManagement/view-product-list-for-customer/view-product-list-for-customer.component';
import { AddBillComponent } from './BillManagement/add-bill/add-bill.component';
import { ViewProductListComponent } from './ProductManagement/view-product-list/view-product-list.component';
import { UpdateProductComponent } from './ProductManagement/update-product/update-product.component';
import { AddProductToCartComponent } from './ProductManagement/add-product-to-cart/add-product-to-cart.component';
import {AddcategoryComponent} from './CategoryManagerment/addcategory/addcategory.component';
import {CreateAccountComponent} from './AccountManagerment/create-account/create-account.component';


const routes: Routes = [
  {path:'register', component: CreateAccountComponent},
  {path:'add-product', component: AddProductComponent},
  {path:'view-product-list', component: ViewProductListComponent},
  {path:'update-product/:productid', component: UpdateProductComponent},
  {path:'add-product-to-cart/:productid', component: AddProductToCartComponent},

  {path:'add-product', component: AddProductComponent},
  {path:'editcategory/:id', component: EditcategoryComponent},
  {path:'showcategory', component: ShowcategoryComponent},
  {path:'addcategory', component: AddcategoryComponent},

  {path: 'view-cart', component: ViewCartComponent},
  {path: 'view-product-list-for-customer', component: ViewProductListForCustomerComponent},
  {path: 'add-bill', component: AddBillComponent}

];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
