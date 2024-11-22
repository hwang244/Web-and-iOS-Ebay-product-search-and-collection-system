import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { MatAutocompleteModule } from '@angular/material/autocomplete';
import { MatInputModule } from '@angular/material/input';
import { ReactiveFormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { ProductSearchComponent } from './components/product-search/product-search.component';
import { ResultsTableComponent } from './components/results-table/results-table.component';
import { WishlistTableComponent } from './components/wishlist-table/wishlist-table.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { ProductDetailComponent } from './components/product-detail/product-detail.component';
import { ProductImagesModalComponent } from './components/product-images-modal/product-images-modal.component';
@NgModule({
  declarations: [
    AppComponent,
    ProductSearchComponent,
    ResultsTableComponent,
    WishlistTableComponent,
    ProductDetailComponent,
    ProductImagesModalComponent
  ],
  imports: [
    MatAutocompleteModule,
    MatInputModule,
    HttpClientModule,
    BrowserModule,
    AppRoutingModule,
    ReactiveFormsModule,
    BrowserAnimationsModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
