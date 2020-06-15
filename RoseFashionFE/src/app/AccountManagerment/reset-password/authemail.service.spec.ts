import { TestBed } from '@angular/core/testing';

import { AuthemailService } from './authemail.service';

describe('AuthemailService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: AuthemailService = TestBed.get(AuthemailService);
    expect(service).toBeTruthy();
  });
});
