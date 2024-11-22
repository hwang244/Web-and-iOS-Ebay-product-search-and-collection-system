import { TestBed } from '@angular/core/testing';

import { SharedSearchResultsService } from './shared-search-results.service';

describe('SharedDataService', () => {
  let service: SharedSearchResultsService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(SharedSearchResultsService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
