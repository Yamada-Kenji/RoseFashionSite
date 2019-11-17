import { Component } from '@angular/core';
import {FormControl, FormGroup, Validators} from "@angular/forms";
import { UserService } from './services';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {

  constructor(private userService: UserService) {}

  ngOnInit() {
    var userid = this.userService.GetCurrentUser();
    if(userid == undefined) {
      this.userService.CreateGuestID().toPromise().then(result => localStorage.setItem('GuestID', result));
    }
  }
}