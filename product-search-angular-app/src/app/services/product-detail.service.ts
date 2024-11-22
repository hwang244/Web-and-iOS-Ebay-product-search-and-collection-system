import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ProductDetailService {

  constructor(private http: HttpClient) { }
  getProductDetail(productId: string): Observable<any> {
    const url = `https://csci571-hw3-node-qqafgeljrq-uw.a.run.app/detail/product`;
    const params = new HttpParams().set('itemId', productId);
    return this.http.get<any>(url, {params: params});
  }
}
