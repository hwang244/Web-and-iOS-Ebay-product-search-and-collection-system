import { TestBed } from '@angular/core/testing';

import { AutolocationService } from './autolocation.service';

describe('AutolocationService', () => {
  let service: AutolocationService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(AutolocationService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
