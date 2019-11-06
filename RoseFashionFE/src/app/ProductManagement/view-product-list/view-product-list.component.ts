import { Component, OnInit } from '@angular/core';
import { ProductService } from 'src/app/services';
import { ProductModel } from 'src/app/model';

@Component({
  selector: 'app-view-product-list',
  templateUrl: './view-product-list.component.html',
  styleUrls: ['./view-product-list.component.css']
})
export class ViewProductListComponent implements OnInit {

  productlist: ProductModel[] = [];
  pageconfig: any;

  constructor(private productService: ProductService) {
    this.pageconfig = {
      itemsPerPage: 3,
      currentPage: 1
    };
  }

  async ngOnInit() {
    await this.GetProductList();
  }

  pageChanged(event) {
    this.pageconfig.currentPage = event;
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
