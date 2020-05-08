import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { StatisticByMonthComponent } from './statistic-by-month.component';

describe('StatisticByMonthComponent', () => {
  let component: StatisticByMonthComponent;
  let fixture: ComponentFixture<StatisticByMonthComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ StatisticByMonthComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(StatisticByMonthComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
