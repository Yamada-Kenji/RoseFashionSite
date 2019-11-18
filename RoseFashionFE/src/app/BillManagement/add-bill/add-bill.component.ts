import { Component, OnInit } from '@angular/core';
import { CartModel } from 'src/app/model';
import { CartService, BillService, UserService } from 'src/app/services';

@Component({
  selector: 'app-add-bill',
  templateUrl: './add-bill.component.html',
  styleUrls: ['./add-bill.component.css']
})
export class AddBillComponent implements OnInit {

  mycart: CartModel[] = [];

  constructor(private cartService: CartService,
    private billService: BillService,
    private userService: UserService) { }

  ngOnInit() {
    this.mycart = this.cartService.ViewProductInCart();
  }
  
  AddBill(){
    var userid = this.userService.GetCurrentUser();
    console.log(userid);
    this.billService.AddBill(this.mycart, userid).toPromise();
  }
}
