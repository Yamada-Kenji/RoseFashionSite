import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-quick-rating',
  templateUrl: './quick-rating.component.html',
  styleUrls: ['./quick-rating.component.css']
})
export class QuickRatingComponent implements OnInit {

  orgtext: HTMLElement;
  overflow: boolean = false;
  constructor() { }

  ngOnInit() {
    // this.orgtext = document.getElementById('org-text') as HTMLElement;
    // var textwidth = this.orgtext.offsetWidth;
    // console.log(textwidth);
    // if(+textwidth > 100){
    //   this.overflow = true;
    // }
  }
}
