import { Component, HostListener } from '@angular/core';
import { UserModel, CartModel } from 'src/app/Shared/model';
import { UserService } from './Shared/user-service';
import { CartService } from './Shared/cart-service';




@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {

  loginmessage: string;
  currentUser: UserModel = new UserModel();
  returnUrl: string;

  email: string;
  islogon: boolean;
  showMessage: string;
  role: string;
  text: string;
  itemsincart: number = 0;

  @HostListener('window:beforeunload', ['$event'])
  beforeUnloadHander(event) {
    var cartid = localStorage.getItem('CartID');
    var items: CartModel[] = JSON.parse(localStorage.getItem('MyCart'));
    if(cartid){
      this.cartService.UpdateCartInDatabase(cartid, items)
      .toPromise().then(result => console.log(result))
      .catch(err => console.log(err));
    }
  }

  constructor(
    private userservice: UserService,
    private cartService: CartService) { }

  ngOnInit() {
    this.getCurrentUser();
  }

  UpdateCartQuantity() {
    return this.cartService.GetCartLenght();
  }

  getCurrentUser() {
    var temp = this.userservice.getCurrentUser();
    if (temp) {
      this.currentUser = temp;
      if(this.currentUser.Role == 'guest') this.islogon = false;
      else {
        this.islogon = true;
      }
    }
    else {
      this.islogon = false;
      this.userservice.CreateGuestID().toPromise()
        .then(email => {
          this.userservice.GetAccountByEmail(email)
            .toPromise().then(result => {
              localStorage.setItem('currentGuest', JSON.stringify(result));
              this.currentUser = result;
            })
        });
    }
    this.cartService.GetLastUsedCart(this.currentUser.UserID).toPromise()
      .then(result => {
        localStorage.setItem('CartID', result);
        this.cartService.GetItemsInCart(result);
      });
    // if (temp) {
    //   this.currentUser = temp;
    //   if(this.currentUser.Role!='guest'){
    //     this.islogon = true;
    //     this.cartService.GetLastUsedCart(this.currentUser.UserID).toPromise()
    //     .then(result => 
    //       {
    //         localStorage.setItem('CartID', result);
    //         this.cartService.GetItemsInCart(result);
    //       });
    //   }
    //   else this.islogon = false;
    // }
    // else {
    //   this.islogon = false;
    //   this.userservice.CreateGuestID().toPromise()
    //     .then(email => {
    //       this.userservice.GetAccountByEmail(email)
    //       .toPromise().then(result => {
    //         localStorage.setItem('currentGuest', JSON.stringify(result));
    //         this.currentUser = result;
    //       })
    //     });
    // }
  }

  async login(email: string, password: string) {

    this.loginmessage = null;

    this.currentUser = await this.userservice.login(email, password).toPromise().then(data => this.currentUser = data, error => this.loginmessage = error);
    if (this.loginmessage != null) {
      this.loginmessage = 'Wrong username or password!';
    } else {

      this.loginmessage = 'Login successfully!';
    }
    this.getCurrentUser();
  }

  logout() {
    this.userservice.logout();
    this.getCurrentUser();
  }
}