import { Component, OnInit } from '@angular/core';
import { ProductModel } from 'src/app/Shared/model';
import { ProductService } from 'src/app/Shared/product-service';
import { ActivatedRoute } from '@angular/router';

@Component({
  selector: 'app-view-product-list',
  templateUrl: './view-product-list.component.html',
  styleUrls: ['./view-product-list.component.css']
})
export class ViewProductListComponent implements OnInit {

  productlist: ProductModel[] = [];
  viewlist: ProductModel[] = [];
  pageconfig: any;
  sortcolumn: number = 1;
  asc: boolean = true;
  removelist: string[] = [];
  keyword: string;

  constructor(private productService: ProductService, private route: ActivatedRoute) {
    this.pageconfig = {
      itemsPerPage: 10,
      currentPage: 1
    };
  }

  async ngOnInit() {
    await this.GetProductList();
    this.Search(localStorage.getItem('keyword'));
    this.Sort(this.sortcolumn);
    this.pageconfig.currentPage = localStorage.getItem('currentpage');
  }

  pageChanged(event) {
    this.removelist.splice(0, this.removelist.length);
    this.pageconfig.currentPage = event;
    localStorage.setItem('currentpage', event);
    window.scrollTo(0, 0);
  }

  async GetProductList() {
    await this.productService.GetAllProduct().toPromise().then(result => {this.productlist = result; this.viewlist = result;});
  }

  async DeleteProduct(productid: string) {
    if (confirm('Bạn có chắc chắn muốn xóa sản phẩm này không?')) {
      await this.productService.DeleteProduct(productid).toPromise().then(result => console.log(result));
      this.GetProductList();
    }
  }

  async DeleteMultipleProduct() {
    if (confirm('Bạn có chắc chắn muốn thực hiện thao tác này không?')) {
      await this.productService.DeleteMultipleProducts(this.removelist)
        .toPromise().then(r => console.log(r), err => console.log(err));
      this.GetProductList();
    }
  }

  UpdateRemoveList(productid) {
    var i = this.removelist.indexOf(productid);
    if (i > -1) this.removelist.splice(i, 1);
    else this.removelist.push(productid);
  }
  ChangeSortColumn(col) {
    if (this.sortcolumn == col) {
      this.asc = !this.asc;
    }
    else {
      this.sortcolumn = col;
      this.asc = true;
    }
    this.Sort(col);
  }

  Search(input) {
    localStorage.setItem('keyword', input);
    if (input != '') {
      this.viewlist = this.productlist.filter(p => p.Name.toLowerCase().includes(input) || p.ProductID.toLowerCase().includes(input));
    }
    else {
      this.viewlist = this.productlist;
    }
  }

  Sort(col) {
    console.log(col);
    switch (col) {
      case 1: {
        if (!this.asc) this.productlist.sort((a, b) => (a.ProductID > b.ProductID ? -1 : 1));
        else this.productlist.sort((a, b) => (b.ProductID > a.ProductID ? -1 : 1));
        break;
      }
      case 2: {
        if (!this.asc) this.productlist.sort((a, b) => (a.Name > b.Name ? -1 : 1));
        else this.productlist.sort((a, b) => (b.Name > a.Name ? -1 : 1));
        break;
      }
      case 3: {
        if (!this.asc) this.productlist.sort((a, b) => (a.Quantity[0] > b.Quantity[0] ? -1 : 1));
        else this.productlist.sort((a, b) => (b.Quantity[0] > a.Quantity[0] ? -1 : 1));
        break;
      }
      case 4: {
        if (!this.asc) this.productlist.sort((a, b) => (a.Price > b.Price ? -1 : 1));
        else this.productlist.sort((a, b) => (b.Price > a.Price ? -1 : 1));
        break;
      }
      default: {
        if (!this.asc) this.productlist.sort((a, b) => (a.Name > b.Name ? -1 : 1));
        else this.productlist.sort((a, b) => (b.Name > a.Name ? -1 : 1));
        break;
      }
    }
  }
}
