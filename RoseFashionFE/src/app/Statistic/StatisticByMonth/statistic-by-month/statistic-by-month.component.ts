import { Component, OnInit } from '@angular/core';
import { ChartDataSets, ChartOptions } from 'chart.js';
import { Color, Label } from 'ng2-charts';
import {  StatisticModel } from 'src/app/Shared/model';
import { StatisticService } from 'src/app/Shared/statistic-service';
import { Chart } from 'chart.js';  
@Component({
  selector: 'app-statistic-by-month',
  templateUrl: './statistic-by-month.component.html',
  styleUrls: ['./statistic-by-month.component.css']
})
export class StatisticByMonthComponent implements OnInit {

  statistics: StatisticModel[];
  constructor(private statisticService: StatisticService) { }

  ngOnInit() {
    localStorage.setItem('keyword', '');
    this.getYear();
    // this.getsumbymonth(2018);
  }

  getYear(): void {
    this.statisticService.GetYears().toPromise().then(
        result =>  this.statistics = result
      );
    }

    getsumbymonth(year: number): void{
      let sum: number[]=[];
      this.statisticService.GetStatisticMonth(year).subscribe(result => {sum = result;
        console.log(sum);
        var mychar = new Chart('canvas', {  
          type: 'bar',  
          data: {  
            labels: ['Th1','Th2','Th3','Th4','Th5','Th6','Th7','Th8','Th9','Th10','Th11','Th12'], 
            datasets: [  
              {  
                label: 'tổng doanh thu (VND)',
                data: sum,  
                borderColor: '#3cb371',  
                backgroundColor: "#0000FF",  
                
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
  
  /*lineChartData: ChartDataSets[] = [
    { data: [85, 72, 78, 75, 77, 75], label: 'Crude oil prices' },
  ];

  lineChartLabels: Label[] = ['January', 'February', 'March', 'April', 'May', 'June'];

  lineChartOptions = {
    responsive: true,
  };

  lineChartColors: Color[] = [
    {
      borderColor: 'black',
      backgroundColor: 'rgba(255,255,0,0.28)',
    },
  ];

  lineChartLegend = true;
  lineChartPlugins = [];
  lineChartType = 'line';
*/
}
