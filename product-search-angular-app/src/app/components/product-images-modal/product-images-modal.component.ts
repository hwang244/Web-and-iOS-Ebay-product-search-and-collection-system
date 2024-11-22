import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-product-images-modal',
  templateUrl: './product-images-modal.component.html',
  styleUrls: ['./product-images-modal.component.css']
})
export class ProductImagesModalComponent {
  @Input() images: string[] = [];
  currentImageIndex: number = 0;
  showModal: boolean = false;

  constructor() {}

  openModal() {
    this.showModal = true;
  }

  closeModal() {
    this.showModal = false;
  }

  navigate(next: boolean) {
    if (next && this.currentImageIndex < this.images.length - 1) {
      this.currentImageIndex++;
    } else if (!next && this.currentImageIndex > 0) {
      this.currentImageIndex--;
    }
  }
}
