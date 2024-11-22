import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class FavoritesService {
  private favoriteStatuses = new BehaviorSubject<Map<string, boolean>>(new Map());
  constructor(private http: HttpClient) {}

  // Observable for components to subscribe to
  favoriteStatuses$ = this.favoriteStatuses.asObservable();

  // Method to refresh favorite statuses from the server
  fetchFavoriteStatuses(): void {
    this.http.get<any[]>('https://csci571-hw3-node-qqafgeljrq-uw.a.run.app/favorites').subscribe(
      favorites => {
        // Transform the array of favorite objects into a map of product IDs to favorite status
        const statuses = new Map<string, boolean>();
        for (const item of favorites) {
          statuses.set(item.productId, true); // Assuming each object has a productId field
        }
        this.favoriteStatuses.next(statuses);
      },
      error => {
        console.error('Failed to fetch favorite statuses', error);
      }
    );
  }
  // Method to update the favorite status
  updateFavoriteStatus(product: any, isFavorite: boolean): Observable<any> {
    const productId = product.productId;

    // Depending on whether isFavorite is true or false, make the appropriate server call
    if (isFavorite) {
      return this.http.post('https://csci571-hw3-node-qqafgeljrq-uw.a.run.app/addToFavorites', product);
    } else {
      return this.http.post(`https://csci571-hw3-node-qqafgeljrq-uw.a.run.app/removeFromFavorites`, {productId: productId});
    }
  }
  // Method to check if a product is in favorites
  checkFavoriteStatus(productId: string): Observable<{ isFavorite: boolean }> {
    return this.http.get<{ isFavorite: boolean }>('https://csci571-hw3-node-qqafgeljrq-uw.a.run.app/isFavorite', {
      params: { productId: productId }
    });
  }

  checkFavoriteStatuses(productIds: string[]): Observable<boolean[]> {
    // Join the array of productIds into a comma-separated string
    const params = productIds.join(',');
    // Make the GET request to your backend
    const data =  this.http.get<boolean[]>('https://csci571-hw3-node-qqafgeljrq-uw.a.run.app/areFavorites', { params: { productIds: params } });
    console.log(data);
    return data;
  }
}
