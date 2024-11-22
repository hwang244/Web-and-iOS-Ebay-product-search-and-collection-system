import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class SearchService {
  private apiUrl = 'https://csci571-hw3-node-qqafgeljrq-uw.a.run.app/search';

  constructor(private http: HttpClient) {}

  performSearch(
    keyword: string,
    category: string,
    conditions: string[],
    shippings: string[],
    distance: string,
    zipcode: string
  ): Observable<any> {
    const params = new HttpParams()
      .set('keyword', keyword)
      .set('category', category)
      .set('conditions', JSON.stringify(conditions))
      .set('shippings', JSON.stringify(shippings))
      .set('distance', distance)
      .set('zipcode', zipcode);
    console.log("Search Params: ", params);
    return this.http.get(this.apiUrl, { params });
  }
}
