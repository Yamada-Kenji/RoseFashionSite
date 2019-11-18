
import { UserModel, CategoryModel, ProductModel, CartModel } from './model';
import { HttpClient, HttpHeaders, HttpParams, HttpHeaderResponse, HttpErrorResponse} from '@angular/common/http';

import { catchError } from 'rxjs/operators';
import { throwError } from 'rxjs';
import { BehaviorSubject, Observable } from 'rxjs';
import { map } from 'rxjs/operators';


const httpOptions = {
    headers: new HttpHeaders({
      'Content-Type':  'application/json'
    })
  };

export class UserService{
    private currentUserSubject: BehaviorSubject<UserModel>;
    public currentUser: Observable<UserModel>;
    constructor(private http: HttpClient){
        this.currentUserSubject = new BehaviorSubject<UserModel>(JSON.parse(localStorage.getItem('currentUser')));
      this.currentUser = this.currentUserSubject.asObservable();
    }
    private userurl = 'http://localhost:62098/api/user';
    Register(newuser: UserModel): Observable<any>{
        return this.http.post(this.userurl, newuser);
    }

    
    public get currentUserValue(): UserModel {
        return this.currentUserSubject.value;
    }
    login(Email: string, Password: string): Observable<UserModel> {
        const editedurl = `${this.userurl}/login`;
        const account: UserModel = { Email, Password} as UserModel;
        return this.http.post<UserModel>(editedurl, account, httpOptions)
            .pipe(map(user => {
                    localStorage.setItem('currentUser', JSON.stringify(user));
                    this.currentUserSubject.next(user);
                return user;
            }));
    }
    logout() {
        // remove user from local storage to log user out
        localStorage.removeItem('currentUser');
        this.currentUserSubject.next(null);
    }
  
    getCurrentUser(){
        var temp: UserModel = JSON.parse(localStorage.getItem('currentUser'));
        return temp;
    }

    //get account by email
    GetAccountByEmail(email: string): Observable<UserModel>{
        const geturl = `${this.userurl}?email=${email}`;
        return this.http.get<UserModel>(geturl);
    }
    //update account
    UpdateAccount(editedaccount: UserModel): Observable<any>{
        return this.http.put(this.userurl, editedaccount, httpOptions);
    }



    CreateGuestID(): Observable<any>{
        const editedurl = `${this.userurl}/guest`;
        return this.http.get<any>(editedurl);
    }

    GetCurrentUser(){
        var userid = localStorage.getItem('UserID');
        if(userid) return userid;
        else return localStorage.getItem('GuestID');
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
    AddToCart(productid: string, image: string, name: string, size: string, amount: number, quantity: number, price: number){
        const newitem: CartModel = {
            CartID: '', 
            UserID: '', 
            ProductID: productid, 
            Image: image, 
            Name: name, 
            Size: size, 
            Amount: amount,
            Quantity: quantity,
            Price: price
        };
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


    UpdateItemAmount(productid, amount){
        var mycart: CartModel[] = JSON.parse(localStorage.getItem('MyCart'));
        var updateditem = mycart.find(item => item.ProductID == productid);
        updateditem.Amount = amount;
        localStorage.setItem('MyCart', JSON.stringify(mycart));
    }

    DeleteItem(productid){
        var mycart: CartModel[] = JSON.parse(localStorage.getItem('MyCart'));
        const index = mycart.indexOf(mycart.find(item => item.ProductID == productid));
        mycart.splice(index, 1);
        localStorage.setItem('MyCart', JSON.stringify(mycart));
    }
}

export class BillService{
    constructor(private http: HttpClient){}
    private billurl = 'http://localhost:62098/api/bill';

    AddBill(items: CartModel[], userid: string): Observable<any>{
        const editedurl = `${this.billurl}?userid=${userid}`;
        return this.http.post(editedurl, items, httpOptions);
    }

}

