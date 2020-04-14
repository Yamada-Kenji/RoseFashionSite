import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { ViewUserRatingComponent } from './view-user-rating.component';

describe('ViewUserRatingComponent', () => {
  let component: ViewUserRatingComponent;
  let fixture: ComponentFixture<ViewUserRatingComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ ViewUserRatingComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(ViewUserRatingComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
