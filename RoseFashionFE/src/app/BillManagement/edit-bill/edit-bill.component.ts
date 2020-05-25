import { Component, OnInit } from '@angular/core';
import { BillModel, CartModel } from 'src/app/Shared/model';
import { BillService } from 'src/app/Shared/bill-service';
import { CartService } from 'src/app/Shared/cart-service';
import { ActivatedRoute, Router } from '@angular/router';
import { Location } from '@angular/common';
import { ProductService } from 'src/app/Shared/product-service';

@Component({
  selector: 'app-edit-bill',
  templateUrl: './edit-bill.component.html',
  styleUrls: ['./edit-bill.component.css']
})
export class EditBillComponent implements OnInit {

  billinfo: BillModel = new BillModel();
  usedcart: CartModel[] = [];
  billid: string;
  constructor(private billService: BillService,
    private cartService: CartService,
    private productService: ProductService,
    private route: ActivatedRoute,
    private router: Router,
    private lc: Location) { }

  ngOnInit() {
    this.billid = this.route.snapshot.paramMap.get('billid');
    this.billService.GetOneBillInfo(this.billid).toPromise()
      .then(result => {
        this.billinfo = result;
        this.cartService.GetItemsInBill(this.billinfo.CartID).toPromise()
          .then(items => this.usedcart = items);
      });
  }

  CalDiscountPercent(saleprice, originalprice) {
    return (originalprice - saleprice) * 100 / originalprice;
  }

  Save() {
    if (this.billinfo.Status == "Đã thanh toán") {
      if (this.billinfo.DeliveryDate < this.billinfo.OrderDate) {
        document.getElementById("dldate").style.color = "red";
        return;
      }
    }
    document.getElementById("dldate").style.color = "black";
    this.billService.UpdateBill(this.billinfo).toPromise()
      .then(() => {
        if (this.billinfo.Status == "Đã thanh toán") {
          this.productService.AddDefaultRating(this.billinfo.CartID)
            .toPromise().then().catch(err => console.log(err));
        }
        if (this.billinfo.Status == "Đã xác nhận") {
          this.cartService.UpdateProductQuantity("accept",this.usedcart).toPromise()
            .then().catch(err => { confirm("Đã có lỗi xảy ra"); });
        }
        if (this.billinfo.Status == "Đã hủy") {
          this.cartService.UpdateProductQuantity("cancel",this.usedcart).toPromise()
            .then().catch(err => { confirm("Đã có lỗi xảy ra"); });
        }
        alert("Cập nhật thành công.");
      }).catch(err => console.log(err));
  }

  Cancel() {
    if (confirm('Bạn có muốn hủy toàn bộ thay đổi đã thực hiện tại trang này không?')) {
      this.lc.back();
    }
  }

  AddDefaultRating() {

  }
}
