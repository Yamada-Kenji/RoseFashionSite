import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { AddProductComponent } from './ProductManagement/add-product/add-product.component';

import { UserService, ProductService, CategoryService, CartService } from './services';

import { AddcategoryComponent } from './CategoryManagerment/addcategory/addcategory.component';
import { EditcategoryComponent } from './CategoryManagerment/editcategory/editcategory.component';
import { ShowcategoryComponent } from './CategoryManagerment/showcategory/showcategory.component';

import { ViewProductListComponent } from './ProductManagement/view-product-list/view-product-list.component';
import { UpdateProductComponent } from './ProductManagement/update-product/update-product.component';
import { AddProductToCartComponent } from './ProductManagement/add-product-to-cart/add-product-to-cart.component';
import { ViewProductListForCustomerComponent } from './ProductManagement/view-product-list-for-customer/view-product-list-for-customer.component';

import { ViewCartComponent } from './CartManagement/view-cart/view-cart.component';
import { CreateAccountComponent } from './AccountManagerment/create-account/create-account.component';
import { EditAccountComponent } from './AccountManagerment/edit-account/edit-account.component';

import { NgxPaginationModule } from 'ngx-pagination';
import { AddBillComponent } from './BillManagement/add-bill/add-bill.component';


@NgModule({
  declarations: [
    AppComponent,
    AddProductComponent,
    AddcategoryComponent,
    EditcategoryComponent,
    ShowcategoryComponent,
    ViewProductListComponent,
    UpdateProductComponent,
    AddProductToCartComponent,
    ViewProductListForCustomerComponent,
    ViewCartComponent,
    CreateAccountComponent,
    EditAccountComponent,
    AddBillComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HttpClientModule,
    FormsModule,
    ReactiveFormsModule,
    NgxPaginationModule
  ],
  providers: [UserService, ProductService, CategoryService, CartService],
  bootstrap: [AppComponent]
})
export class AppModule { }
