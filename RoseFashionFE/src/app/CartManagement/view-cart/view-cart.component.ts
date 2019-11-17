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
  selectedid: string;
  totalprice: number = 0;
  pageconfig: any;
  constructor(private cartService: CartService) { 
    this.pageconfig = {
      itemsPerPage: 3,
      currentPage: 1
    };
  }

  ngOnInit() {
    this.mycart = this.cartService.ViewProductInCart();
    if(this.mycart==undefined) this.mycart = [];
    this.CalTotalPrice();
  }

  pageChanged(event) {
    this.pageconfig.currentPage = event;
  }

  CalTotalPrice(){
    this.totalprice = 0;
    var i=0;
    while(i<this.mycart.length){
      this.totalprice += this.mycart[i].Price * this.mycart[i].Amount;
      i++;
    }
  }

  UpdateItemAmount(productid, amount){
    this.cartService.UpdateItemAmount(productid, amount);
    this.CalTotalPrice();
  }

  SelectItem(producid, amount){
    this.selectedid = producid;
  }

  RemoveItem(){
    this.cartService.DeleteItem(this.selectedid);
    const index = this.mycart.indexOf(this.mycart.find(item => item.ProductID == this.selectedid));
    this.mycart.splice(index, 1);
    this.CalTotalPrice();
  }
}
