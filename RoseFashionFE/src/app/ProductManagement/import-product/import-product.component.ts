import { Component, OnInit } from '@angular/core';
import { ProductService } from 'src/app/Shared/product-service';
import { ProductModel } from 'src/app/Shared/model';

@Component({
  selector: 'app-import-product',
  templateUrl: './import-product.component.html',
  styleUrls: ['./import-product.component.css']
})
export class ImportProductComponent implements OnInit {

  product: ProductModel = new ProductModel();
  productid: string;
  newquantity: number[] = [0, 0, 0, 0, 0];

  constructor(private productService: ProductService) { }

  ngOnInit() {
  }

  Search() {
    this.productService.GetProductDetail(this.productid)
      .toPromise().then(r => this.product = r).catch(err => alert('Không tìm thấy sản phẩm này.'))
  }

  UpdateQuantity() {
    var i = 0;
    for (i; i < this.newquantity.length; i++) {
      this.product.Quantity[i] += this.newquantity[i];
    }
    this.productService.UpdateProduct(this.product)
      .toPromise().then().catch(err => { alert('Đã có lỗi xảy ra.'); this.Search(); })
  }
}
