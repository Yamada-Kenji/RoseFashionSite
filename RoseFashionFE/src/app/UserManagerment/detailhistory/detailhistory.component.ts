import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
@Component({
  selector: 'app-detailhistory',
  templateUrl: './detailhistory.component.html',
  styleUrls: ['./detailhistory.component.css']
})
export class DetailhistoryComponent implements OnInit {

  constructor(private route: ActivatedRoute, private router: Router) { }

  ngOnInit() {
    const key = this.route.snapshot.paramMap.get('keyword');
    this.router.navigate(['/findproduct/'+ key]);
  }

}
