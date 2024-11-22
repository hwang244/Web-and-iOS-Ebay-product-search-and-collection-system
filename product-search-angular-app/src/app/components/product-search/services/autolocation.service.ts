import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class AutolocationService {

  constructor(private http: HttpClient) { }

  getPostalCodes(firstThreeDigits: string): Observable<string[]> {
    const url = `http://api.geonames.org/postalCodeSearchJSON?postalcode_startsWith=${firstThreeDigits}&maxRows=5&username=frnk9927&country=US`;
    return this.http.get<any>(url).pipe(
      map(response => response.postalCodes.map((pc: { postalCode: string; }) => pc.postalCode))
    );
  }
}
