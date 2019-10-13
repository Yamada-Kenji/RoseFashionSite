import { Component, OnInit } from '@angular/core';
import { CategoryModel, ProductModel } from 'src/app/model';
import { ProductService, CategoryService } from 'src/app/services';

@Component({
  selector: 'app-add-product',
  templateUrl: './add-product.component.html',
  styleUrls: ['./add-product.component.css']
})
export class AddProductComponent implements OnInit {

  newproduct: ProductModel = new ProductModel();
  categorylist: CategoryModel[] = [];
  selectedmaincategory: string;
  sizes = [
    {name:'S', checked:false},
    {name:'M', checked:false},
    {name:'L', checked:false},
    {name:'XL', checked:false},
    {name:'XXL', checked:false}
  ]

  constructor(private productService: ProductService, private categoryService: CategoryService) { }

  async ngOnInit() {
    await this.GetAllCategory();
    console.log(this.categorylist);
  }

  // đọc dữ liệu file ảnh sang dạng url
  //nguồn tham khảo https://stackblitz.com/edit/angular-file-upload-preview?file=app%2Fapp.component.html
  onSelectFile(event) {
    if (event.target.files && event.target.files[0]) {
      var reader = new FileReader();

      reader.readAsDataURL(event.target.files[0]); // read file as data url

      reader.onload = (event) => { // called once readAsDataURL is completed
        this.newproduct.Image = reader.result.toString();
      }
    }
  }

  

  show(){
    console.log(this.newproduct);
  }

  async AddProduct(){
    await this.productService.AddProduct(this.newproduct).toPromise();
  }

  async GetAllCategory(){
    await this.categoryService.GetAllCategory().toPromise().then(result => this.categorylist = result);
  }

  GetSelectedSize(){
    this.newproduct.Size = this.sizes.filter(opt => opt.checked).map(opt => opt.name);
    console.log(this.newproduct);
  }
}
