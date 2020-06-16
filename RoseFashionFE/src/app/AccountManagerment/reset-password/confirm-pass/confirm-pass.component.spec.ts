import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { ConfirmPassComponent } from './confirm-pass.component';

describe('ConfirmPassComponent', () => {
  let component: ConfirmPassComponent;
  let fixture: ComponentFixture<ConfirmPassComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ ConfirmPassComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(ConfirmPassComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
