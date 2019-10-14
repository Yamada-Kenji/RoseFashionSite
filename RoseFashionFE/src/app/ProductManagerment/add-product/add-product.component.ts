import { Component, OnInit } from '@angular/core';
import { CategoryModel, ProductModel } from 'src/app/model';
import { ProductService, CategoryService } from 'src/app/services';

@Component({
  selector: 'app-add-product',
  templateUrl: './add-product.component.html',
  styleUrls: ['./add-product.component.css']
})
export class AddProductComponent implements OnInit {

  product: ProductModel = {ProductID:'', Name:'', Color:'#000000', Size:[]=[], CategoryID:'', Description:'', Quantity:0, Image:'https://cdn1.iconfinder.com/data/icons/social-17/48/photos2-512.png', Price:0};
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
        this.product.Image = reader.result.toString();
      }
    }
  }

  

  show(){
    console.log(this.product);
  }

  async AddProduct(){
    this.GetSelectedSize();
    console.log(this.product);
    await this.productService.AddProduct(this.product).toPromise();
  }

  async GetAllCategory(){
    await this.categoryService.GetAllCategory().toPromise().then(result => this.categorylist = result);
  }

  GetSelectedSize(){
    this.product.Size = this.sizes.filter(opt => opt.checked).map(opt => opt.name);
    console.log(this.product);
  }
}
