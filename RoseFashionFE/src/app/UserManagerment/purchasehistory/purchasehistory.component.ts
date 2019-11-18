import { Component, OnInit } from '@angular/core';
import { UserService } from 'src/app/services';

@Component({
  selector: 'app-purchasehistory',
  templateUrl: './purchasehistory.component.html',
  styleUrls: ['./purchasehistory.component.css']
})
export class PurchasehistoryComponent implements OnInit {
  email: String
  constructor( private userservice: UserService) { }

  ngOnInit() {
    var x = this.userservice.getCurrentUser();
    this.email=x.Email;
  }

}
