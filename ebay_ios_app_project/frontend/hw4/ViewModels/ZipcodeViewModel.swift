//
//  ZipcodeViewModel.swift
//  hw4
//
//  Created by Frank Wang on 12/7/23.
//

import Foundation
import Combine
import Alamofire
import SwiftyJSON

class ZipcodeViewModel: ObservableObject {
    @Published var zipcodeSuggestions: [String] = []

    private var cancellable: AnyCancellable?
    private let zipcodeSubject = PassthroughSubject<String, Never>()

    init() {
        cancellable = zipcodeSubject
            .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] zipcode in
                print("Debounced zipcode: \(zipcode)")
                self?.fetchZipcodeSuggestions(zipcode: zipcode)
            }
    }

    func sendZipcode(_ zipcode: String) {
        zipcodeSubject.send(zipcode)
    }

    func fetchZipcodeSuggestions(zipcode: String) {
        // Ensure that the zipcode is not empty and has a minimum number of characters
        guard !zipcode.isEmpty && zipcode.count > 0 && zipcode.count < 5 else {
            return
        }
        print(zipcode)
        
        let url = "https://csci571-hw4-node-wl4tgnjsaa-uw.a.run.app/autozip?zip=\(zipcode)"
        AF.request(url).responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let zipArray = json["postalCodes"].arrayObject as? [String] {
                    DispatchQueue.main.async {
                        self.zipcodeSuggestions = zipArray
                        print(self.zipcodeSuggestions)
                    }
                } else {
                    print("Failed to parse zipcode data")
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
