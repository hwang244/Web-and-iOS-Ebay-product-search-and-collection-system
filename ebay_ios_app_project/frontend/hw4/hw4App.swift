//
//  hw4App.swift
//  hw4
//
//  Created by Frank Wang on 11/27/23.
//

import SwiftUI

@main
struct hw4App: App {
    @StateObject var viewModel = ProductsViewModel()

    var body: some Scene {
        WindowGroup {
            VStack(spacing: 0) {
                SearchFormView(viewModel: viewModel)
            }
            
        }
    }
}
