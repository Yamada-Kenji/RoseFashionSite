import { Component, OnInit, Input } from '@angular/core';
import { ProductService } from 'src/app/Shared/product-service';
import { UserService } from 'src/app/Shared/user-service';
import { RatingModel, MessageModel } from 'src/app/Shared/model';
import { MessageService } from 'src/app/Shared/message-service';

@Component({
  selector: 'app-view-user-rating',
  templateUrl: './view-user-rating.component.html',
  styleUrls: ['./view-user-rating.component.css']
})
export class ViewUserRatingComponent implements OnInit {

  @Input('pr') productid: string;

  star: number = 4.5;
  comments: number[] = [1, 2, 3, 4, 5];
  addrating: boolean = false;
  purchased: boolean = false;
  totalstar: number = 0;
  userrating: RatingModel;
  ratinglist: RatingModel[] = [];

  constructor(private productService: ProductService,
    private userService: UserService,
    private messageService: MessageService) { }

  async ngOnInit() {
    await this.productService.CheckingPurchased(this.userService.getCurrentUser().UserID, this.productid)
      .toPromise().then(r => this.purchased = r);
    await this.productService.GetRatingList(this.productid)
      .toPromise().then(r => this.ratinglist = r);
    await this.productService.GetTotalStar(this.productid)
      .toPromise().then(r => this.totalstar = r);
  }

  ChangeRatingForm() {
    this.addrating = !this.addrating;
    this.productService.GetOneRating(this.userService.getCurrentUser().UserID, this.productid)
      .toPromise().then(r => this.userrating = r);
  }

  AddUserRating() {
    this.productService.AddRating(this.userrating)
      .toPromise().then(() => {
        var msg: MessageModel = { Title: "Thông báo", Content: "Gửi đánh giá thành công", BackToHome: false };
        this.messageService.SendMessage(msg);
        this.productService.GetRatingList(this.productid)
          .toPromise().then(r => this.ratinglist = r);
        this.addrating = !this.addrating;
      }).catch(err => alert("Gửi đánh giá thất bại"));

  }

}
