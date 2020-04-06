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
  constructor(private billService: BillService) {
   }

  ngOnInit() {
    this.billService.GetBillTable().toPromise().then(r => this.billtable = r).catch(err => alert(err));
  }

}
