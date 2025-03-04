//
//  ProductsViewModel.swift
//  hw4
//
//  Created by Frank Wang on 11/27/23.
//

import Foundation
import Alamofire
import SwiftyJSON
struct ServerResponse: Codable {
    let message: String
}

class ProductsViewModel: ObservableObject {
    @Published var products: [Product] = []

    func searchProducts(keyword: String, category: String, conditions: [String], shippings: [String], distance: Int, customZipcode: String, useCustomLocation: Bool, zipcode:String,completion: @escaping () -> Void) {
        let baseUrl = "https://csci571-hw4-node-wl4tgnjsaa-uw.a.run.app/search"
        var components = URLComponents(string: baseUrl)
        var queryItems = [URLQueryItem]()
        
        // Add query items
        queryItems.append(URLQueryItem(name: "keyword", value: keyword))
        queryItems.append(URLQueryItem(name: "category", value: category))
        // Add other parameters as needed...
        let conditionsString = "[" + conditions.joined(separator: ",") + "]"
        queryItems.append(URLQueryItem(name: "conditions", value: conditionsString))
        let shippingString = "[" + shippings.joined(separator: ",") + "]"
        queryItems.append(URLQueryItem(name: "shippings", value: shippingString))
        queryItems.append(URLQueryItem(name: "distance", value: String(distance)))
        if useCustomLocation {
            queryItems.append(URLQueryItem(name: "zipcode", value: customZipcode))
        } else {
            queryItems.append(URLQueryItem(name: "zipcode", value: zipcode))
        }
        
        components?.queryItems = queryItems

        // Ensure the URL is valid
        guard let url = components?.url else { return }
        print("URL being requested: \(url.absoluteString)")

        // Send HTTP request and handle response
        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                do{
                    // Parse data with SwiftyJSON
                    let json = JSON(data)
                    // Print the JSON object
//                    print("JSON Response: \(json)")
                    
                    var parsedProducts: [Product] = []
                    for productJson in json.arrayValue{
                        let shippingInfoJson = productJson["shippingInfo"]
                        let shippingInfo = ShippingInfo(
                            shippingServiceCost: shippingInfoJson["shippingServiceCost"].arrayValue.compactMap { costJson in
                                ShippingServiceCost(
                                    currencyId: costJson["@currencyId"].string,
                                    value: costJson["__value__"].string
                                )
                            },
                            shippingType: shippingInfoJson["shippingType"].arrayValue.compactMap { $0.string },
                            shipToLocations: shippingInfoJson["shipToLocations"].arrayValue.compactMap { $0.string },
                            expeditedShipping: shippingInfoJson["expeditedShipping"].arrayValue.compactMap { $0.string },
                            oneDayShippingAvailable: shippingInfoJson["oneDayShippingAvailable"].arrayValue.compactMap { $0.string },
                            handlingTime: shippingInfoJson["handlingTime"].arrayValue.compactMap { $0.string }
                        )
                        
                        let product = Product(
                            itemId: productJson["itemId"].stringValue,
                            image: productJson["image"].stringValue,
                            title: productJson["title"].stringValue,
                            zipcode: productJson["zipcode"].stringValue,
                            price: productJson["price"].stringValue,
                            shipping: productJson["shipping"].stringValue,
                            conditionId: productJson["condition"][0]["conditionId"][0].stringValue,
                            shippingInfo: shippingInfo,
                            returnsAccepted: productJson["returnsAccepted"].stringValue
                        )
                        parsedProducts.append(product)
//                        print(product)
                    }
                    DispatchQueue.main.async {
                        self.products = parsedProducts
                        self.fetchFavoritesStatus()
                        completion()
                    }
                }
            case .failure(let error):
                // Handle error
                print("Error: \(error.localizedDescription)")
                completion()
            }
        }
    }
    func toggleFavorite(for productId: String) {
        if let index = products.firstIndex(where: { $0.itemId == productId }) {
            // Toggle the favorite status
            products[index].isFavorite.toggle()
            // Now update the backend
            updateFavoriteStatus(for: products[index], isFavorite: products[index].isFavorite)
        }
    }
    func fetchFavoritesStatus() {
        let productIds = products.map { $0.itemId }
        let productIdsString = productIds.joined(separator: ",")
        print(productIdsString)
        
        // Send HTTP request to your server
        let url = "https://csci571-hw4-node-wl4tgnjsaa-uw.a.run.app/areFavorites?productIds=\(productIdsString)"
        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let json = try JSON(data: data)
                    var favoritesArray: [Bool] = []
                    
                    // Assuming the JSON array contains boolean values
                    if let jsonArray = json.array {
                        favoritesArray = jsonArray.map { $0.boolValue }
                    }
                    
                    for (index, _) in self.products.enumerated() {
                        if index < favoritesArray.count {
                            self.products[index].isFavorite = favoritesArray[index]
                        }
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func updateFavoriteStatus(for product: Product, isFavorite: Bool) {
        if isFavorite {
            addToFavorites(product: product)
        } else {
            removeFromFavorites(productId: product.itemId)
        }
    }

    private func addToFavorites(product: Product) {
        let favoriteProduct = ProductPojo(productId: product.itemId,
                                          image: product.image,
                                          title: product.title,
                                          shipping: product.shipping,
                                          zipcode: product.zipcode,
                                          price: product.price,
                                          condition: product.condition)
        
        let url = "https://csci571-hw4-node-wl4tgnjsaa-uw.a.run.app/addToFavorites"
        
        AF.request(url, method: .post, parameters: favoriteProduct, encoder: JSONParameterEncoder.default).responseDecodable(of: ServerResponse.self) { response in
            switch response.result {
            case .success(let serverResponse):
                let json = JSON(serverResponse)
                if json["message"].stringValue == "Added to favorites" {
                    // Update the local favorite status
                    self.setFavoriteStatus(for: product.itemId, isFavorite: true)
                }
            case .failure(let error):
                print("Error adding to favorites: \(error)")
            }
        }
    }
    private func removeFromFavorites(productId: String) {
        let url = "https://csci571-hw4-node-wl4tgnjsaa-uw.a.run.app/removeFromFavorites"
        let parameters = ["productId": productId]
        
        AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).responseDecodable(of: ServerResponse.self) { response in
            switch response.result {
            case .success(let serverResponse):
                let json = JSON(serverResponse)
                // Handle the JSON response
                if json["message"].stringValue == "Removed from favorites" {
                    // Update the local favorite status
                    self.setFavoriteStatus(for: productId, isFavorite: false)
                    print("product removed!")
                }
            case .failure(let error):
                print("Error removing from favorites: \(error)")
            }
        }
    }
    private func setFavoriteStatus(for productId: String, isFavorite: Bool) {
        if let index = products.firstIndex(where: { $0.itemId == productId }) {
            DispatchQueue.main.async {
                self.products[index].isFavorite = isFavorite
            }
        }
    }
    
}

