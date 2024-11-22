import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class SharedSearchResultsService {
  private searchArray = new BehaviorSubject<any[]>([]);
  searchArray$ = this.searchArray.asObservable();

  constructor() { }
  setSearchArray(jsonData: any): void {
    this.searchArray.next(jsonData);
  }
  getSearchArray(): Observable<any[]> {
    return this.searchArray.asObservable();
  }
}
