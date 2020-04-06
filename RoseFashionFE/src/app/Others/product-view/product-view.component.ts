import { Component, OnInit, Input } from '@angular/core';
import { ProductService } from 'src/app/Shared/product-service';
import { ProductModel } from 'src/app/Shared/model';

@Component({
  selector: 'app-product-view',
  templateUrl: './product-view.component.html',
  styleUrls: ['./product-view.component.css']
})
export class ProductViewComponent implements OnInit {
  @Input() id: string;

  item: ProductModel;
  constructor(private productService: ProductService) { }

  ngOnInit() {
    this.productService.GetProductDetail(this.id).toPromise()
      .then(result => this.item = result);
  }

}
