import { Component, OnInit } from '@angular/core';
import { UserService } from 'src/app/services';
import { BillService } from 'src/app/services';
import { BillModel } from 'src/app/model';

@Component({
  selector: 'app-purchasehistory',
  templateUrl: './purchasehistory.component.html',
  styleUrls: ['./purchasehistory.component.css']
})
export class PurchasehistoryComponent implements OnInit {
  idUser: string
  history: BillModel

  constructor( private userservice: UserService,private billservice: BillService) { }

  ngOnInit() {
    var x = this.userservice.getCurrentUser();
    this.idUser=x.UserID;
    this.getPurchaseHistory();
  }

  getPurchaseHistory(): void {
    this.billservice.GetPurchaseById(this.idUser).subscribe(history => this.history = history);
  }

}
