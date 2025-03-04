//
//  ProductPojo.swift
//  hw4
//
//  Created by Frank Wang on 12/5/23.
//

import Foundation
import SwiftyJSON
struct ProductPojo: Codable, Identifiable{
    let productId: String
    let image: String
    let title: String
    let shipping: String
    let zipcode: String
    let price: String
    let condition: String
    var id: String{productId}
}

extension ProductPojo {
    init(json: JSON) {
        self.productId = json["productId"].stringValue
        self.image = json["image"].stringValue
        self.title = json["title"].stringValue
        self.shipping = json["shipping"].stringValue
        self.zipcode = json["zipcode"].stringValue
        self.price = json["price"].stringValue
        self.condition = json["condition"].stringValue
    }
}

