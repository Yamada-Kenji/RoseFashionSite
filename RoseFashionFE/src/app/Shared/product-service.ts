import { HttpHeaders, HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ProductModel, TestModel } from './model';

const httpOptions = {
    headers: new HttpHeaders({
      'Content-Type':  'application/json'
    })
  };

  export class ProductService{
    constructor(private http: HttpClient){}
    private producturl = 'http://localhost:62098/api/product';

    AddProduct(newproduct: ProductModel): Observable<any>{
        return this.http.post(this.producturl, newproduct, httpOptions);
    }

    UpdateProduct(editedproduct: ProductModel): Observable<any>{
        return this.http.put(this.producturl, editedproduct, httpOptions);
    }

    DeleteProduct(productid: string): Observable<any>{
        const editedurl = `${this.producturl}?productid=${productid}`;
        return this.http.delete(editedurl);
    }

    GetProductDetail(id: string): Observable<ProductModel>{
        const editedurl = `${this.producturl}?pid=${id}`;
        return this.http.get<ProductModel>(editedurl);
    }

    GetAllProduct(): Observable<ProductModel[]>{
        return this.http.get<ProductModel[]>(this.producturl);
    }
    
    GetProductByCategory(categoryid: string): Observable<ProductModel[]>{
        const editedurl = `${this.producturl}?categoryid=${categoryid}`;
        return this.http.get<ProductModel[]>(editedurl);
    }

    GetProductByCategoryVer2(categoryid: string): Observable<string[]>{
        const editedurl = `${this.producturl}?categoryid=${categoryid}`;
        return this.http.get<string[]>(editedurl);
    }


    GetTopSales(): Observable<ProductModel[]>{
        const editedurl = `${this.producturl}/topsale`;
        return this.http.get<ProductModel[]>(editedurl);
    }

     // get Product when find
    FindProduct(keyword: string): Observable<ProductModel[]>{
        const editedurl = `${this.producturl}?keyword=${keyword}`;
        return this.http.get<ProductModel[]>(editedurl);
    }

    /*FindProductVer2(keyword: string): Observable<string[]>{
        const editedurl = `${this.producturl}?keyword=${keyword}`;
        return this.http.get<string[]>(editedurl);
    }

    GetProductIDList(): Observable<string[]>{
        const editedurl = `${this.producturl}/list`;
        return this.http.get<string[]>(editedurl);
    }*/

    UploadImage(data: FormData): Observable<any>{
        const editedurl = `${this.producturl}/imgupload`;
        return this.http.post(editedurl, data);
    }
}