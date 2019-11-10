import { Component, OnInit } from '@angular/core';
import { CartModel } from 'src/app/model';
import { CartService } from 'src/app/services';

@Component({
  selector: 'app-add-bill',
  templateUrl: './add-bill.component.html',
  styleUrls: ['./add-bill.component.css']
})
export class AddBillComponent implements OnInit {

  mycart: CartModel[] = [];

  constructor(private cartService: CartService) { }

  ngOnInit() {
    this.mycart = this.cartService.ViewProductInCart();
  }
  
}
