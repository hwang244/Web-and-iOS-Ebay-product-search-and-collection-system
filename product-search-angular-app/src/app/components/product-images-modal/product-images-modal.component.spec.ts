import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ProductImagesModalComponent } from './product-images-modal.component';

describe('ProductImagesModalComponent', () => {
  let component: ProductImagesModalComponent;
  let fixture: ComponentFixture<ProductImagesModalComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [ProductImagesModalComponent]
    });
    fixture = TestBed.createComponent(ProductImagesModalComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
