import { Component, OnInit } from '@angular/core';
import { ProductService } from '../product.service';
import { CategoryModel } from 'src/app/model';

@Component({
  selector: 'app-add-product',
  templateUrl: './add-product.component.html',
  styleUrls: ['./add-product.component.css']
})
export class AddProductComponent implements OnInit {

  category: CategoryModel = new CategoryModel();
  imgurl='';
  constructor(private productService: ProductService) { }

  ngOnInit() {
  }

  //nguồn tham khảo https://stackblitz.com/edit/angular-file-upload-preview?file=app%2Fapp.component.html
  onSelectFile(event) {
    if (event.target.files && event.target.files[0]) {
      var reader = new FileReader();

      reader.readAsDataURL(event.target.files[0]); // read file as data url

      reader.onload = (event) => { // called once readAsDataURL is completed
        this.category.Name = event.target.result.toString();
      }
    }
  }

  async SaveImage(){
    console.log(this.category.Name)
    await this.productService.SaveImage(this.category).toPromise();
  }

  async GetImage(){
    await this.productService.GetImage("1").toPromise().then(link => this.imgurl=link);
    console.log(this.imgurl);
  }
}
