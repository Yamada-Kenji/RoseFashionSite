import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { QuickRatingComponent } from './quick-rating.component';

describe('QuickRatingComponent', () => {
  let component: QuickRatingComponent;
  let fixture: ComponentFixture<QuickRatingComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ QuickRatingComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(QuickRatingComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
