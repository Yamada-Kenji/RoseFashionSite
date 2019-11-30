import { Component, OnInit } from '@angular/core';
import { ProductModel, CategoryModel, MessageModel } from 'src/app/Shared/model';
import { ActivatedRoute } from '@angular/router';
import { Location } from '@angular/common';
import { ProductService } from 'src/app/Shared/product-service';
import { CategoryService } from 'src/app/Shared/category-service';
import { MessageService } from 'src/app/Shared/message-service';

@Component({
  selector: 'app-update-product',
  templateUrl: './update-product.component.html',
  styleUrls: ['./update-product.component.css']
})
export class UpdateProductComponent implements OnInit {

  product: ProductModel = new ProductModel();
  categorylist: CategoryModel[] = [];
  selectedmaincategory: string="";
  message: any;
  maxquantity: number = 999;
  minquantity: number = 0;
  sizes = [
    {name:'S', quantity: 0, checked:false},
    {name:'M', quantity: 0, checked:false},
    {name:'L', quantity: 0, checked:false},
    {name:'XL', quantity: 0, checked:false},
    {name:'XXL', quantity: 0, checked:false}
  ]

  constructor(private productService: ProductService, 
    private categoryService: CategoryService,
    private route: ActivatedRoute,
    private messageService: MessageService,
    private location: Location) { }

  ngOnInit() {
    var productid = this.route.snapshot.paramMap.get('productid');
    this.GetAllCategory();
    this.productService.GetProductDetail(productid).toPromise().then(p =>{
      this.product = p;
      this.SetCategory();
    });
  }

  // đọc dữ liệu file ảnh sang dạng url
  //nguồn tham khảo https://stackblitz.com/edit/angular-file-upload-preview?file=app%2Fapp.component.html
  onSelectFile(event) {
    if (event.target.files && event.target.files[0]) {
      var reader = new FileReader();

      reader.readAsDataURL(event.target.files[0]); // read file as data url

      reader.onload = (event) => { // called once readAsDataURL is completed
        this.product.Image = reader.result.toString();
      }
    }
  }

  async GetAllCategory(){
    await this.categoryService.GetAllCategory().toPromise().then(result => this.categorylist = result);
  }

  SetCategory(){
    var i:number=0;
    for(i;i<this.categorylist.length;i++){
      if(this.categorylist[i].CategoryID==this.product.CategoryID){
        this.selectedmaincategory = this.categorylist[i].MainCategory; break;
      }
    }
  }

  GetSelectedSizeAndQuantity(){
    this.product.Size = this.sizes.filter(opt => opt.checked).map(opt => opt.name);
    this.product.Quantity = this.sizes.filter(opt => opt.checked).map(opt => opt.quantity);
  }

  UpdateProduct(){
    this.productService.UpdateProduct(this.product)
    .toPromise().then(() => {
      alert('Thêm sản phẩm thành công');
      this.location.back();
    })
    .catch(() => alert('Đã có lỗi xảy ra.'));
    // var messagemodel: MessageModel = {Title:'', Content:''}
    // if(this.message=='OK') {
    //   messagemodel.Title='Thông báo';
    //   messagemodel.Content='Thêm sản phẩm thành công';
    // }
    // else{
    //   messagemodel.Title='Lỗi';
    //   messagemodel.Content='Đã có lỗi xảy ra.';
    // }
  }

  Cancel(){
    if(confirm('Bạn có muốn hủy toàn bộ thay đổi đã thực hiện tại trang này không?')){
      this.location.back();
    }
  }

  OnQuantityChange(index: number){
    if(this.product.Quantity[index] > this.maxquantity) this.product.Quantity[index] = this.maxquantity;
    if(this.product.Quantity[index] <= this.minquantity) this.product.Quantity[index] = this.minquantity;
  
  }
  
}
