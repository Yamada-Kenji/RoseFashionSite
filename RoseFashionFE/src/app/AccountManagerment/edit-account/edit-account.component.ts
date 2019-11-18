import { Component, OnInit } from '@angular/core';
import { UserModel } from 'src/app/model';
import { UserService } from 'src/app/services';
import { Location } from '@angular/common';
import { ActivatedRoute } from '@angular/router';

@Component({
  selector: 'app-edit-account',
  templateUrl: './edit-account.component.html',
  styleUrls: ['./edit-account.component.css']
})
export class EditAccountComponent implements OnInit {

  user: UserModel;
  users: UserModel[];
 idd: string;
  constructor(private userService: UserService,  private location: Location, private route: ActivatedRoute) { }

  ngOnInit() {
    this.getAccountByEmail();
  }

  getAccountByEmail(): void {
    
    this.userService.GetAccountByEmail('haha@gmail.com').subscribe(user => this.user = user);
 
  }
  save(): void {
      this.userService.UpdateAccount(this.user).subscribe(() => this.goBack());
      // alert("Congratulation! Update successfully.")
    }
  goBack(): void {
      this.location.back();
    }

}
