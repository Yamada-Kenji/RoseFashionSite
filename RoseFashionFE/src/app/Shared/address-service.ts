import { HttpHeaders, HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ProvinceModel, DistrictModel } from './model';
import { Injectable } from '@angular/core';

const httpOptions = {
    headers: new HttpHeaders({
      'Content-Type':  'application/json'
    })
  };

@Injectable()
export class AddressService{
    constructor(private http: HttpClient){}
    private addressurl = 'http://localhost:62098/api/address';

    GetProvince(): Observable<ProvinceModel[]>{
        return this.http.get<ProvinceModel[]>(this.addressurl);
    }

    GetDistrict(pvid): Observable<DistrictModel[]>{
        const editedurl = `${this.addressurl}?pvid=${pvid}`;
        return this.http.get<DistrictModel[]>(editedurl);
    }
}