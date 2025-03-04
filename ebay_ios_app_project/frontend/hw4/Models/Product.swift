//
//  Product.swift
//  hw4
//
//  Created by Frank Wang on 11/27/23.
//

import Foundation
struct ShippingServiceCost: Decodable {
    var currencyId: String?
    var value: String?

    enum CodingKeys: String, CodingKey {
        case currencyId = "@currencyId"
        case value = "__value__"
    }
}
struct ShippingInfo: Decodable {
    var shippingServiceCost: [ShippingServiceCost]?
    var shippingType: [String]?
    var shipToLocations: [String]?
    var expeditedShipping: [String]?
    var oneDayShippingAvailable: [String]?
    var handlingTime: [String]?
}

struct Product: Decodable, Identifiable{
    
    let itemId: String
    let image: String
    let title: String
    let zipcode: String
    let price: String
    let shipping: String
    let conditionId: String
    var shippingInfo: ShippingInfo?
    var returnsAccepted: String
    var id: String{itemId}
    var condition: String {
        switch conditionId {
        case "1000":
            return "NEW"
        case "2000", "2500":
            return "REFURBISHED"
        case "3000", "4000", "5000", "6000":
            return "USED"
        default:
            return "NA"
        }
    }
    var isFavorite: Bool = false
}
