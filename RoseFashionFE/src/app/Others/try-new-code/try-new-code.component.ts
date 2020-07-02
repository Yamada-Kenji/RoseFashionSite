import { Component, OnInit } from '@angular/core';
import { UserService } from 'src/app/Shared/user-service';
import { CartService } from 'src/app/Shared/cart-service';
import { CartModel} from 'src/app/Shared/model';


@Component({
  selector: 'app-try-new-code',
  templateUrl: './try-new-code.component.html',
  styleUrls: ['./try-new-code.component.css']
})
export class TryNewCodeComponent implements OnInit {

  message: any;

  cart: CartModel[] = [];

  jsondata: string = '[]';
  
  totalprice: number = 0;
  url: string = "https://www.youtube.com/watch?v=MsbL8lFHrZI";

  constructor(private userService: UserService, private cartService: CartService){};
  

  ngOnInit() {
    var a = new CartModel();
    a.Name = "hahaha";
    this.cart.push(a);
  }

  RunAlgorithm(){
    this.userService.RunRecommendationAlgorithm().toPromise().then(r=>this.message = r).catch(err => this.message = 'Error');
  }

  CreateJSON(){
    this.cart = this.cartService.ViewProductInCart();
    //alert(this.cart[0].Name);
    var jsonstring = "[";
    for(var i=0;i<this.cart.length;i++){
      this.totalprice += +(this.cart[i].SalePrice*this.cart[i].Amount*0.000043).toFixed(2);
      jsonstring += '{ "name": "' + this.cart[i].Name 
      + '", "unit_amount": { "currency_code": "USD", "value": ' + (this.cart[i].SalePrice*0.000043).toFixed(2)
      + '}, "quantity": '+ this.cart[i].Amount +'},';
    }
    var jsonstr = jsonstring.slice(0, -1);
    jsonstr +="]";
    this.jsondata = jsonstr;
    /*var x = JSON.parse(this.jsondata);
    alert(x);*/
  }

  dosomething(){
    alert('do something');
  }
}
