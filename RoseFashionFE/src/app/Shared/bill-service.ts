import { HttpHeaders, HttpClient } from '@angular/common/http';
import { BillModel } from './model';

const httpOptions = {
    headers: new HttpHeaders({
      'Content-Type':  'application/json'
    })
  };

export class BillService{
    constructor(private http: HttpClient){}
    private billurl = 'http://localhost:62098/api/bill';

    AddBillForMember(billinfo: BillModel){
        return this.http.post(this.billurl, billinfo, httpOptions);
    }
}