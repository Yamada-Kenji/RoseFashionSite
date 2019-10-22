import { Component, OnInit } from '@angular/core';
import { ProductModel, CategoryModel } from 'src/app/model';
import { ProductService, CategoryService } from 'src/app/services';
import { ActivatedRoute } from '@angular/router';
import { Location } from '@angular/common';

@Component({
  selector: 'app-update-product',
  templateUrl: './update-product.component.html',
  styleUrls: ['./update-product.component.css']
})
export class UpdateProductComponent implements OnInit {

  product: ProductModel = {ProductID:'', Name:'', Color:'#000000', Size:[]=['S','M','L','XL','XXL'], CategoryID:'', Description:'', Quantity:[]=[0,0,0,0,0], Image:'', Price:0};
  categorylist: CategoryModel[] = [];
  selectedmaincategory: string="";
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
      console.log('adafafafafa');
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

  async UpdateProduct(){
    await this.productService.UpdateProduct(this.product).toPromise().then(result => alert(result));
    this.location.back();
  }

  Cancel(){
    if(confirm('Bạn có muốn hủy toàn bộ thay đổi đã thực hiện tại trang này không?')){
      this.location.back();
    }
  }
  
}
