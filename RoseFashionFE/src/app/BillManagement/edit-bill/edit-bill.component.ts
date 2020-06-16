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
  status: string[] = ["Đang chờ xác nhận", "Đã xác nhận", "Đang giao hàng", "Đã thanh toán", "Đã hủy"];
  statuscode: number = 0;
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
        this.billinfo.DeliveryDate = new Date();
        this.statuscode = this.status.indexOf(this.billinfo.Status);
        this.cartService.GetItemsInBill(this.billinfo.CartID).toPromise()
          .then(items => this.usedcart = items);
      });      
  }

  CalDiscountPercent(saleprice, originalprice) {
    return (originalprice - saleprice) * 100 / originalprice;
  }

  Save() {
    if (this.statuscode == 3) {
      if (this.billinfo.DeliveryDate < this.billinfo.OrderDate) {
        document.getElementById("dldate").style.color = "red";
        return;
      }
      else document.getElementById("dldate").style.color = "black";
    }
    this.billinfo.Status = this.status[this.statuscode];
    this.billService.UpdateBill(this.billinfo).toPromise()
      .then(() => {
        switch(this.statuscode){
          case 3: {
            this.productService.AddDefaultRating(this.billinfo.CartID)
            .toPromise().then().catch(err => console.log(err));
            break;
          }
          case 1: {
            this.cartService.UpdateProductQuantity("accept",this.usedcart).toPromise()
            .then().catch(err => { confirm("Đã có lỗi xảy ra"); });
            break;
          }
          case 4: {
            this.cartService.UpdateProductQuantity("cancel",this.usedcart).toPromise()
            .then().catch(err => { confirm("Đã có lỗi xảy ra"); });
            break;
          }
          default: {
            this.cartService.UpdateProductQuantity("other",this.usedcart).toPromise()
            .then().catch(err => { confirm("Đã có lỗi xảy ra"); });
            break;
          }
        }
        /*if (this.billinfo.Status == "Đã thanh toán") {
          alert('da thanh toan');
          this.productService.AddDefaultRating(this.billinfo.CartID)
            .toPromise().then().catch(err => console.log(err));
        }
        if (this.billinfo.Status == "Đã xác nhận") {
          alert('da xac nhan');
          this.cartService.UpdateProductQuantity("accept",this.usedcart).toPromise()
            .then().catch(err => { confirm("Đã có lỗi xảy ra"); });
        }
        if (this.billinfo.Status == "Đã hủy") {
          alert('da huy');
          this.cartService.UpdateProductQuantity("cancel",this.usedcart).toPromise()
            .then().catch(err => { confirm("Đã có lỗi xảy ra"); });
        }*/
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
