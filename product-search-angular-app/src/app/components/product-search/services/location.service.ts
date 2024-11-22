import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class LocationService {
  IPINFO_TOKEN = "a64f51fae9465c";
  constructor(private http: HttpClient) { }

  getUserLocation() {
    const url = `https://ipinfo.io/json?token=${this.IPINFO_TOKEN}`;
    return this.http.get(url);
  }
}
