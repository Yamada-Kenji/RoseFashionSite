import { Component, OnInit } from '@angular/core';
import { ProductModel, CategoryModel } from 'src/app/model';
import { ProductService, CategoryService, CartService } from 'src/app/services';
import { ActivatedRoute } from '@angular/router';
import { Location } from '@angular/common';

@Component({
  selector: 'app-add-product-to-cart',
  templateUrl: './add-product-to-cart.component.html',
  styleUrls: ['./add-product-to-cart.component.css']
})
export class AddProductToCartComponent implements OnInit {

  product: ProductModel;
  selectedsize: string;


  constructor(
    private productService: ProductService,
    private cartService: CartService,
    private route: ActivatedRoute) { }

  ngOnInit() {
    var productid = this.route.snapshot.paramMap.get('productid');
    this.productService.GetProductDetail(productid).toPromise().then(p => {this.product = p;console.log(this.product);});
  }

  AddToCart(amount: number){
    this.cartService.AddToCart(this.product.ProductID, this.selectedsize, amount);
  }

  OnSizeChange(size){
    this.selectedsize = size;
  }
}
