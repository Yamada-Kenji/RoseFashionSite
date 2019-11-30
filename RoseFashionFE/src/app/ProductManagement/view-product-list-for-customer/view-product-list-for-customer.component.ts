import { Component, OnInit } from '@angular/core';
import { ProductModel, CategoryModel } from 'src/app/Shared/model';
import { ProductService } from 'src/app/Shared/product-service';
import { CategoryService } from 'src/app/Shared/category-service';


@Component({
  selector: 'app-view-product-list-for-customer',
  templateUrl: './view-product-list-for-customer.component.html',
  styleUrls: ['./view-product-list-for-customer.component.css']
})
export class ViewProductListForCustomerComponent implements OnInit {

  productlist: ProductModel[] = [];
  categorylist: CategoryModel[] = [];
  pageconfig: any;
  selectedcategory: string = 'all';

  flag: boolean = false;
  showbutton: boolean = false;

  constructor(private productService: ProductService,
    private categoryService: CategoryService) { 
      this.pageconfig = {
        itemsPerPage: 10,
        currentPage: 1
      };
    }

  ngOnInit() {    
    this.GetProductList();
    this.GetAllCategory();

    window.onscroll = function() {
      if (document.body.scrollTop > 100 || document.documentElement.scrollTop > 100) {
        //alert('show');
        this.showbutton = true;
      } else {
        //alert('hide');
        this.showbutton = false;
      }
    }
  }

  topFunction() {
    document.body.scrollTop = 0;
    document.documentElement.scrollTop = 0;
  }

  ToggleSidebar(){
    this.flag = !this.flag;
  }

  pageChanged(event) {
    this.pageconfig.currentPage = event;
  }

  async GetAllCategory(){
    await this.categoryService.GetAllCategory().toPromise().then(result => this.categorylist = result);
  }

  async GetProductList() {
    await this.productService.GetAllProduct().toPromise().then(result => this.productlist = result);
  }

  async GetProductByCategory(categoryid){
    await this.productService.GetProductByCategory(categoryid).toPromise().then(result => this.productlist = result);
  }

  async onSelectCategory(categoryid){
    this.selectedcategory = categoryid;
    if(categoryid == 'all') await this.GetProductList();
    else await this.GetProductByCategory(categoryid);
    this.pageconfig.currentPage = 1;
  }

  GetColor(categoryid){
    if(categoryid == this.selectedcategory) return 'white';
    else return '';
  }
}
