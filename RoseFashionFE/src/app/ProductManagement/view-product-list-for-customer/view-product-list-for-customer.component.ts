import { Component, OnInit } from '@angular/core';
import { ProductModel, CategoryModel } from 'src/app/model';
import { ProductService, CategoryService } from 'src/app/services';
import { AddProductToCartComponent } from '../add-product-to-cart/add-product-to-cart.component';

@Component({
  selector: 'app-view-product-list-for-customer',
  templateUrl: './view-product-list-for-customer.component.html',
  styleUrls: ['./view-product-list-for-customer.component.css']
})
export class ViewProductListForCustomerComponent implements OnInit {

  productlist: ProductModel[] = [];
  categorylist: CategoryModel[] = [];
  pageconfig: any;
  recol: number;
  
  constructor(private productService: ProductService,
    private categoryService: CategoryService) { 
      this.pageconfig = {
        itemsPerPage: 4,
        currentPage: 1
      };
    }

  ngOnInit() {
    this.GetProductList();
    this.GetAllCategory();
    this.recol = (window.innerWidth <= 420) ? 2 : 3;
  }

  onResize(event) {
    this.recol = (event.target.innerWidth <= 420) ? 2 : 3;
  }

  pageChanged(event) {
    this.pageconfig.currentPage = event;
  }

  async GetAllCategory(){
    await this.categoryService.GetAllCategory().toPromise().then(result => this.categorylist = result);
  }

  async GetProductList() {
    await this.productService.GetProductListForAdmin().toPromise().then(result => this.productlist = result);
  }

  async DeleteProduct(productid: string) {
    if (confirm('Bạn có chắc chắn muốn xóa sản phẩm này không?')) {
      await this.productService.DeleteProduct(productid).toPromise().then(result => console.log(result));
      this.GetProductList();
    }
  }
}
