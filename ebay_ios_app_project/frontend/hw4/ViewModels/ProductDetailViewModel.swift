import Foundation
import Alamofire
import SwiftyJSON

class ProductDetailViewModel: ObservableObject {
    @Published var productDetail: ProductDetail?
    @Published var photoURLs: [String] = []

    func fetchPhotoURLs(title: String) {
        let urlString = "https://csci571-hw4-node-wl4tgnjsaa-uw.a.run.app/pictures" // Replace with your actual URL
        let parameters: [String: Any] = ["title": title]
        
        AF.request(urlString, parameters: parameters).responseDecodable(of: [String].self) { response in
            switch response.result {
            case .success(let urls):
                DispatchQueue.main.async {
                    self.photoURLs = urls
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchProductDetails(itemId: String) {
        let baseUrl = "https://csci571-hw4-node-wl4tgnjsaa-uw.a.run.app/detail/product"
        var components = URLComponents(string: baseUrl)
        components?.queryItems = [URLQueryItem(name: "itemId", value: itemId)]

        guard let url = components?.url else {
            return
        }

        AF.request(url).responseData { response in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
//                    print(json)
                    // Parse JSON using SwiftyJSON
                    self.parseProductDetail(json: json)
//                    print(self.productDetail)
                case .failure(let error):
                    print("Error fetching product details: \(error.localizedDescription)")
                }
            }
        }
    }

    private func parseProductDetail(json: JSON) {
        // Example of extracting data using SwiftyJSON
        let itemID = json["ItemID"].stringValue
        let title = json["Title"].stringValue
        let viewItemURLForNaturalSearch = json["ViewItemURLForNaturalSearch"].stringValue
        let pictureURL = json["PictureURL"].arrayValue.map { $0.stringValue }
        let currentPriceValue = json["CurrentPrice"]["Value"].floatValue
        let itemSpecifics = parseItemSpecifics(json: json)
        let storefront = parseStorefront(json: json["Storefront"])
        let globalShipping = json["GlobalShipping"].stringValue
        let seller = parseSeller(json: json["Seller"])
        let returnPolicy = parseReturnPolicy(json: json["ReturnPolicy"])

        print("ViewItemURL: " + viewItemURLForNaturalSearch)
        // Constructing ProductDetail object
        let price = ProductDetail.Price(value: currentPriceValue)
        let productDetail = ProductDetail(pictureURL: pictureURL, itemID: itemID, title: title, viewItemURLForNaturalSearch: viewItemURLForNaturalSearch, itemSpecifics: itemSpecifics, currentPrice: price, storefront: storefront, globalShipping: globalShipping, seller:seller, returnPolicy: returnPolicy)

        self.productDetail = productDetail
    }
    private func parseItemSpecifics(json: JSON) -> ProductDetail.ItemSpecifics {
        var nameValueListArray = [ProductDetail.NameValueList]()

        for (_, subJson):(String, JSON) in json["ItemSpecifics"]["NameValueList"] {
            let name = subJson["Name"].stringValue
            let values = subJson["Value"].arrayValue.map { $0.stringValue }
            let nameValueList = ProductDetail.NameValueList(name: name, value: values)
            nameValueListArray.append(nameValueList)
        }

        return ProductDetail.ItemSpecifics(nameValueList: nameValueListArray)
    }
    private func parseStorefront(json: JSON) -> ProductDetail.Storefront? {
        guard let storeURL = json["StoreURL"].string,
              let storeName = json["StoreName"].string else { return nil }
        
        return ProductDetail.Storefront(storeURL: storeURL, storeName: storeName)
    }

    private func parseSeller(json: JSON) -> ProductDetail.Seller {
        return ProductDetail.Seller(
            userID: json["UserID"].stringValue,
            feedbackRatingStar: json["FeedbackRatingStar"].stringValue,
            feedbackScore: json["FeedbackScore"].intValue,
            positiveFeedbackPercent: json["PositiveFeedbackPercent"].doubleValue,
            topRatedSeller: json["TopRatedSeller"].boolValue
        )
    }

    private func parseReturnPolicy(json: JSON) -> ProductDetail.ReturnPolicy {
        return ProductDetail.ReturnPolicy(
            refund: json["Refund"].stringValue,
            returnsWithin: json["ReturnsWithin"].stringValue,
            returnsAccepted: json["ReturnsAccepted"].stringValue,
            shippingCostPaidBy: json["ShippingCostPaidBy"].stringValue,
            internationalRefund: json["InternationalRefund"].stringValue,
            internationalReturnsWithin: json["InternationalReturnsWithin"].stringValue,
            internationalReturnsAccepted: json["InternationalReturnsAccepted"].stringValue,
            internationalShippingCostPaidBy: json["InternationalShippingCostPaidBy"].stringValue
        )
    }

}
