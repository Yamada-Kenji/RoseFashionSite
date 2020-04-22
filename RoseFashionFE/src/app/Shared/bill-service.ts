import { HttpHeaders, HttpClient } from '@angular/common/http';
import { BillModel } from './model';
import { Observable } from 'rxjs';
import { Injectable } from '@angular/core';

const httpOptions = {
  headers: new HttpHeaders({
    'Content-Type': 'application/json'
  })
};

@Injectable()
export class BillService {
  constructor(private http: HttpClient) { }
  private billurl = 'http://localhost:62098/api/bill';

  AddBillForMember(billinfo: BillModel) {
    return this.http.post(this.billurl, billinfo, httpOptions);
  }

  //get purchase history by id
  GetPurchaseById(userid: string): Observable<BillModel[]> {
    const geturl = `${this.billurl}?userid=${userid}`;
    return this.http.get<BillModel[]>(geturl);
  }

  GetOneBillInfo(billid: string): Observable<BillModel>{
    const editedurl = `${this.billurl}?billid=${billid}`;
    return this.http.get<BillModel>(editedurl);
  }

  GetBillTable(): Observable<BillModel[]>{
    return this.http.get<BillModel[]>(this.billurl);
  }

  UpdateBill(billinfo: BillModel): Observable<any>{
    const editedurl = `${this.billurl}/updatebill`;
    return this.http.post<any>(editedurl,billinfo, httpOptions);
  }

  DeleteBill(billid: string): Observable<any>{
    const editedurl = `${this.billurl}?billid=${billid}`;
    return this.http.delete(editedurl);
  }
}