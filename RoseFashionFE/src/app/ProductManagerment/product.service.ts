import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { CategoryModel } from '../model';

const httpOptions = {
    headers: new HttpHeaders({
      'Content-Type':  'application/json'
    })
  };

export class ProductService{
    constructor(private http: HttpClient){}
    private apiurl = 'http://localhost:62098/api/product';

    SaveImage(category: CategoryModel): Observable<any>{
        //const editedurl = `${this.apiurl}?imgurl=${imgurl}`;
        return this.http.post(this.apiurl, category, httpOptions);
    }

    GetImage(id: string): Observable<any>{
        const editedurl =  `${this.apiurl}?id=${id}`;
        return this.http.get(editedurl);
    }

}