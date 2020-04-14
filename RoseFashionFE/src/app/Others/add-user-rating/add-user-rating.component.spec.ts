import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { AddUserRatingComponent } from './add-user-rating.component';

describe('AddUserRatingComponent', () => {
  let component: AddUserRatingComponent;
  let fixture: ComponentFixture<AddUserRatingComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ AddUserRatingComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(AddUserRatingComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
