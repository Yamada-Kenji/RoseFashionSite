import { Component, OnInit } from '@angular/core';
import { BillModel } from 'src/app/Shared/model';
import { UserService } from 'src/app/Shared/user-service';
import { BillService } from 'src/app/Shared/bill-service';

@Component({
  selector: 'app-view-bill-for-customer',
  templateUrl: './view-bill-for-customer.component.html',
  styleUrls: ['./view-bill-for-customer.component.css']
})
export class ViewBillForCustomerComponent implements OnInit {

  idUser: string
  history: BillModel[]
  foo: number[] = [1,5,2];

  constructor( private userservice: UserService,private billservice: BillService) { }

  ngOnInit() {
    var x = this.userservice.getCurrentUser();
    this.idUser=x.UserID;
    this.getPurchaseHistory();
  }

  getPurchaseHistory(): void {
   /* this.billservice.GetPurchaseById(this.idUser).subscribe(history => {this.history = history; console.log(history);});
    this.history.sort((a,b) => {
    return <any>new Date(a.OrderDate) - <any>new Date(b.OrderDate);
    });
    console.log(this.history); */

   this.billservice.GetPurchaseById(this.idUser).toPromise()
  .then( history =>{ this.history = history;
    this.history.sort((b,a) => {
      return <any>new Date(a.OrderDate) - <any>new Date(b.OrderDate);
      });
      console.log(history);});
  }
  

}
