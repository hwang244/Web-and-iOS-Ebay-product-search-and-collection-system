import { Component, Input, Output, EventEmitter } from '@angular/core';

@Component({
  selector: 'app-product-detail',
  templateUrl: './product-detail.component.html',
  styleUrls: ['./product-detail.component.css']
})
export class ProductDetailComponent {
  @Input() product: any;
  @Input() productDetail: any;
  @Input() title: string = '';
  @Output() backToList = new EventEmitter<void>();
  selectedTab: string = 'product';
  detailsList: {key: string, value: any}[] = [];
  shippingList:{key: string, value: any}[] = [];
  sellerInfo: {key: string, value: any}[] = [];
  images: string[] = [];
  currentImageIndex: number = 0;

  constructor(){}
  ngOnChanges():void{
    this.setupDetailsList();
    this.setShipping();
    this.setSeller();
  }
  triggerBackToResults(){
    this.backToList.emit();
  }
  isActive(tab: string):boolean {
    return this.selectedTab === tab;
  }
  selectTab(tabName: string): void {
    this.selectedTab = tabName;
  }

  nextImage() {
    if (this.currentImageIndex < this.images.length - 1) {
      this.currentImageIndex++;
    }
  }

  previousImage() {
    if (this.currentImageIndex > 0) {
      this.currentImageIndex--;
    }
  }

  private setupDetailsList(){
    if(!this.productDetail) return;
    const item = this.productDetail;
    const pic = item?.PictureURL;
    const priceValue = parseFloat(item?.CurrentPrice?.Value);
    const price  = priceValue? '$' + priceValue.toFixed(2) : 'N/A';
    const location = item?.Location;
    const detailValues = item?.ItemSpecifics?.NameValueList;
    let returnPolicy = 'Not specified';
    if (item?.ReturnPolicy) {
      if (item.ReturnPolicy.ReturnsWithin && item.ReturnPolicy.ReturnsWithin !== '0 Days') {
          returnPolicy = item.ReturnPolicy.ReturnsAccepted + ' Within ' + item.ReturnPolicy.ReturnsWithin;
      } else {
          returnPolicy = item.ReturnPolicy.ReturnsAccepted;
      }
    }
    this.detailsList = [
      { key: 'Product Images', value: pic},
      { key: 'Price', value: price},
      { key: 'Location', value: location},
      { key: 'Return Policy', value: returnPolicy}
    ]
    this.images = pic;
    // Function to find and add a detail by name
    const addDetailByName = (name: string) => {
      const detail = detailValues.find((d:any) => d?.Name === name);
      if (detail) {
        const newPair = { key: detail.Name, value: detail?.Value?.[0] || 'N/A' };
        this.detailsList.push(newPair);
      }
    };
    addDetailByName('Brand');
    addDetailByName('Color');
    if (Array.isArray(detailValues)) {
      detailValues.forEach((detail) => {
        if (detail?.Name === 'Brand' || detail?.Name === 'Color') {
          return;
        }
        const newPair = { key: detail?.Name, value: detail?.Value?.[0] || 'N/A' } // Using 'N/A' if Value is not available
        this.detailsList.push(newPair);
      });
    }
  }
  private setShipping(){
    const shippingInfo = this.product.shippingInfo;
    let shippingCost = shippingInfo?.shippingServiceCost?.[0]?.__value__;
    if(shippingCost == '0.0'){
      shippingCost = 'Free Shipping';
    }else{
      const shippingValue = parseFloat(shippingCost);
      shippingCost = '$' + shippingValue.toFixed(2);
    }
    const shippingLocation = shippingInfo?.shipToLocations?.[0];
    const handlingTime = shippingInfo?.handlingTime?.[0] + ' Day';
    const expeditedShipping = shippingInfo?.expeditedShipping?.[0] == 'true' ? true: false;
    const oneDayShipping = shippingInfo?.oneDayShippingAvailable?.[0] == 'true' ? true : false;
    const returnAccepted = this.product?.returnsAccepted == 'true' ? true : false;
    this.shippingList = [
      {key: 'Shipping Cost', value: shippingCost},
      {key: 'Shipping Locations', value: shippingLocation},
      {key: 'Handling Time', value: handlingTime},
      {key: 'Expedited Shipping', value: expeditedShipping},
      {key: 'One Day Shipping', value: oneDayShipping},
      {key: 'Return Accepted', value: returnAccepted}
    ];
  }
  private setSeller(){
    if(!this.productDetail) return;
    const seller = this.productDetail?.Seller;
    const feedbackScore = seller?.FeedbackScore || 'N/A';
    const popularity = seller?.PositiveFeedbackPercent || 'N/A';
    const ratingStar = seller?.FeedbackRatingStar || 'N/A';
    const topRated = seller?.TopRatedSeller || 'N/A';
    const storeName = this.productDetail?.Storefront?.StoreName || 'N/A';
    const storeUrl = this.productDetail?.Storefront?.StoreURL || 'N/A';
    this.sellerInfo = [
      {key: 'Feedback Score', value: feedbackScore},
      {key: 'Popularity', value: popularity},
      {key: 'Feedback Rating Star', value: ratingStar},
      {key: 'Top Rated', value: topRated},
      {key: 'Store Name', value: storeName},
      {key: 'Buy Product At', value: storeUrl}
    ];
    console.log('ProductDetail: ', this.productDetail);
    console.log('SellerInfo: ', this.sellerInfo);
  }
  transformStoreName(name: string): string {
    return name.toUpperCase().replace(/\s+/g, '');
  }  
}
