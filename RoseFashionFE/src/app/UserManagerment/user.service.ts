import {HttpClient} from '@angular/common/http';
import { UserModel } from '../model';
import { Observable } from 'rxjs';

export class UserService{
    constructor(private http: HttpClient){}
    private apiurl = 'http://localhost:62098/api/user';
    register(newuser: UserModel): Observable<any>{
        return this.http.post(this.apiurl, newuser);
    }
}