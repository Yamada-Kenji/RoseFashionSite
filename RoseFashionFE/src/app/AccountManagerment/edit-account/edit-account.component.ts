import { Component, OnInit } from '@angular/core';
import { UserModel, MessageModel,ProvinceModel,DistrictModel } from 'src/app/Shared/model';
import { Location } from '@angular/common';
import { ActivatedRoute } from '@angular/router';
import { UserService } from 'src/app/Shared/user-service';
import { MessageService } from 'src/app/Shared/message-service';
import { AddressService } from 'src/app/Shared/address-service';


@Component({
  selector: 'app-edit-account',
  templateUrl: './edit-account.component.html',
  styleUrls: ['./edit-account.component.css']
})
export class EditAccountComponent implements OnInit {

  user: UserModel = new UserModel();
  users: UserModel[];
  idUser: string;
  validphone: boolean = true;
  provincelist: ProvinceModel[] = [];
  districtlist: DistrictModel[] = [];

  constructor(private userService: UserService,  private location: Location,
    private messageService: MessageService, private addressService: AddressService) { }

   ngOnInit() {
    this.user.Province="";  
    var x = this.userService.getCurrentUser();
    this.addressService.GetProvince().toPromise().then(r => this.provincelist = r);
    this.idUser=x.UserID;
    this.getAccountByEmail();
    //this.onProvinceChange();

  }

  getAccountByEmail(): void {
    this.userService.GetAccountByID(this.idUser).toPromise().then(user => {this.user = user;this.onProvinceChange();});
 
  }
  onProvinceChange(){
    //console.log(this.billinfo.ProvinceID);
    var result = this.provincelist.find(r => r.ProvinceName == this.user.Province);
    this.addressService.GetDistrict(result.ProvinceID).toPromise().then(r => this.districtlist = r);
  }
  save(): void {
    console.log(this.user);
      this.userService.UpdateAccount(this.user).toPromise()
      .then(result =>{
        var msg: MessageModel = {Title:"Thông báo", Content: "Cập nhật thông tin thành công.", BackToHome: false};
        this.messageService.SendMessage(msg);
      }).catch(err =>{
        var msg: MessageModel = {Title:"Thông báo", Content: "Đã có lỗi xảy ra.", BackToHome: false};
        this.messageService.SendMessage(msg);
      });
    }
  goBack(): void {
      this.location.back();
    }
  
  CheckingPhoneNumber(){
    if(this.user.Phone=='') return;
    var regex = ['0','1','2','3','4','5','6','7','8','9'];
    if(this.user.Phone.length!=10){
      this.validphone = false;
    }
    else
    { 
      for(var i=0;i<10;i++){
        if(!regex.indexOf(this.user.Phone[i])) {
          this.validphone = false;
          break;
        }
      }
      this.validphone = true
    }
  }  
}
