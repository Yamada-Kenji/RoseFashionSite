import { Component, OnInit } from '@angular/core';
import { CartModel, BillModel, UserModel } from 'src/app/Shared/model';
import { CartService } from 'src/app/Shared/cart-service';
import { BillService } from 'src/app/Shared/bill-service';
import { UserService } from 'src/app/Shared/user-service';


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

  CalTotalPrice() {
    this.totalprice = 0;
    var i = 0;
    while (i < this.mycart.length) {
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

    this.cartService.UpdateCartInDatabase(cartid, items);
    this.cartService.UpdateProductQuantity(items).toPromise()
      .then(() => {
        this.billService.AddBillForMember(billinfo)
          .toPromise().then(result => this.cartService.GetLastUsedCart(this.user.UserID).toPromise()
            .then(result => {
              localStorage.setItem('CartID', result);
              this.cartService.GetItemsInCart(result);
              alert("Hóa đơn đã được lưu.");
            }))
          .catch(err => alert("Lưu hóa đơn thất bại"));
      }).catch(err => alert("Cập nhật số lượng thất bại"));
  }
}
