import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { RegisterComponent } from './UserManagerment/register/register.component';
import { LoginComponent } from './UserManagerment/login/login.component';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { AddProductComponent } from './ProductManagerment/add-product/add-product.component';
import { UserService, ProductService, CategoryService, CartService } from './services';
import { ViewProductListComponent } from './ProductManagerment/view-product-list/view-product-list.component';
import { UpdateProductComponent } from './ProductManagerment/update-product/update-product.component';
import { AddProductToCartComponent } from './ProductManagerment/add-product-to-cart/add-product-to-cart.component';
import { ViewProductListForCustomerComponent } from './ProductManagerment/view-product-list-for-customer/view-product-list-for-customer.component';
import { ViewCartComponent } from './CartManagement/view-cart/view-cart.component';

@NgModule({
  declarations: [
    AppComponent,
    RegisterComponent,
    LoginComponent,
    AddProductComponent,
    ViewProductListComponent,
    UpdateProductComponent,
    AddProductToCartComponent,
    ViewProductListForCustomerComponent,
    ViewCartComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HttpClientModule,
    FormsModule
  ],
  providers: [UserService, ProductService, CategoryService, CartService],
  bootstrap: [AppComponent]
})
export class AppModule { }
