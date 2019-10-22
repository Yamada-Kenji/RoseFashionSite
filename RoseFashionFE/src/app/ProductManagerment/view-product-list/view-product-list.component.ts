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
  constructor(private productService: ProductService) { }

  async ngOnInit() {
    await this.GetProductList();
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
