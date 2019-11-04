import { Component, OnInit } from '@angular/core';
import { CartService } from 'src/app/services';
import { CartModel } from 'src/app/model';

@Component({
  selector: 'app-view-cart',
  templateUrl: './view-cart.component.html',
  styleUrls: ['./view-cart.component.css']
})
export class ViewCartComponent implements OnInit {

  mycart: CartModel[] = [];

  constructor(private cartService: CartService) { }

  ngOnInit() {
    this.mycart = this.cartService.ViewProductInCart();
  }


}
