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
  ready: boolean = false;

  ratecount: number[] = [0, 0, 0, 0, 0];
  barname: string[] = ["bar1", "bar2", "bar3", "bar4", "bar5"];

  constructor(private productService: ProductService,
    private userService: UserService,
    private messageService: MessageService) { }

  async ngOnInit() {
    var user = this.userService.getCurrentUser();
    await this.productService.CheckingPurchased(user.UserID, this.productid)
      .toPromise().then(r => 
        {
          this.purchased = r;
          if(user.Role=="admin") this.purchased = true;
        });
    await this.productService.GetRatingList(this.productid)
      .toPromise().then(r => {
        this.ratinglist = r;
        if (this.ratinglist.length > 0) {
          this.CountStar();
          this.CalPercent();
          this.ready = true;
        };
      });
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
          .subscribe(r => 
            {
              this.ratinglist = r;
              if (this.ratinglist.length > 0) {
                this.CountStar();
                this.CalPercent();
                this.ready = true;
              }
            });
        this.addrating = !this.addrating;
      }).catch(err => alert("Gửi đánh giá thất bại"));
  }

  CountStar() {
    this.ratinglist.forEach(r => {
      if (r.Star == 1) this.ratecount[0]++;
      if (r.Star == 2) this.ratecount[1]++;
      if (r.Star == 3) this.ratecount[2]++;
      if (r.Star == 4) this.ratecount[3]++;
      if (r.Star == 5) this.ratecount[4]++;
    });
  }

  CalPercent() {
    var i = 0;
    for (i; i < this.ratecount.length; i++) {
      var percent = this.ratecount[i] / this.ratinglist.length;
      var x = document.getElementById(this.barname[i]) as HTMLElement;
      x.style.width = percent.toString() + "%";
    }
  }

}
