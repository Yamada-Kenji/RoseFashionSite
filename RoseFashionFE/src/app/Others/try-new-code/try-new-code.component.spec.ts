import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { TryNewCodeComponent } from './try-new-code.component';

describe('TryNewCodeComponent', () => {
  let component: TryNewCodeComponent;
  let fixture: ComponentFixture<TryNewCodeComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ TryNewCodeComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(TryNewCodeComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
