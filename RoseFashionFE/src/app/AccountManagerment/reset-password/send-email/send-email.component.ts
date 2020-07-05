import { Component, OnInit } from '@angular/core';
import {  UserModel } from 'src/app/Shared/model';
import { UserService } from 'src/app/Shared/user-service';

@Component({
  selector: 'app-send-email',
  templateUrl: './send-email.component.html',
  styleUrls: ['./send-email.component.css']
})
export class SendEmailComponent implements OnInit {

  constructor(private userservice: UserService) { }

  ngOnInit() {
  }
  getcode(email: string): void {
  this.userservice.getcode(email).toPromise().then(
    result =>  {
      alert('successfull');
    })
  }

    

}
