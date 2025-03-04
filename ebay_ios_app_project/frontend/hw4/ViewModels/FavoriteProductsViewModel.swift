//
//  FavoriteProductsViewModel.swift
//  hw4
//
//  Created by Frank Wang on 12/5/23.
//

import Foundation
import Alamofire
import SwiftyJSON
class FavoriteProductsViewModel: ObservableObject {
    @Published var products: [ProductPojo] = []

    func fetchFavoriteProducts() {
        let url = "https://csci571-hw4-node-wl4tgnjsaa-uw.a.run.app/favorites"
        
        AF.request(url).response { response in
            switch response.result {
            case .success(let data):
                if let data = data {
                    let json = JSON(data)
                    print(json)
                    if let productArray = json.array {
                        self.products = productArray.map { ProductPojo(json: $0) }
                    }
                }
                print(self.products)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
