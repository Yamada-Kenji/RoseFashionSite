import { Component } from '@angular/core';
import {FormControl, FormGroup, Validators} from "@angular/forms";

import { UserModel } from 'src/app/model';
import { UserService } from 'src/app/services';
import { RouterModule, Router } from '@angular/router';



@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {


  loginmessage: string;
  currentUser: UserModel;
  returnUrl: string;

  email: string;
  islogon: boolean;
  showMessage: string;
  role: string;
  text: string;

  constructor(
    private userservice: UserService,
    private router: Router) {
     if (this.userservice.getCurrentUser()) { this.router.navigate(['/home']);

  }
}

  ngOnInit() {
  }

  async login(email: string, password: string) {
    
    this.loginmessage = null;
    
    this.currentUser =  await this.userservice.login(email, password).toPromise().then(data => this.currentUser = data, error => this.loginmessage = error);
    console.log(this.currentUser.Role);
    if (this.loginmessage != null) {
      this.loginmessage = 'Wrong username or password or role!';
    } else {
      console.log(this.currentUser.Role);
      localStorage.setItem('currentrole', this.currentUser.Role);
      this.loginmessage = 'Login successfully!';

      

      this.setName(this.currentUser.Username);
      this.setRole(this.currentUser.Role);
      switch (this.currentUser.Role) {
      case 'admin': {
        this.router.navigate(['/view-product-list']); break;
      }
      case 'user': {
        this.router.navigate(['/showcategory']); break;
      }
      default: break;
    }
  }
}

setName(email: string){
  this.email = email;
  this.islogon = true;
}
logout() {
  this.userservice.logout();
  this.islogon = false;
  this.email = null;
  this.role = null;
}
setRole(rolename: string){
  this.role = rolename;
  this.islogon = true;
}
  

  // constructor(private userService: UserService) {}

  // ngOnInit() {
  //   var userid = this.userService.GetCurrentUser();
  //   if(userid == undefined) {
  //     this.userService.CreateGuestID().toPromise().then(result => localStorage.setItem('GuestID', result));
  //   }
  // }

}