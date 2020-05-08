import { Component, OnInit } from '@angular/core';
import { UserService } from 'src/app/Shared/user-service';


@Component({
  selector: 'app-try-new-code',
  templateUrl: './try-new-code.component.html',
  styleUrls: ['./try-new-code.component.css']
})
export class TryNewCodeComponent implements OnInit {

  message: any;

  constructor(private userService: UserService){};
  

  ngOnInit() {
    
  }

  RunAlgorithm(){
    this.userService.RunRecommendationAlgorithm().toPromise().then(r=>this.message = r).catch(err => this.message = err);
  }

}
