import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { FavoritesService } from 'src/app/services/favorites.service';
import { Subscription } from 'rxjs';
@Component({
  selector: 'app-wishlist-table',
  templateUrl: './wishlist-table.component.html',
  styleUrls: ['./wishlist-table.component.css']
})
export class WishlistTableComponent{
  private subscriptions = new Subscription();
  favoriteProducts: any[] = [];
  favoriteStatuses: boolean[] = [];
  constructor(
    private http: HttpClient,
    private favoritesService: FavoritesService
  ){}

  ngOnInit(){
    this.loadWishlist();
    this.subscriptions.add(
      this.favoritesService.favoriteStatuses$.subscribe(statuses => {
        // Update the favoriteStatuses array whenever there's a change
        this.favoriteStatuses = this.favoriteProducts.map((product:any) => statuses.get(product.itemId) || false);
      })
    );
  }
  ngOnDestroy(){
    this.subscriptions.unsubscribe();
  }
  truncateTitle(title: string, maxLength:number = 35):string{
    if(title.length <= maxLength) return title;
    let trimmedString = title.substr(0, maxLength);
    if (trimmedString.lastIndexOf(' ') > -1) {
      // If there's a whitespace character before the cut-off point, trim up to that point.
      trimmedString = trimmedString.substr(0, Math.min(trimmedString.length, trimmedString.lastIndexOf(' ')));
    }
    trimmedString += '...';
    return `${trimmedString}`;
  }
  loadWishlist() {
    // Load the wishlist items from the database
    this.http.get<any[]>('https://csci571-hw3-node-qqafgeljrq-uw.a.run.app/favorites').subscribe(
      data => {
        this.favoriteProducts = data;
        // Initialize the favoriteStatuses based on the products
        this.favoriteStatuses = this.favoriteProducts.map((product:any) => true); // Wishlist items are all favorites by default
      },
      error => {
        console.error('Error fetching wishlist: ', error);
      }
    );
  }

  calculateTotal(): string {
    const total = this.favoriteProducts.reduce((sum, product) => {
      // Remove the dollar sign and parse the number
      const priceNumber = parseFloat(product.price.replace('$', ''));
      return sum + priceNumber;
    }, 0);
    return `$${total.toFixed(2)}`; // Convert the total to a string with two decimal places
  }

  toggleFavorite(product: any, index: number) {
    console.log('Toggling favorite for product at index:', index, product);
    const isFavorite = this.favoriteStatuses[index];
    const newStatus = !isFavorite;

    // Update the central favorite status via the service
    this.favoritesService.updateFavoriteStatus(product, newStatus).subscribe({
      next: (response) => {
        this.favoriteStatuses[index] = newStatus;
        // Handle the successful response, if necessary
        console.log(this.favoriteStatuses);
      },
      error: (error) => {
        // Revert the optimistic update if there's an error
        this.favoriteStatuses[index] = isFavorite;
        console.error('Failed to update favorite status: ', error);
      }
    });
  }
}
