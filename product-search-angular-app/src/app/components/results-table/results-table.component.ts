import { Component } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Subscription } from 'rxjs';
import { ProductDetailService } from 'src/app/services/product-detail.service';
import { SharedSearchResultsService } from 'src/app/services/shared-search-results.service';
import { FavoritesService } from 'src/app/services/favorites.service';
@Component({
  selector: 'app-results-table',
  templateUrl: './results-table.component.html',
  styleUrls: ['./results-table.component.css']
})
export class ResultsTableComponent {
  private subscriptions = new Subscription();
  products! : any[];
  currentPage: number = 1;
  itemsPerPage: number = 10;
  searchPerformed: boolean = false;
  showDetail: boolean = false;
  selectedProductDetail: any;
  selectedTitle!: string;
  selectedProduct: any;
  clickTitleProduct: any;
  favoriteStatuses: boolean[] = [];

  constructor(private shSrchReService: SharedSearchResultsService, 
              private productDetailService: ProductDetailService,
              private favoritesService: FavoritesService,
              private http: HttpClient){}
  ngOnInit(){
    const srhReSubscription = this.shSrchReService.getSearchArray().subscribe(
      (data) => {
        if(data != null){
          this.products = data;
          this.searchPerformed = this.products.length > 0;
          this.checkFavorites();
        }else{
          this.products = [];
          this.searchPerformed = true;
        }
      },
      (error) => {
        console.error('Error fetching data: ', error);
      }
    );
    this.favoritesService.fetchFavoriteStatuses(); // Fetch the initial favorite statuses
    this.subscriptions.add(
      this.favoritesService.favoriteStatuses$.subscribe(statusesMap => {
        // Update the favoriteStatuses array based on the incoming map
        this.favoriteStatuses = this.products.map(product => statusesMap.get(product.productId) || false);
      })
    );
    this.subscriptions.add(srhReSubscription);
  }
  ngOnDestroy(){
    if(this.subscriptions){
      this.subscriptions.unsubscribe();
    }
  }

  get totalPages(): number {
    return Math.ceil(this.products.length / this.itemsPerPage);
  }

  get pages(): number[] {
    return Array(this.totalPages).fill(0).map((_, index) => index + 1);
  }
  get currentProducts(): any[] {
    const startIndex = (this.currentPage - 1) * this.itemsPerPage;
    if(startIndex == this.totalPages){
      return this.products.slice(startIndex, this.products.length - 1);
    }
    return this.products.slice(startIndex, startIndex + this.itemsPerPage);
  }
  setPage(page: number): void {
    this.currentPage = page;
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

  onSelectProduct(product: any):void{
    console.log(product);
    this.selectedProduct = product;
  }

  onDetailButtonClick(): void {
    if(this.selectedProduct) {
      this.onTitleClick(this.selectedProduct);
    }
  }

  toggleFavorite(product:any, isFavorite: boolean, index:number): void {
    this.favoriteStatuses[index] = !isFavorite ; // Toggle the boolean value

    if (this.favoriteStatuses[index]) {
      this.addToFavorites(product, index);
    } else {
      this.removeFromFavorites(product, index);
    }
  }

  addToFavorites(product: any, index: number) {
    const item = {
      productId: product.itemId,
      image: product.image,
      title: product.title,
      price: product.price,
      shipping: product.shipping,
      zipcode: product.zipcode
    }
    this.http.post('https://csci571-hw3-node-qqafgeljrq-uw.a.run.app/addToFavorites', item).subscribe(response => {
      this.favoriteStatuses[index] = true;
    }, error => {
      // Handle the error
    });
    console.log('Adding to favorites:', product);
  }

  removeFromFavorites(product: any, index: number) {
    this.http.post('https://csci571-hw3-node-qqafgeljrq-uw.a.run.app/removeFromFavorites', { productId: product.itemId }).subscribe(response => {
      // Handle the response, e.g., unmark the product as favorite
      this.favoriteStatuses[index] = false;
    }, error => {
      // Handle the error
    });
    console.log('Removing from favorites:', product);
  }
  onTitleClick(product: any){
    const productId = product.itemId;
    const productTitle = product.title;
    this.getProductDetails(productId);
    this.selectedTitle = productTitle;
    this.clickTitleProduct = product;
    console.log('clickProduct: ', this.clickTitleProduct);
    this.showDetail = true;
  }

  private getProductDetails(productId: string){
    this.productDetailService.getProductDetail(productId).subscribe(
      (data) => {
        this.selectedProductDetail = data;
        console.log(this.selectedProductDetail);
      },
      error => {
        console.error('Error fetching product details: ', error);
      }
    )
  }

  private checkFavorites(): void {
    const productIds = this.products.map(product => product.itemId);
    this.favoritesService.checkFavoriteStatuses(productIds).subscribe(
      (favoriteStatuses) => {
        this.favoriteStatuses = favoriteStatuses;
        console.log(this.favoriteStatuses);
      },
      (error) => {
        console.error('Error checking favorite statuses: ', error);
      }
    );
  }
  
  
  

  backToResults(): void {
    this.showDetail = false;
  }
}
