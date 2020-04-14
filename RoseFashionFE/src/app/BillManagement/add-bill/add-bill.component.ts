import { Component, OnInit } from '@angular/core';
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
  warning: boolean = false;
  provincelist: ProvinceModel[] = [];
  districtlist: DistrictModel[] = [];

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
  }

  onProvinceChange(){
    //console.log(this.billinfo.ProvinceID);
    var result = this.provincelist.find(r => r.ProvinceName == this.billinfo.ProvinceName);
    if(result){
      this.billinfo.DeliveryFee = this.provincelist.find(r => r.ProvinceID == result.ProvinceID).DeliveryFee;
    }
    else{
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
    var items: CartModel[] = JSON.parse(localStorage.getItem('MyCart'));
    var cartid = localStorage.getItem('CartID');
    this.billinfo.CartID = cartid;
    this.billinfo.ReceiverName = name;
    this.billinfo.ReceiverPhone = phone;
    this.billinfo.DeliveryAddress = address;
    this.billinfo.DiscountCode = discountcode;
    this.billinfo.TotalPrice = this.totalprice;
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
              var message: MessageModel = { Title: "Thông báo", Content: "Hóa đơn đã được lưu.", BackToHome: true };
              this.messageService.SendMessage(message);
            }))
          .catch(err => {
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

  Back() {
    this.location.back();
  }
}
