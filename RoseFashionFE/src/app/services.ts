
import { UserModel, CategoryModel, ProductModel, CartModel } from './model';
import { HttpClient, HttpHeaders, HttpParams, HttpHeaderResponse, HttpErrorResponse} from '@angular/common/http';
import { Observable } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { throwError } from 'rxjs';


const httpOptions = {
    headers: new HttpHeaders({
      'Content-Type':  'application/json'
    })
  };

export class UserService{
    constructor(private http: HttpClient){}
    private userurl = 'http://localhost:62098/api/user';
    Register(newuser: UserModel): Observable<any>{
        return this.http.post(this.userurl, newuser);
    }
}

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

    GetProductListForAdmin(): Observable<ProductModel[]>{
        return this.http.get<ProductModel[]>(this.producturl);
    }
    
    GetProductByCategory(categoryid: string): Observable<ProductModel[]>{
        const editedurl = `${this.producturl}?categoryid=${categoryid}`;
        return this.http.get<ProductModel[]>(editedurl);
    }
}

export class CategoryService{
    constructor(private http: HttpClient){}
    private categoryurl = 'http://localhost:62098/api/category';

    GetCategorybyMainCategory(id: string): Observable<CategoryModel[]>{
        const editedurl = `${this.categoryurl}?maincategory=${id}`;
        return this.http.get<CategoryModel[]>(editedurl);
    }

    GetAllCategory(): Observable<CategoryModel[]>{
        return this.http.get<CategoryModel[]>(this.categoryurl);
    }
    
    addCategory (category: CategoryModel): Observable<CategoryModel> {
        return this.http.post<CategoryModel>(this.categoryurl, category)
                               .pipe(catchError(this.errorHandler));
     }
     errorHandler(error: HttpErrorResponse){
     
        return throwError('Error...Please try again!');
      
    }
    editCategory(categories: CategoryModel): Observable<any> {
        return this.http.put<CategoryModel>(this.categoryurl, categories , httpOptions).pipe();
      }
    getCategoryID(id: string): Observable<CategoryModel> {
        const url = `${this.categoryurl}?categoryId=${id}`;
        return this.http.get<CategoryModel>(url).pipe();
      }
    
}

export class CartService{
    AddToCart(productid: string, image: string, name: string, size: string, amount: number, price: number){
        const newitem: CartModel = {CartID: '', UserID: '', ProductID: productid, Image: image, Name: name, Size: size, Amount: amount, Price: price};
        var mycart: CartModel[] = JSON.parse(localStorage.getItem('MyCart'));
        if(mycart){
            var i=0;
            while(i<mycart.length) {
                if(mycart[i].ProductID==newitem.ProductID && mycart[i].Size==newitem.Size) break;
                else i++;
            }
            if(i>=mycart.length){
                mycart.push(newitem);
            }
            else{
                var newamount = +mycart[i].Amount + +newitem.Amount;
                mycart[i].Amount = newamount;
            }
            localStorage.setItem('MyCart', JSON.stringify(mycart));
        }
        else{
            mycart = [];
            mycart.push(newitem);
            localStorage.setItem('MyCart', JSON.stringify(mycart));
        }
    }
    ViewProductInCart(){
        return JSON.parse(localStorage.getItem('MyCart'));
    }
}

