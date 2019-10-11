import { Component, OnInit } from '@angular/core';
import { UserModel } from 'src/app/model';
import { UserService } from '../user.service';

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.css'],
})
export class RegisterComponent implements OnInit {

  newuser: UserModel = new UserModel();

  constructor(private userService: UserService) { }

  ngOnInit() {
  }

  register(){
    this.userService.register(this.newuser);
  }
  asd(){
    console.log(this.newuser);
  }
}
