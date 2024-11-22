import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  activeView: 'Result' | 'WishList' = 'Result';
  title = 'product-search-angular-app';
}
