import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { RegisterComponent } from './UserManagerment/register/register.component';
import { LoginComponent } from './UserManagerment/login/login.component';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { AddProductComponent } from './ProductManagerment/add-product/add-product.component';
import { UserService, ProductService, CategoryService } from './services';
import { AddcategoryComponent } from './CategoryManagerment/addcategory/addcategory.component';
import { EditcategoryComponent } from './CategoryManagerment/editcategory/editcategory.component';
import { ShowcategoryComponent } from './CategoryManagerment/showcategory/showcategory.component';

@NgModule({
  declarations: [
    AppComponent,
    RegisterComponent,
    LoginComponent,
    AddProductComponent,
    AddcategoryComponent,
    EditcategoryComponent,
    ShowcategoryComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HttpClientModule,
    FormsModule,
    ReactiveFormsModule
  ],
  providers: [UserService, ProductService, CategoryService],
  bootstrap: [AppComponent]
})
export class AppModule { }
