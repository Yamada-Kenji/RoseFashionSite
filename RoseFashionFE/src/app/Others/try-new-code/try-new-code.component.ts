import { Component, OnInit } from '@angular/core';
import { UserService } from 'src/app/Shared/user-service';
import { CartService } from 'src/app/Shared/cart-service';
import { CartModel } from 'src/app/Shared/model';


@Component({
  selector: 'app-try-new-code',
  templateUrl: './try-new-code.component.html',
  styleUrls: ['./try-new-code.component.css']
})
export class TryNewCodeComponent implements OnInit {

  message: any;

  constructor(private userService: UserService, private cartService: CartService){};
  

  ngOnInit() {
    
  }

  RunAlgorithm(){
    this.userService.RunRecommendationAlgorithm().toPromise().then(r=>this.message = r).catch(err => this.message = err);
  }

}
