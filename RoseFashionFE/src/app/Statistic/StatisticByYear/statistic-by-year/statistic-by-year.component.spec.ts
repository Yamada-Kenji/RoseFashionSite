import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { StatisticByYearComponent } from './statistic-by-year.component';

describe('StatisticByYearComponent', () => {
  let component: StatisticByYearComponent;
  let fixture: ComponentFixture<StatisticByYearComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ StatisticByYearComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(StatisticByYearComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
