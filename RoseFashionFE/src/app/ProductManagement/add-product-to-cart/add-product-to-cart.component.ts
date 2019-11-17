import { Component, OnInit } from '@angular/core';
import { ProductModel, CategoryModel } from 'src/app/model';
import { ProductService, CategoryService, CartService } from 'src/app/services';
import { ActivatedRoute } from '@angular/router';
import { Location } from '@angular/common';
import { max } from 'rxjs/operators';

@Component({
  selector: 'app-add-product-to-cart',
  templateUrl: './add-product-to-cart.component.html',
  styleUrls: ['./add-product-to-cart.component.css']
})
export class AddProductToCartComponent implements OnInit {

  product: ProductModel = {ProductID:'', Name:'', Color:'#000000', Size:[]=['S','M','L','XL','XXL'], CategoryID:'', Description:'', Quantity:[]=[0,0,0,0,0], Image:'', Price:0};
  selectedsize: string;
  maxamount: number;

  constructor(
    private productService: ProductService,
    private cartService: CartService,
    private route: ActivatedRoute) { }

  ngOnInit() {
    var productid = this.route.snapshot.paramMap.get('productid');
    this.productService.GetProductDetail(productid).toPromise().then(p => this.product = p);
  }

  AddToCart(amount: number){
    this.cartService.AddToCart(this.product.ProductID, this.product.Image, this.product.Name, this.selectedsize, amount, this.maxamount, this.product.Price);
  }

  OnSizeChange(size, index: number){
    this.selectedsize = size;
    this.maxamount = this.product.Quantity[index];
    console.log(this.maxamount);
  }
}
