import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { ViewRecommendedProductComponent } from './view-recommended-product.component';

describe('ViewRecommendedProductComponent', () => {
  let component: ViewRecommendedProductComponent;
  let fixture: ComponentFixture<ViewRecommendedProductComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ ViewRecommendedProductComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(ViewRecommendedProductComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
