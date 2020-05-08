import { Component, OnInit } from '@angular/core';
import { ProductModel } from 'src/app/Shared/model';
import { ProductService } from 'src/app/Shared/product-service';

@Component({
  selector: 'app-homepage',
  templateUrl: './homepage.component.html',
  styleUrls: ['./homepage.component.css']
})
export class HomepageComponent implements OnInit {

  pageconfig: any;

  productlist: ProductModel[] = [];
  constructor(private productService: ProductService) { 
    this.pageconfig = {
      itemsPerPage: 2,
      currentPage: 1
    };
  }

  ngOnInit() {
    this.ResetLocalStorage();
    this.productService.GetTopSales().toPromise().then(result => this.productlist = result);
  }

  pageChanged(event) {
    this.pageconfig.currentPage = event;
  }

  ResetLocalStorage(){
    localStorage.setItem('category', 'all');
    localStorage.setItem('keyword', '');
  }

}
