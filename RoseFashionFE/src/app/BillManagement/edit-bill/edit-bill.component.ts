import { Component, OnInit } from '@angular/core';
import { BillModel, CartModel } from 'src/app/Shared/model';
import { BillService } from 'src/app/Shared/bill-service';
import { CartService } from 'src/app/Shared/cart-service';
import { ActivatedRoute, Router } from '@angular/router';
import { Location } from '@angular/common';
import { ProductService } from 'src/app/Shared/product-service';
//

import pdfMake from 'pdfmake/build/pdfmake';
import pdfFonts from 'pdfmake/build/vfs_fonts';
pdfMake.vfs = pdfFonts.pdfMake.vfs;

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
  disablelist: boolean[] = [false, false, false, false, false];
  statuscode: number = 0;
  notchanged: boolean = true;
  textonly: boolean = false;

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
        this.DisableOption();
        this.cartService.GetItemsInBill(this.billinfo.CartID).toPromise()
          .then(items => this.usedcart = items);
      });
  }

  StatusChanged() {
    if (this.status.indexOf(this.billinfo.Status) != this.statuscode) this.notchanged = false;
  }

  DisableOption() {
    if(this.statuscode==3||this.statuscode==4) {
      this.textonly = true;
      return;
    }
    var i = 0;
    for (i; i <= this.statuscode; i++) {
      this.disablelist[i] = true;
    }
  }

  CalDiscountPercent(saleprice, originalprice) {
    return (originalprice - saleprice) * 100 / originalprice;
  }

  Save() {
    if(!confirm("Xác nhận lưu những thay đổi này?")) return;
    if (this.statuscode == 3) {
      if (this.billinfo.DeliveryDate < this.billinfo.OrderDate) {
        document.getElementById("dldate").style.color = "red";
        return;
      }
      else document.getElementById("dldate").style.color = "black";
    }
    this.billinfo.Status = this.status[this.statuscode];
    this.billService.UpdateBill(this.billinfo).toPromise()
      .then(oldstatus => {
        console.log(this.status.indexOf(oldstatus));
        if (this.statuscode == 0 || this.statuscode == 1 || this.statuscode == 3) {
          alert("Cập nhật thành công.");
          window.location.reload();
          return;
        }
        if (this.statuscode == 2) {
          this.cartService.UpdateProductQuantity("subtract", this.usedcart).toPromise()
            .then(() => { alert("Cập nhật thành công."); window.location.reload(); })
            .catch(err => { alert("Đã có lỗi xảy ra"); window.location.reload(); });
        }
        if (this.statuscode == 4) {
          if (this.status.indexOf(oldstatus) == 2) {
            this.cartService.UpdateProductQuantity("add", this.usedcart).toPromise()
              .then(() => { alert("Cập nhật thành công."); window.location.reload(); })
              .catch(err => { alert("Đã có lỗi xảy ra"); window.location.reload(); });
          }
          else {
            alert("Cập nhật thành công.");
            window.location.reload();
          }
          return;
        }
        // switch(this.statuscode){
        //   case 3: {
        //     this.productService.AddDefaultRating(this.billinfo.CartID)
        //     .toPromise().then().catch(err => console.log(err));
        //     break;
        //   }
        //   case 1: {
        //     this.cartService.UpdateProductQuantity("accept",this.usedcart).toPromise()
        //     .then().catch(err => { confirm("Đã có lỗi xảy ra"); });
        //     break;
        //   }
        //   case 4: {
        //     this.cartService.UpdateProductQuantity("cancel",this.usedcart).toPromise()
        //     .then().catch(err => { confirm("Đã có lỗi xảy ra"); });
        //     break;
        //   }
        //   default: {
        //     this.cartService.UpdateProductQuantity("other",this.usedcart).toPromise()
        //     .then().catch(err => { confirm("Đã có lỗi xảy ra"); });
        //     break;
        //   }
        // }
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
        // alert("Cập nhật thành công.");
      }).catch(err => { alert("Đã có lỗi xảy ra"); window.location.reload(); });
  }

  Cancel() {
    if (confirm('Bạn có muốn hủy toàn bộ thay đổi đã thực hiện tại trang này không?')) {
      this.lc.back();
    }
  }

  Back(){
    this.lc.back();
  }



  AddDefaultRating() {

  }
  //
  generatePdf(){
    this.billService.GetOneBillInfo(this.billid).toPromise()
      .then(result => {
        this.billinfo = result;
        //this.statuscode = this.status.indexOf(this.billinfo.Status);
        this.cartService.GetItemsInBill(this.billinfo.CartID).toPromise()
          .then(items => {this.usedcart = items;
              //
              var bodyData = [];
              var header = ['Tên sản phẩm','Size','Số lượng','Giá'];
              this.usedcart.forEach(function(sourceRow) {
                var dataRow = [];

                dataRow.push(sourceRow.Name);
                dataRow.push(sourceRow.Size);
                dataRow.push(sourceRow.Amount);
                dataRow.push(sourceRow.OriginalPrice);
                bodyData.push(dataRow)
              });
                            //
              const documentDefinition = {  content: [
                {
                  text: 'Hóa đơn',
                  bold: true,
                  fontSize: 20,
                  alignment: 'center',
                  margin: [0, 0, 0, 20]
                },
                {
                  text:'Tên: ' + this.billinfo.ReceiverName,
                 },
                 {
                  text:'Sđt: ' + this.billinfo.ReceiverPhone,
                 },
                 {
                  text:'Địa chỉ: ' + this.billinfo.DeliveryAddress +', '+ this.billinfo.DistrictName + ', '+ this.billinfo.ProvinceName,
                 },
                 {
                
                        table: {
                          headerRows: 1,
                          widths: [ '*', 'auto', 100, '*' ],
                  
                          body: bodyData
                        }
                 },
                 
                 {
                  text:'Tổng tiền: ' + this.billinfo.TotalPrice,
                 },
                
                ],
                
                tyles: {
                  name: {
                    
                    fontSize: 20,
                    bold: true,
                    
                  }
                }
              };
              pdfMake.createPdf(documentDefinition).open();

          });
      });    
    
   }
}
