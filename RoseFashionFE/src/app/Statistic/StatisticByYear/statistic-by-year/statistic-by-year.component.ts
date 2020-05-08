
import { Component, OnInit } from '@angular/core';
import { ChartDataSets, ChartOptions,ChartType } from 'chart.js';
import { Color, Label } from 'ng2-charts';
import {  StatisticModel } from 'src/app/Shared/model';
import { StatisticService } from 'src/app/Shared/statistic-service';
import { Chart } from 'chart.js';  
@Component({
  selector: 'app-statistic-by-year',
  templateUrl: './statistic-by-year.component.html',
  styleUrls: ['./statistic-by-year.component.css']
})
export class StatisticByYearComponent implements OnInit {
  statistics: StatisticModel[];
  statistic: StatisticModel;
  barchart = [];
 

  constructor(private statisticService: StatisticService) { }

  async ngOnInit() {
    await this.getYear();
    // this.getsumbyyear(2016,2021);

  }
  getYear(): void {
    this.statisticService.GetYears().toPromise().then(
        result =>  this.statistics = result);
    }
   getsumbyyear(fromyear: number,toyear: number): void{
    let sum: number[]=[];
    let year: number[]=[];
    let n: number =0;
    if(fromyear > toyear){
      let tem: number = fromyear;
      fromyear = toyear;
      toyear = tem;
    }
     for (var i:number = fromyear; i<=toyear;i++){
        year[n++] = i;
     }
     console.log(year);
    this.statisticService.GetStatisticYear(fromyear,toyear).subscribe(result => {sum = result;
      
      var mychar = new Chart('canvas', {  
        type: 'bar',  
        data: {  
          labels: year, 
          datasets: [  
            {  
              label: 'tổng doanh thu (VND)',
              data: sum,  
              borderColor: '#3cba9f',  
              backgroundColor: [  
                "#3cb371",  
                "#0000FF",  
                "#9966FF",  
                "#4C4CFF",  
                "#00FFFF",  
                "#f990a7",  
                "#aad2ed",  
                "#FF00FF",  
                "Blue",  
                "Red",  
                "Blue"  
              ],  
              fill: true  
            }  
          ]  
        },  
        options: {  
          legend: {  
            display: true  
          },  
          scales: {  
            xAxes: [{  
              display: true  
            }],  
            yAxes: [{  
              display: true  
            }],  
          }  
        }  
      });  

    });
  }
  refresh(): void {
    window.location.reload();
  }
 /* barChartOptions: ChartOptions = {
    responsive: true,
  };
  barChartLabels: Label[] = ['Apple', 'Banana', 'Kiwifruit','aa','bb'];
  barChartType: ChartType = 'bar';
  barChartLegend = true;
  barChartPlugins = [];

  barChartData: ChartDataSets[] = [
    { data: this.sum, label: 'Best Fruits' }
  ];
*/
}