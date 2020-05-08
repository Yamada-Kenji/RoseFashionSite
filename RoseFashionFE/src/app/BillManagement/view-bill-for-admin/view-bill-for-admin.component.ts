import { Component, OnInit } from '@angular/core';
import { BillService } from 'src/app/Shared/bill-service';
import { BillModel } from 'src/app/Shared/model';

@Component({
  selector: 'app-view-bill-for-admin',
  templateUrl: './view-bill-for-admin.component.html',
  styleUrls: ['./view-bill-for-admin.component.css']
})
export class ViewBillForAdminComponent implements OnInit {

  billtable: BillModel[] = [];
  pageconfig: any;
  constructor(private billService: BillService) {
    this.pageconfig = {
      itemsPerPage: 10,
      currentPage: 1
    };
  }

  ngOnInit() {
    this.billService.GetBillTable().toPromise().then(r => {this.billtable = r;
      this.billtable.sort((b,a) => {
        return <any>new Date(a.OrderDate) - <any>new Date(b.OrderDate);
        });}).catch(err => alert(err));
    this.pageconfig.currentPage = localStorage.getItem('currentpage');
  }

  pageChanged(event) {
    this.pageconfig.currentPage = event;
    localStorage.setItem('currentpage', event);
  }

  DeleteBill(billid: string) {
    if (confirm("Xác nhận xóa hóa đơn này?")) {
      this.billService.DeleteBill(billid).toPromise()
        .then(() => this.billService.GetBillTable().toPromise().then(r => this.billtable = r).catch(err => alert(err)))
        .catch(err => console.log(err));
    }
  }

}
