import { HttpHeaders, HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { StatisticModel } from './model';
import { Injectable } from '@angular/core';

const httpOptions = {
    headers: new HttpHeaders({
        'Content-Type': 'application/json'
    })
};
@Injectable()
export class StatisticService {
    constructor(private http: HttpClient) { }
    private statisticurl = 'http://localhost:62098/api/statistical';

    GetYears(): Observable<StatisticModel[]>{
        return this.http.get<StatisticModel[]>(this.statisticurl);
      }

    GetStatisticYear(fromyear: number,toyear: number): Observable<number[]>{
        const url = `${this.statisticurl}?fromyear=${fromyear}&toyear=${toyear}`;
        return this.http.get<number[]>(url).pipe();
      }
    GetStatisticMonth(year: number): Observable<number[]>{
        const url = `${this.statisticurl}?year=${year}`;
        return this.http.get<number[]>(url).pipe();
      }
}