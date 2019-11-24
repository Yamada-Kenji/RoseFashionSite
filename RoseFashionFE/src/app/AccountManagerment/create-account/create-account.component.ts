import { Component, OnInit } from '@angular/core';

import { UserModel } from 'src/app/model';
import { UserService } from 'src/app/services';
//Validator
import { FormBuilder,FormControl, FormGroup, Validators } from '@angular/forms';
import { identityRevealedValidator } from './confirm';

@Component({
  selector: 'app-create-account',
  templateUrl: './create-account.component.html',
  styleUrls: ['./create-account.component.css']
})
export class CreateAccountComponent implements OnInit {

  classForm: FormGroup; //Validator
  public user :UserModel[] ;
  public showMessage ;
  vaCate = { username: '', fullname: '',email: '',passwork: '',confirmpass: ''};

  constructor(private userservice: UserService, private formBuilder: FormBuilder) { }

  ngOnInit() {
    //Validators
    this.classForm = new FormGroup({
      'username': new FormControl(this.vaCate.username,
        Validators.required),
      'fullname': new FormControl(this.vaCate.fullname, [
        Validators.required
      ]),
      'email': new FormControl(this.vaCate.email, [
        Validators.required,
        Validators.email
      ]),
      'passwork': new FormControl(this.vaCate.passwork, [
        Validators.required,
        Validators.minLength(6)
      ]),
      'confirmpass': new FormControl(this.vaCate.confirmpass,
        Validators.required)
      
      
  },   { validators: identityRevealedValidator }
  ); 
  /*
  this.classForm = this.formBuilder.group({
    username: ['', Validators.required],
    fullname: ['', Validators.required],
    email: ['', [Validators.required, Validators.email]],
    passwork: ['', [Validators.required, Validators.minLength(6)]],
    confirmpass: ['', Validators.required]
}, {
    validator: MustMatch('password', 'confirmPassword')
});
*/
  }

 // Validators
get username() { return this.classForm.get('username'); }
get fullname() { return this.classForm.get('fullname'); }
get email() { return this.classForm.get('email'); }
get passwork() { return this.classForm.get('passwork'); }
get confirmpass() { return this.classForm.get('confirmpass'); }
//add new category
creatAccount(UserID: string, FullName: string, Email: string,Password: string): void{
var creAccount: UserModel;
this.showMessage=null;
creAccount = {UserID , FullName , Email,Password} as UserModel
this.userservice.Register(creAccount).subscribe(addCourse => this.user.push(addCourse), 
                                                  error => this.showMessage = error);
}

}
