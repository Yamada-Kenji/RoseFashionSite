import { Component, OnInit } from '@angular/core';
import { CategoryModel } from 'src/app/model';
import { CategoryService } from 'src/app/services';

@Component({
  selector: 'app-showcategory',
  templateUrl: './showcategory.component.html',
  styleUrls: ['./showcategory.component.css']
})
export class ShowcategoryComponent implements OnInit {
  category: CategoryModel[];
  a: object;
  constructor(private categoryService: CategoryService) { }

  ngOnInit() {
   this.getCategory();
  }
  //get category
  async getCategory() {
    await this.categoryService.GetAllCategory().toPromise().then(result => this.category= result);
   

}

}
