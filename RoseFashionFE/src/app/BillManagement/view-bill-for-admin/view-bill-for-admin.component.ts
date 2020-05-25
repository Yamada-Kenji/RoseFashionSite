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
  sortcolumn: number = 3;
  asc: boolean = false;
  constructor(private billService: BillService) {
    this.pageconfig = {
      itemsPerPage: 10,
      currentPage: 1
    };
  }

  ngOnInit() {
    this.billService.GetBillTable().toPromise().then(r => {this.billtable = r;
      // this.billtable.sort((b,a) => {
      //   return <any>new Date(a.OrderDate) - <any>new Date(b.OrderDate);
      this.Sort(this.sortcolumn);
      }).catch(err => alert(err));
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

  ChangeSortColumn(col){
    if(this.sortcolumn == col){
      this.asc = !this.asc;
    }
    else{
      this.sortcolumn = col;
      this.asc = true;
    }
    this.Sort(col);
  }

  Sort(col){
    console.log(col);
    switch(col){
      case 1:{
        if(!this.asc) this.billtable.sort((a,b)=>(a.BillID > b.BillID ? -1 : 1));
        else this.billtable.sort((a,b)=>(b.BillID > a.BillID ? -1 : 1));
        break;
      }
      case 2:{
        if(!this.asc) this.billtable.sort((a,b)=>(a.ReceiverName > b.ReceiverName ? -1 : 1));
        else this.billtable.sort((a,b)=>(b.ReceiverName > a.ReceiverName ? -1 : 1));
        break;
      }
      case 3:{
        if(!this.asc) this.billtable.sort((a,b)=>(a.OrderDate > b.OrderDate ? -1 : 1));
        else this.billtable.sort((a,b)=>(b.OrderDate > a.OrderDate ? -1 : 1));
        break;
      }
      case 4:{
        if(!this.asc) this.billtable.sort((a,b)=>a.TotalPrice - b.TotalPrice);
        else this.billtable.sort((a,b)=>b.TotalPrice - a.TotalPrice);
        break;
      }
      default:{
        if(!this.asc) this.billtable.sort((a,b)=>(a.OrderDate > b.OrderDate ? -1 : 1));
        else this.billtable.sort((a,b)=>(b.OrderDate > a.OrderDate ? -1 : 1));
        break;
      }
    }
  }
}
