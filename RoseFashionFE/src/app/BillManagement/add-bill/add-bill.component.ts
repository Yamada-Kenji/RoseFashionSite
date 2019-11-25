import { Component, OnInit } from '@angular/core';
import { CartModel, BillModel, UserModel } from 'src/app/model';
import { CartService, BillService, UserService } from 'src/app/services';

@Component({
  selector: 'app-add-bill',
  templateUrl: './add-bill.component.html',
  styleUrls: ['./add-bill.component.css']
})
export class AddBillComponent implements OnInit {

  user: UserModel = new UserModel();
  mycart: CartModel[] = [];
  totalprice: number = 0;

  constructor(private cartService: CartService,
    private billService: BillService,
    private userService: UserService) { }

  ngOnInit() {
    this.mycart = this.cartService.ViewProductInCart();
    this.user = this.userService.getCurrentUser();
    this.CalTotalPrice();
  }

  CalTotalPrice(){
    this.totalprice = 0;
    var i=0;
    while(i<this.mycart.length){
      this.totalprice += this.mycart[i].SalePrice * this.mycart[i].Amount;
      i++;
    }
  }

  AddBill(name, phone, address, discountcode) {
    var items: CartModel[] = JSON.parse(localStorage.getItem('MyCart'));
    var cartid = localStorage.getItem('CartID');
    var billinfo: BillModel = {
      BillID: '',
      CartID: cartid,
      OrderDate: null,
      ReceiverName: name,
      ReceiverPhone: phone,
      DeliveryAddress: address,
      DiscountCode: discountcode,
      TotalPrice: this.totalprice
    };
    if (this.user.Role == 'guest') {
      this.billService.AddBillForGuest(items, billinfo, this.user.UserID)
      .toPromise().then(result => alert(result))
      .catch(err => alert(err));
    }
    else {
      this.cartService.UpdateCartInDatabase(cartid, items);
      this.billService.AddBillForMember(billinfo)
      .toPromise().then(result => alert(result))
      .catch(err => alert(err));
    }
  }
}
