import { Component, OnInit } from '@angular/core';
import {  UserModel } from 'src/app/Shared/model';
import { UserService } from 'src/app/Shared/user-service';

@Component({
  selector: 'app-send-email',
  templateUrl: './send-email.component.html',
  styleUrls: ['./send-email.component.css']
})
export class SendEmailComponent implements OnInit {
  email: string = 'phamha.hyp@gmail.com'

  constructor(private userservice: UserService) { }

  ngOnInit() {
  }
  getcode(): void {
  this.userservice.getcode(this.email).toPromise().then(
    result =>  {
      alert('successfull');
    })
  }

    

}
