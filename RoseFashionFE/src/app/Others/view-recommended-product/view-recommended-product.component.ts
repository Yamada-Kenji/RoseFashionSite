import { Component, OnInit } from '@angular/core';
import { UserService } from 'src/app/Shared/user-service';
import { ProductModel } from 'src/app/Shared/model';
import { ProductService } from 'src/app/Shared/product-service';

@Component({
  selector: 'app-view-recommended-product',
  templateUrl: './view-recommended-product.component.html',
  styleUrls: ['./view-recommended-product.component.css']
})
export class ViewRecommendedProductComponent implements OnInit {

  productlist: ProductModel[] = [];
  list1: ProductModel[] = [];
  list2: ProductModel[] = [];
  firstproduct: ProductModel;

  show: boolean = false;

  constructor(private userService: UserService,
    private productService: ProductService) { }

  ngOnInit() {
    var user = this.userService.getCurrentUser();
    if (user.Role == 'user') {
      //this.productService.GetRecommendedProduct(user.UserID).toPromise().then(r => this.productlist = r);
      this.productService.GetRecommendedProduct(this.userService.getCurrentUser().UserID).toPromise().then(r => {
        this.productlist = r;
        var templist: ProductModel[] = [];
        this.productlist.forEach(p => templist.push(p))
        this.list1 = templist.splice(0, 4);
        this.list2 = templist.splice(0, 4);
        this.firstproduct = this.productlist[0];
        this.productlist.splice(0, 1);
        this.show = true;
        /*console.log(this.productlist);
        console.log(this.firstproduct);*/
      });
    }
  }

}
