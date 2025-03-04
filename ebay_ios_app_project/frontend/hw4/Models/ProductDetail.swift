//
//  ProductDetail.swift
//  hw4
//
//  Created by Frank Wang on 12/2/23.
//

import Foundation
struct ProductDetail: Decodable {
    var pictureURL: [String]
    var itemID: String
    var title: String
    var viewItemURLForNaturalSearch: String?
    var itemSpecifics: ItemSpecifics
    var currentPrice: Price
    var storefront: Storefront?
    var globalShipping: String
    var seller: Seller
    var returnPolicy: ReturnPolicy
    
    var brand: String? {
        itemSpecifics.value(for: "Brand")
    }
    
    var color: String? {
        itemSpecifics.value(for: "Color")
    }
    
    var formattedPrice: String {
        if let value = currentPrice.value {
            return "$\(value)"
        } else {
            return "N/A"
        }
    }

    struct Price: Decodable {
        var value: Float?
    }

    struct ItemSpecifics: Decodable {
        var nameValueList: [NameValueList]
        
        func value(for name: String) -> String? {
            nameValueList.first { $0.name == name }?.value.first
        }
        enum CodingKeys: String, CodingKey {
            case nameValueList = "NameValueList"
        }
    }

    struct NameValueList: Decodable {
        var name: String
        var value: [String]
        enum CodingKeys: String, CodingKey {
            case name = "Name"
            case value = "Value"
        }
    }
    struct Storefront: Decodable {
            var storeURL: String
            var storeName: String
    }
    struct Seller: Decodable {
        var userID: String
        var feedbackRatingStar: String
        var feedbackScore: Int
        var positiveFeedbackPercent: Double
        var topRatedSeller: Bool
    }
    struct ReturnPolicy: Decodable {
            var refund: String
            var returnsWithin: String
            var returnsAccepted: String
            var shippingCostPaidBy: String
            var internationalRefund: String
            var internationalReturnsWithin: String
            var internationalReturnsAccepted: String
            var internationalShippingCostPaidBy: String
    }
    enum CodingKeys: String, CodingKey {
        case pictureURL, itemID, title, itemSpecifics, currentPrice, globalShipping
        case storefront = "Storefront"
        case seller = "Seller"
        case returnPolicy = "ReturnPolicy"
    }
}


