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

  product: ProductModel = {ProductID:'', Name:'', Color:'#000000', Size:[]=['S','M','L','XL','XXL'], CategoryID:'', Description:'', Quantity:[]=[0,0,0,0,0], Image:'', Price:0};
  categorylist: CategoryModel[] = [];
  selectedmaincategory: string="";
  selectedsize: string;
  sizes = [
    {name:'S', quantity: 0, checked:false},
    {name:'M', quantity: 0, checked:false},
    {name:'L', quantity: 0, checked:false},
    {name:'XL', quantity: 0, checked:false},
    {name:'XXL', quantity: 0, checked:false}
  ]

  constructor(
    private productService: ProductService,
    private categoryService: CategoryService,
    private cartService: CartService,
    private route: ActivatedRoute,
    private location: Location) { }

  ngOnInit() {
    this.product = {ProductID:'', Name:'', Color:'#000000', Size:[]=['S','M','L','XL','XXL'], CategoryID:'', Description:'', Quantity:[]=[0,0,0,0,0], Image:'', Price:0};
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
