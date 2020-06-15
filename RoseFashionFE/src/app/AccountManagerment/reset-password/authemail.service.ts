import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class AuthemailService {
  private api = 'http://localhost:4200';

  constructor(private http: HttpClient) { }
  public sendEmail(email: string) {
    return this.http.post(`${this.api}/sendEmail`, email);
  }

}
