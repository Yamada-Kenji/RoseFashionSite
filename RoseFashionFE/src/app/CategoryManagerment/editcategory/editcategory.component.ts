import { Component, OnInit } from '@angular/core';
import { CategoryModel } from 'src/app/model';
import { CategoryService } from 'src/app/services';
import { Location } from '@angular/common';
import { ActivatedRoute } from '@angular/router';
//Validator
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { Variable } from '@angular/compiler/src/render3/r3_ast';
@Component({
  selector: 'app-editcategory',
  templateUrl: './editcategory.component.html',
  styleUrls: ['./editcategory.component.css']
})
export class EditcategoryComponent implements OnInit {
  category: CategoryModel;
  Categories: CategoryModel[];
 idd: string;
  constructor(private categoryService: CategoryService,  private location: Location, private route: ActivatedRoute) { }

  ngOnInit() {
    this.getCoursefromRoute();
  }

  getCoursefromRoute(): void {
    const id = this.route.snapshot.paramMap.get('id');
    
    this.categoryService.getCategoryID(id).subscribe(category => this.category = category);
  }
  save(): void {
      this.categoryService.editCategory(this.category).subscribe(() => this.goBack());
      alert("Congratulation! Added class successfully.")
    }
  goBack(): void {
      this.location.back();
    }
  
}
