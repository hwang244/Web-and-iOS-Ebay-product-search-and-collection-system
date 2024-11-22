import { ComponentFixture, TestBed } from '@angular/core/testing';

import { WishlistTableComponent } from './wishlist-table.component';

describe('WishlistTableComponent', () => {
  let component: WishlistTableComponent;
  let fixture: ComponentFixture<WishlistTableComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [WishlistTableComponent]
    });
    fixture = TestBed.createComponent(WishlistTableComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
