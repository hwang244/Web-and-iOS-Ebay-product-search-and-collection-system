//
//  ProductDetailView.swift
//  hw4
//
//  Created by Frank Wang on 11/28/23.
//

import SwiftUI
struct ProductDetailView: View {
    var product:Product
//    var productDetail: ProductDetail
    @ObservedObject var productsViewModel: ProductsViewModel
    @StateObject private var viewModel = ProductDetailViewModel()
    @State private var selectedTab: Int = 0
    @State private var autoScrollIndex: Int = 0
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TabView(selection: $selectedTab){
            ScrollView {
                if let productDetail = viewModel.productDetail{
                    VStack(alignment: .leading, spacing: 0) {
                        // Image carousel
                        if !productDetail.pictureURL.isEmpty  {
                            let pictureURL = productDetail.pictureURL
                            // Image carousel with automatic scrolling
                            TabView(selection: $autoScrollIndex) {
                                ForEach(pictureURL, id: \.self) { urlString in
                                    AsyncImage(url: URL(string: urlString)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image.resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(maxWidth: .infinity)
                                        case .failure:
                                            Image(systemName: "photo")
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .tag(pictureURL.firstIndex(of: urlString) ?? 0)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)) // Scroll indicators
                            .frame(height: 220) // Adjust height as needed
                            .padding([.horizontal, .top], 0)
                            .onReceive(timer) { _ in
                                withAnimation {
                                    autoScrollIndex = (autoScrollIndex + 1) % pictureURL.count
                                }
                            }
                        }
                        
                        Text(productDetail.title)
                            .padding(.top)
                        if let price = productDetail.currentPrice.value {
                            Text("$\(String(format: "%.2f", price))") // Format to two decimal places
                                .foregroundColor(.blue) // Set text color to blue
                                .fontWeight(.bold)
                                .padding(.top)
                        }
                        HStack{
                            Image(systemName: "magnifyingglass")
                            Text("Description")
                        }
                        .padding(.top)
                        VStack(alignment: .leading, spacing: 5) {
                            Divider()
                            if let brand = item(for: "Brand") {
                                specificationRow(name: "Brand", value: brand)
                                Divider()
                            }
                            if let model = item(for: "Model") {
                                specificationRow(name: "Model", value: model)
                                Divider()
                            }
                            if let color = item(for: "Color") {
                                specificationRow(name: "Color", value: color)
                                Divider()
                            }
                            ForEach(productDetail.itemSpecifics.nameValueList, id: \.name){ item in
                                if item.name != "Brand" && item.name != "Model" && item.name != "Color" {
                                    specificationRow(name: item.name, value: item.value.first ?? "")
                                    Divider()
                                }
                            }
                            .padding(.bottom, 0)
                        }
                        .padding()
                        
                    } 
                }
            }
            .padding([.leading, .trailing])
            .tabItem {
                Image(systemName: "info.circle.fill")
                Text("Info")
            }
            .tag(0)
            VStack{
                if let productDetail = viewModel.productDetail{
                    VStack(alignment:.leading) {
                        Divider()
                        HStack {
                            Image(systemName: "storefront")
                            Text("Seller")
                        }
                        .padding(.bottom, 2)
                        .padding(.top, 1)
                        Divider()
                    }
                    VStack {
                        if let storefront = productDetail.storefront,
                            let url = URL(string: storefront.storeURL) {
                            HStack {
                                Spacer()
                                Text("Store Name")
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                                Link(storefront.storeName, destination: url)
                                    .foregroundColor(.blue)
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        }
                        if productDetail.seller.feedbackScore > 0{
                            HStack {
                                Spacer()
                                Text("Feedback Score")
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                                Text("\(productDetail.seller.feedbackScore)")
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        }
                        if productDetail.seller.positiveFeedbackPercent > 0{
                            HStack{
                                Spacer()
                                Text("Popularity")
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                                Text(String(format: "%.2f", productDetail.seller.positiveFeedbackPercent))
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        }
                    }
                    VStack(alignment:.leading) {
                        Divider()
                        HStack {
                            Image(systemName: "sailboat")
                            Text("Shipping Info")
                        }
                        .padding(.bottom, 2)
                        .padding(.top, 1)
                        Divider()
                    }
                    VStack{
                        HStack{
                            if let serviceCost = product.shippingInfo?.shippingServiceCost?.first,
                               let costString = serviceCost.value,
                               let cost = Double(costString) {
                                Spacer()
                                Text("Shipping Cost")
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                                
                                Text(cost == 0 ? "FREE" : "$\(String(format: "%.2f", cost))")
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        }
                        if productDetail.globalShipping == "true" {
                            HStack {
                                Spacer()
                                Text("Global Shipping")
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                                Text("Yes")
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        } else if productDetail.globalShipping == "false" {
                            HStack {
                                Spacer()
                                Text("Global Shipping")
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                                Text("No")
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        }

                        if let handlingTime = product.shippingInfo?.handlingTime?.first {
                            HStack{
                                Spacer()
                                Text("Handling Time")
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                                
                                Text("\(handlingTime) day")
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        }
                    }
                    VStack(alignment:.leading) {
                        Divider()
                        HStack {
                            Image(systemName: "return")
                            Text("Return policy")
                        }
                        .padding(.bottom, 2)
                        .padding(.top, 1)
                        Divider()
                    }
                    VStack{
                        if !productDetail.returnPolicy.returnsAccepted.isEmpty {
                            HStack {
                                Spacer()
                                Text("Policy")
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                                Text(productDetail.returnPolicy.returnsAccepted)
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        }
                        if !productDetail.returnPolicy.refund.isEmpty  {
                            HStack {
                                Spacer()
                                Text("Refund Mode")
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                                Text(productDetail.returnPolicy.refund)
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        }
                        if !productDetail.returnPolicy.returnsWithin.isEmpty {
                            HStack {
                                Spacer()
                                Text("Refund Within")
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                                Text(productDetail.returnPolicy.returnsWithin)
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        }
                        if !productDetail.returnPolicy.shippingCostPaidBy.isEmpty{
                            HStack {
                                Spacer()
                                Text("Shipping Cost Paid By")
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                                Text(productDetail.returnPolicy.shippingCostPaidBy)
                                    .frame(alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .tabItem {
                Image(systemName: "shippingbox")
                Text("Shipping")
            }
            .tag(1)
            
            ScrollView {
                LazyVStack {
                    HStack{
                        Spacer()
                        Text("Powered by")
                        Image("google")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 50) // Example dimensions, adjust as needed
                            .clipped()
                        Spacer()
                    }
                    ForEach(viewModel.photoURLs, id: \.self) { urlString in
                        if let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 120, height: 120)
                                case .success(let image):
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 120, height: 120)
                                        .clipped()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .tabItem{
                Image(systemName: "photo.stack")
                Text("Photos")
            }
            .tag(2)
            Text("Similar products")
                .tabItem{
                    Image(systemName: "list.bullet.indent")
                    Text("Similar")
                }
                .tag(3)
        }
        .onAppear{
            viewModel.fetchProductDetails(itemId: product.itemId)
            viewModel.fetchPhotoURLs(title: product.title)
        }
        .navigationBarItems(trailing: HStack{
            Button(action:{
                if let viewItemURL = viewModel.productDetail?.viewItemURLForNaturalSearch,
                   let url =  URL(string: "https://www.facebook.com/sharer/sharer.php?u=\(viewItemURL)") {
                    UIApplication.shared.open(url)
                }
            }){
                Image("facebook")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                
            }
            Button(action:{productsViewModel.toggleFavorite(for: product.itemId)}){
                Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                                    .imageScale(.large)
            }
        })
    }
    
    private func item(for name: String) -> String? {
        viewModel.productDetail?.itemSpecifics.nameValueList.first { $0.name == name }?.value.first
    }
    
    // Helper view to create a row for the specification
    private func specificationRow(name: String, value: String) -> some View {
        HStack {
            Text(name)
                .font(.headline)
                .fontWeight(.semibold)
                .frame(width: 120, alignment: .leading)
            Text(value)
                .font(.body)
                .frame(alignment: .leading)
        }
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleProduct = Product(
            itemId: "123",
            image: "https://example.com/image.png",
            title: "Sample Product",
            zipcode: "12345",
            price: "$99.99",
            shipping: "Free Shipping",
            conditionId: "1000",
            shippingInfo: ShippingInfo(
                shippingServiceCost: [ShippingServiceCost(currencyId: "USD", value: "0.00")],
                shippingType: ["Standard"],
                shipToLocations: ["Worldwide"],
                expeditedShipping: ["true"],
                oneDayShippingAvailable: ["false"],
                handlingTime: ["1"]
            ),
            returnsAccepted: "true"
        )
        
        let productDetail = ProductDetail(pictureURL: ["https://i.ebayimg.com/00/s/MTMzNVgxNTk5/z/xe0AAOSwumVlaPOZ/$_57.JPG?set_id=880000500F", "https://i.ebayimg.com/00/s/MTQyM1gxNjAw/z/kK0AAOSwWINlaPOi/$_57.JPG?set_id=880000500F", "https://i.ebayimg.com/00/s/MTI4MVgxNjAw/z/m6gAAOSwfVllYpJQ/$_57.JPG?set_id=880000500F", "https://i.ebayimg.com/00/s/MTI2M1gxNjAw/z/rbwAAOSw9HJlYpJP/$_57.JPG?set_id=880000500F", "https://i.ebayimg.com/00/s/MTMyN1gxNjAw/z/BWIAAOSwjp9lYpJQ/$_57.JPG?set_id=880000500F"], itemID: "305286810238", title: "Apple iPhone 13 6.1\" Midnight 256GB FACTORY UNLOCKED GSM/CDMA/5G WARRANTY OPEN", itemSpecifics: ProductDetail.ItemSpecifics(nameValueList: [ProductDetail.NameValueList(name: "Processor", value: ["Hexa Core"]), ProductDetail.NameValueList(name: "Screen Size", value: ["6.1 in"]), ProductDetail.NameValueList(name: "Chipset Model", value: ["Apple A15 Bionic"]), ProductDetail.NameValueList(name: "Color", value: ["Black"]), ProductDetail.NameValueList(name: "MPN", value: ["ML9E3LL/A"]), ProductDetail.NameValueList(name: "Model Number", value: ["A2482 (CDMA + GSM)"]), ProductDetail.NameValueList(name: "Lock Status", value: ["Factory Unlocked"]), ProductDetail.NameValueList(name: "SIM Card Slot", value: ["Single SIM"]), ProductDetail.NameValueList(name: "Brand", value: ["Apple"]), ProductDetail.NameValueList(name: "Manufacturer Warranty", value: ["1 Year"]), ProductDetail.NameValueList(name: "Network", value: ["Unlocked"]), ProductDetail.NameValueList(name: "Model", value: ["Apple iPhone 13"]), ProductDetail.NameValueList(name: "Connectivity", value: ["5G", "Bluetooth", "Wi-Fi", "Lightning", "NFC"]), ProductDetail.NameValueList(name: "Style", value: ["Bar"]), ProductDetail.NameValueList(name: "Operating System", value: ["iOS"]), ProductDetail.NameValueList(name: "Features", value: ["Proximity Sensor", "E-compass", "Gyro Sensor", "Accelerometer", "Ambient Light Sensor", "Barometer", "Ultra Wide-Angle Camera", "eSIM"]), ProductDetail.NameValueList(name: "Storage Capacity", value: ["256 GB"]), ProductDetail.NameValueList(name: "Contract", value: ["Without Contract"]), ProductDetail.NameValueList(name: "Camera Resolution", value: ["12.0 MP"]), ProductDetail.NameValueList(name: "RAM", value: ["4 GB"])]), currentPrice: ProductDetail.Price(value: Optional(569.0)), storefront: Optional(ProductDetail.Storefront(storeURL: "https://www.ebay.com/str/lpta1971", storeName: "lpta1971")), globalShipping: "false", seller: ProductDetail.Seller(userID: "lpta1971", feedbackRatingStar: "Green", feedbackScore: 9308, positiveFeedbackPercent: 100.0, topRatedSeller: true), returnPolicy: ProductDetail.ReturnPolicy(refund: "Money Back", returnsWithin: "30 Days", returnsAccepted: "Returns Accepted", shippingCostPaidBy: "Seller", internationalRefund: "", internationalReturnsWithin: "", internationalReturnsAccepted: "ReturnsNotAccepted", internationalShippingCostPaidBy: ""))
//                ProductDetailView(product: sampleProduct, productDetail:productDetail)
//        ProductDetailView(product: sampleProduct)
    }
}

