import { Component, OnInit, SystemJsNgModuleLoader } from '@angular/core';
import { CartModel, BillModel, UserModel, MessageModel, ProvinceModel, DistrictModel } from 'src/app/Shared/model';
import { CartService } from 'src/app/Shared/cart-service';
import { BillService } from 'src/app/Shared/bill-service';
import { UserService } from 'src/app/Shared/user-service';
import { Location } from '@angular/common';
import { MessageService } from 'src/app/Shared/message-service';
import { AddressService } from 'src/app/Shared/address-service';


@Component({
  selector: 'app-add-bill',
  templateUrl: './add-bill.component.html',
  styleUrls: ['./add-bill.component.css']
})
export class AddBillComponent implements OnInit {

  billinfo: BillModel = new BillModel();
  user: UserModel = new UserModel();
  mycart: CartModel[] = [];
  totalprice: number = 0;
  totalpriceUSD: string = "0";
  warning: boolean = false;
  provincelist: ProvinceModel[] = [];
  districtlist: DistrictModel[] = [];
  creditcard: boolean = false;
  loading: boolean = false;

  jsonstring: string;


  constructor(private cartService: CartService,
    private billService: BillService,
    private userService: UserService,
    private addressService: AddressService,
    private messageService: MessageService,
    private location: Location) { }

  ngOnInit() {
    this.mycart = this.cartService.ViewProductInCart();
    this.user = this.userService.getCurrentUser();
    this.addressService.GetProvince().toPromise().then(r => this.provincelist = r);
    if (this.user.Role == 'guest') {
      this.user.FullName = '';
      this.user.Email = '';
    }
    this.CalTotalPrice();
    this.LoadPayPalScript();
    this.LoadAddress();
  }

  LoadAddress(){
    this.userService.GetAccountByID(this.user.UserID).toPromise().then(r => 
      {
        this.user = r;
        if(r.Province!=null) {
          this.billinfo.ProvinceName = r.Province;
          this.onProvinceChange();
          this.billinfo.DistrictName = r.District;
        }
    });
  }

  onProvinceChange() {
    //console.log(this.billinfo.ProvinceID);
    var result = this.provincelist.find(r => r.ProvinceName == this.billinfo.ProvinceName);
    if (result) {
      this.billinfo.DeliveryFee = this.provincelist.find(r => r.ProvinceID == result.ProvinceID).DeliveryFee;
    }
    else {
      this.billinfo.DeliveryFee = 0;
    }
    //console.log(this.provincelist.find(r => r.ProvinceID == this.billinfo.ProvinceID).DeliveryFee);

    this.addressService.GetDistrict(result.ProvinceID).toPromise().then(r => this.districtlist = r);
    this.billinfo.DistrictName = '';
  }

  CalTotalPrice() {
    this.totalprice = 0;
    var i = 0;
    while (i < this.mycart.length) {
      this.totalprice += this.mycart[i].SalePrice * this.mycart[i].Amount;
      i++;
    }
  }

  CheckDiscount(originalprice: number, saleprice: number) {
    if (originalprice > saleprice) return true;
    return false;
  }

  AddBill(name, phone, address, discountcode) {
    if (name == '' || phone == '' || address == '' || this.billinfo.ProvinceName == '' || this.billinfo.DistrictName == '') {
      this.warning = true;
      return;
    }
    this.loading = true;
    var items: CartModel[] = JSON.parse(localStorage.getItem('MyCart'));
    var cartid = localStorage.getItem('CartID');
    this.billinfo.CartID = cartid;
    this.billinfo.ReceiverName = name;
    this.billinfo.ReceiverPhone = phone;
    this.billinfo.DeliveryAddress = address;
    this.billinfo.DiscountCode = discountcode;
    this.billinfo.TotalPrice = this.totalprice;
    this.billinfo.PaymentMethod = "Tiền mặt";
    if (this.creditcard == true) {
      this.billinfo.PaymentMethod = "Thẻ tín dụng";
    }
    // var billinfo: BillModel = {
    //   BillID: '',
    //   CartID: cartid,
    //   OrderDate: null,
    //   ReceiverName: name,
    //   ReceiverPhone: phone,
    //   DeliveryAddress: address,
    //   DiscountCode: discountcode,
    //   TotalPrice: this.totalprice
    // };

    this.cartService.UpdateCartInDatabase(cartid, items);
    // this.cartService.UpdateProductQuantity(items).toPromise()
    //   .then(() => {
    this.billService.AddBillForMember(this.billinfo)
      .toPromise().then(result => this.cartService.GetLastUsedCart(this.user.UserID).toPromise()
        .then(result => {
          localStorage.setItem('CartID', result);
          this.cartService.GetItemsInCart(result);
          /*this.userService.RunRecommendationAlgorithm().toPromise()
          .then(r => {
            alert(r);*/
            this.loading = false;
            var message: MessageModel = { Title: "Thông báo", Content: "Hóa đơn đã được lưu.", BackToHome: true };
            this.messageService.SendMessage(message);
          //});
        }))
      .catch(err => {
        this.loading = false;
        console.log("Lưu hóa đơn thất bại");
        var message: MessageModel = { Title: "Thông báo", Content: "Đã có lỗi xảy ra. Vui lòng thử lại sau.", BackToHome: false };
        this.messageService.SendMessage(message);
      });
    // }).catch(err => {
    //   console.log("Cập nhật số lượng thất bại");
    //   var message: MessageModel = { Title: "Thông báo", Content: "Đã có lỗi xảy ra. Vui lòng thử lại sau." };
    //   this.messageService.SendMessage(message);
    // });
  }

  ShowPaypalButton() {
    var paypalbtn = document.getElementById("paypal-button-container") as HTMLElement;
    paypalbtn.hidden = false;
    //paypalbtn.style.display = 'block';
  }

  CashPayment() {
    var normalbtn = document.getElementById("order") as HTMLElement;
    var paypalbtn = document.getElementById("paypal-button-container") as HTMLElement;
    paypalbtn.hidden = true;
    normalbtn.hidden = false;
    this.creditcard = false;
  }

  OnlinePayment() {
    this.DataToJSON();
    this.creditcard = true;
    var normalbtn = document.getElementById("order") as HTMLElement;
    normalbtn.hidden = true;
  }

  Back() {
    this.location.back();
  }

  LoadPayPalScript() {
    var x = document.getElementById("reloadscript") as HTMLElement;
    x.click();
    //alert(stringify(script));
  }

  DataToJSON() {
    this.VNDtoUSD();
    var amount_data = {
      currency_code: "USD",
      value:  (Number.parseFloat(this.totalpriceUSD) + Number.parseFloat((this.billinfo.DeliveryFee * 0.000043).toFixed(2))).toString(),//((this.totalprice + this.billinfo.DeliveryFee) * 0.000043).toFixed(2),
      breakdown: {
        item_total: {
          currency_code: "USD",
          value: this.totalpriceUSD //(this.totalprice * 0.000043).toFixed(2)
        },
        shipping: {
          currency_code: "USD",
          value: (this.billinfo.DeliveryFee * 0.000043).toFixed(2)
        },
      }
    };
    
    var items_data = [];
    for (var i = 0; i < this.mycart.length; i++) {
      var item = {
        name: this.mycart[i].Name,
        description: "Size: " + this.mycart[i].Size,
        unit_amount: {
          currency_code: "USD",
          value: (this.mycart[i].SalePrice * 0.000043).toFixed(2)
        },
        quantity: this.mycart[i].Amount
      }
      items_data.push(item);
    }
    
    var temp = {
      amount: amount_data,
      items: items_data
    };

    var purchase_unit_data = [];
    purchase_unit_data.push(temp);

    this.jsonstring = JSON.stringify(purchase_unit_data);
    //console.log(JSON.parse(this.jsonstring));
    //this.VNDtoUSD();
    //alert(this.totalpriceUSD);
  }

  VNDtoUSD(){
    var total: number = 0;
    for (var i = 0; i < this.mycart.length; i++) {
      total += Number.parseFloat((this.mycart[i].SalePrice * 0.000043).toFixed(2)) * this.mycart[i].Amount;
    }
    this.totalpriceUSD = total.toString();
  }
}
