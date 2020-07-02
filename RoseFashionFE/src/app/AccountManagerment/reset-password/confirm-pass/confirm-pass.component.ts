import { Component, OnInit } from '@angular/core';
//Validator
import { FormBuilder, FormControl, FormGroup, Validators } from '@angular/forms';
import { identityRevealedValidator } from 'src/app/AccountManagerment/create-account/confirm';
import { UserService } from 'src/app/Shared/user-service';

@Component({
  selector: 'app-confirm-pass',
  templateUrl: './confirm-pass.component.html',
  styleUrls: ['./confirm-pass.component.css']
})
export class ConfirmPassComponent implements OnInit {
  classForm: FormGroup; //Validator
  vaCate = { passwork: '', confirmpass: '' };

  constructor(userservice: UserService) { }

  ngOnInit() {
     //Validators
     this.classForm = new FormGroup({
      'passwork': new FormControl(this.vaCate.passwork, [
        Validators.required,
        Validators.minLength(6)
      ]),
      'confirmpass': new FormControl(this.vaCate.confirmpass,
        Validators.required)


    }, { validators: identityRevealedValidator }
    );
  }

   // Validators
   get passwork() { return this.classForm.get('passwork'); }
   get confirmpass() { return this.classForm.get('confirmpass'); }

}
