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
    this.billService.GetBillTable().toPromise().then(r => this.billtable = r).catch(err => alert(err));
  }

  pageChanged(event) {
    this.pageconfig.currentPage = event;
  }

}
