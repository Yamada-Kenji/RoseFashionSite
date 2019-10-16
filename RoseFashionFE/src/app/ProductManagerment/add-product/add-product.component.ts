import { Component, OnInit } from '@angular/core';
import { CategoryModel, ProductModel } from 'src/app/model';
import { ProductService, CategoryService } from 'src/app/services';

@Component({
  selector: 'app-add-product',
  templateUrl: './add-product.component.html',
  styleUrls: ['./add-product.component.css']
})
export class AddProductComponent implements OnInit {

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

  constructor(private productService: ProductService, private categoryService: CategoryService) { }

  async ngOnInit() {
    await this.GetAllCategory();
    await this.productService.GetProductDetail('PR-2').toPromise().then(p => this.product=p);

    var i:number=0;
    for(i;i<this.categorylist.length;i++){
      if(this.categorylist[i].CategoryID==this.product.CategoryID){
        this.selectedmaincategory = this.categorylist[i].MainCategory; break;
      }
    }
    console.log(this.selectedmaincategory);
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
    else{
      this.product.Image='';
    }
  }

  

  show(){
    console.log(this.product);
  }

  async AddProduct(){
    console.log(this.product);
    await this.productService.AddProduct(this.product).toPromise().then(m => console.log(m));
  }

  async GetAllCategory(){
    await this.categoryService.GetAllCategory().toPromise().then(result => this.categorylist = result);
  }

  GetSelectedSizeAndQuantity(){
    this.product.Size = this.sizes.filter(opt => opt.checked).map(opt => opt.name);
    this.product.Quantity = this.sizes.filter(opt => opt.checked).map(opt => opt.quantity);
    console.log(this.product);
  }
}
