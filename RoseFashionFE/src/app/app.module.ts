import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';



import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { AddProductComponent } from './ProductManagement/add-update-product/add-product.component';

//import { UserService, ProductService, CategoryService, CartService, BillService, MessageService } from './services';

import { AddcategoryComponent } from './CategoryManagerment/addcategory/addcategory.component';
import { EditcategoryComponent } from './CategoryManagerment/editcategory/editcategory.component';
import { ShowcategoryComponent } from './CategoryManagerment/showcategory/showcategory.component';

import { ViewProductListComponent } from './ProductManagement/view-product-list/view-product-list.component';
import { AddProductToCartComponent } from './ProductManagement/add-product-to-cart/add-product-to-cart.component';
import { ViewProductListForCustomerComponent } from './ProductManagement/view-product-list-for-customer/view-product-list-for-customer.component';

import { ViewCartComponent } from './CartManagement/view-cart/view-cart.component';
import { CreateAccountComponent } from './AccountManagerment/create-account/create-account.component';
import { EditAccountComponent } from './AccountManagerment/edit-account/edit-account.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';



import { NgxPaginationModule } from 'ngx-pagination';
import { AddBillComponent } from './BillManagement/add-bill/add-bill.component';
import { HomepageComponent } from './Others/homepage/homepage.component';
import { MessageModalComponent } from './Others/message-modal/message-modal.component';
import { AuthGuard } from './Shared/auth-guard';
import { UserService } from './Shared/user-service';
import { ProductService } from './Shared/product-service';
import { CategoryService } from './Shared/category-service';
import { CartService } from './Shared/cart-service';
import { BillService } from './Shared/bill-service';
import { MessageService } from './Shared/message-service';
import { KeyWord } from './Shared/model';
import { ViewBillDetailComponent } from './BillManagement/view-bill-detail/view-bill-detail.component';
import { ViewBillForCustomerComponent } from './BillManagement/view-bill-for-customer/view-bill-for-customer.component';
import { ViewBillForAdminComponent } from './BillManagement/view-bill-for-admin/view-bill-for-admin.component';
import { ProductViewComponent } from './Others/product-view/product-view.component';
import { TryNewCodeComponent } from './Others/try-new-code/try-new-code.component';
import { AddressService } from './Shared/address-service';
import { EditBillComponent } from './BillManagement/edit-bill/edit-bill.component';
import { BarRatingModule } from "ngx-bar-rating";
import { ViewUserRatingComponent } from './Others/view-user-rating/view-user-rating.component';
import { AddUserRatingComponent } from './Others/add-user-rating/add-user-rating.component';
import { ViewRecommendedProductComponent } from './Others/view-recommended-product/view-recommended-product.component';
//chart
import { ChartsModule } from 'ng2-charts';
import { StatisticByYearComponent } from './Statistic/StatisticByYear/statistic-by-year/statistic-by-year.component';
import { StatisticByMonthComponent } from './Statistic/StatisticByMonth/statistic-by-month/statistic-by-month.component';
import { StatisticService } from './Shared/statistic-service';
//Social Login
import { SocialLoginModule, AuthServiceConfig,AuthService } from "angularx-social-login";
import { GoogleLoginProvider, FacebookLoginProvider } from "angularx-social-login";
import { ChatDialogComponent } from './chatbot/chat-dialog/chat-dialog.component';
//chat
import { ChatModule } from './chatbot/chat/chat.module';
import { SendEmailComponent } from './accountmanagerment/reset-password/send-email/send-email.component';
import { ConfirmPassComponent } from './accountmanagerment/reset-password/confirm-pass/confirm-pass.component';

export function socialConfigs() {  
  const config = new AuthServiceConfig(  
    [  
      {  
        id: FacebookLoginProvider.PROVIDER_ID,  
        provider: new FacebookLoginProvider('224081915477787')  
      },  
      {  
        id: GoogleLoginProvider.PROVIDER_ID,  
        provider: new GoogleLoginProvider('843816834979-5p804krlg4q47bnf7cfjejr2mljo8jvf.apps.googleusercontent.com')  
      }  
    ]  
  );  
  return config;  
} 
@NgModule({
  declarations: [
    AppComponent,
    AddProductComponent,
    AddcategoryComponent,
    EditcategoryComponent,
    ShowcategoryComponent,
    ViewProductListComponent,
    AddProductToCartComponent,
    ViewProductListForCustomerComponent,
    ViewCartComponent,
    CreateAccountComponent,
    EditAccountComponent,
    AddBillComponent,
    HomepageComponent,
    MessageModalComponent,
    ViewBillDetailComponent,
    ViewBillForCustomerComponent,
    ViewBillForAdminComponent,
    ProductViewComponent,
    TryNewCodeComponent,
    EditBillComponent,
    ViewUserRatingComponent,
    AddUserRatingComponent,
    ViewRecommendedProductComponent,
    StatisticByYearComponent,
    StatisticByMonthComponent,
    SendEmailComponent,
    ConfirmPassComponent,
    
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HttpClientModule,
    FormsModule,
    ReactiveFormsModule,
    NgxPaginationModule,
    BrowserAnimationsModule,
    BarRatingModule,
    ChartsModule,
    SocialLoginModule,
    ChatModule
  ],

  providers: [
    UserService,
    ProductService, 
    CategoryService,
    CartService,
    BillService,
    MessageService,
    AddressService,
    AuthGuard,
    KeyWord,
    StatisticService,
    AuthService,  
    {  
      provide: AuthServiceConfig,  
      useFactory: socialConfigs  
    } 
  ],



  bootstrap: [AppComponent]
})
export class AppModule { }
