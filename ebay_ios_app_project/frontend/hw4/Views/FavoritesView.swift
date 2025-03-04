//
//  FavoritesView.swift
//  hw4
//
//  Created by Frank Wang on 12/5/23.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject var viewModel = FavoriteProductsViewModel()
    @ObservedObject var productsViewModel: ProductsViewModel
    var body: some View {
        NavigationView{
            List{
                HStack{
                    Text("WishList total(\(viewModel.products.count)) items:")
                    Spacer()
                    Text("$\(calculateTotalPrice())")
                }
                ForEach(viewModel.products){ product in
                    HStack {
                        // AsyncImage to load an image from a URL
                        AsyncImage(url: URL(string: product.image)) { image in
                            image.resizable() // Make the image resizable
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 70, height: 70) // Set the frame for the image
                        .cornerRadius(6) // Optional: if you want to have rounded corners
                        
                        VStack {
                            HStack{
                                VStack(alignment: .leading) {
                                    Text(product.title)
                                        .lineLimit(1)
                                        .font(.footnote)
                                        .frame(alignment: .leading)
                                    
                                    Text("\(product.price)")
                                        .font(.footnote).bold()
                                        .foregroundColor(.blue)
                                    
                                    // Other product details
                                    Text(product.shipping.uppercased())
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                    
                                    HStack {
                                        Text(product.zipcode)
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text(product.condition)
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let productPojo = viewModel.products[index]
                        if let product = productsViewModel.products.first(where: { $0.itemId == productPojo.productId }) {
                            removeProduct(product)
                        }
                    }
                }
            }
        }
        .navigationTitle("Favorites")
        .onAppear {
            viewModel.fetchFavoriteProducts()
        }
        
    }
    func calculateTotalPrice() -> String {
        let total = viewModel.products.reduce(0) { sum, product in
            let priceWithoutDollarSign = product.price.dropFirst() // Remove the first character (the dollar sign)
            return sum + (Double(priceWithoutDollarSign) ?? 0)
        }
        return String(format: "%.2f", total)
    }
    func removeProduct(_ product: Product) {
        productsViewModel.toggleFavorite(for: product.itemId)
        // You might want to also update the UI to reflect the change immediately
        viewModel.products.removeAll { $0.productId == product.itemId }
    }

    
}
//#Preview {
//    FavoritesView()
//}

