import SwiftUI
import Alamofire
import SwiftyJSON
import Combine

struct SearchFormView: View {
    @State private var keyword: String = ""
    @State private var selectedCategory = "All"
    @State private var conditionUsed = false
    @State private var conditionNew = false
    @State private var conditionUnspecified = false
    @State private var pickup = false
    @State private var freeShipping = false
    @State private var distance: Int = 10
    @State private var distanceText: String = ""
    @State private var useCustomLocation = false
    @State private var customZipcode: String = ""
    @State private var zipcode: String = ""
//    @State private var zipcodeSuggestions:[String] = []
    @State private var debounceTimer: Timer?
    @State private var showKeywordError = false
    @State private var showResults = false
    @ObservedObject var viewModel: ProductsViewModel
    
    @State private var showingSheet = false
    @ObservedObject var zipViewModel = ZipcodeViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Keyword:")
                        Spacer()
                        TextField("Required", text: $keyword)
                    }
                    .padding(.top,5)
                    
                    VStack {
                        HStack {
                            Text("Category")
                            Picker("", selection: $selectedCategory) {
                                Text("All").tag("All")
                                // Add other categories here
                                Text("Art").tag("Art")
                                Text("Baby").tag("Baby")
                                Text("Books").tag("Books")
                                Text("Clothing,Shoes & Accessories").tag("Clothing,Shoes & Accessories")
                                Text("Computers/Tablets & Networking").tag("Computers/Tablets & Networking")
                                Text("Health & Beauty").tag("Health & Beauty")
                                Text("Music").tag("Music")
                                Text("Video Games & Consoles").tag("Video Games & Consoles")
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }.padding(.vertical,1)
                    
                    VStack(alignment: .leading){
                        Spacer()
                        Text("Condition")
                        Spacer()
                        HStack(){
                            Toggle(isOn: $conditionUsed) {
                            }.toggleStyle(CheckboxStyle())
                            Text("Used").fixedSize()
                            Toggle(isOn: $conditionNew) {
                            }.toggleStyle(CheckboxStyle())
                            Text("New").fixedSize()
                            Toggle(isOn: $conditionUnspecified) {
                            }.toggleStyle(CheckboxStyle())
                            Text("Unspecified").fixedSize()
                        }
                        Spacer()
                    }.padding(.vertical,1)
                    VStack(alignment: .leading){
                        Spacer()
                        Text("Shipping")
                        Spacer()
                        HStack(){
                            Toggle(isOn: $pickup) {
                            }.toggleStyle(CheckboxStyle())
                            Text("Pickup").fixedSize()
                            Toggle(isOn: $freeShipping) {
                            }.toggleStyle(CheckboxStyle())
                            Text("Free Shipping").fixedSize()
                            Spacer(minLength:10)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading,0)
                        Spacer()
                    }.padding(.vertical,1)
                    HStack{
                        Text("Distance:")
                        Spacer()
                        TextField("10",text: $distanceText)
                            .keyboardType(.decimalPad)
                            .onChange(of: distanceText){
                                updateDistance();
                            }
                        
                    }
                    VStack(alignment: .leading){
                        HStack{
                            Text("Custom location")
                            Spacer()
                            Toggle(isOn:$useCustomLocation){
                            }.onChange(of: useCustomLocation){ fetchZipcode()
                            }
                            .labelsHidden()
                        }
                        .padding(.vertical,1)
                        if useCustomLocation{
                            HStack{
                                Text("Zipcode:")
                                Spacer()
//                                TextField("Required",text:$customZipcode)
//                                    .onTapGesture {
//                                        debounceTimer?.invalidate()
//                                        debounceTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
//                                            fetchZipcodeSuggestions(for: customZipcode)
//                                        }
//                                    }
                                TextField("Required", text: $customZipcode)
                                    .onChange(of: customZipcode){old, newZip in
                                        debounceTimer?.invalidate()
                                        debounceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false){ _ in
                                            if newZip.count < 5{
                                                zipViewModel.fetchZipcodeSuggestions(zipcode: newZip)
                                                print("Sending zipcode to ViewModel: \(newZip)")
                                                if !customZipcode.isEmpty {
                                                    showingSheet = true
                                                }
                                            }
                                        }
                                    }
                                    .sheet(isPresented: $showingSheet) {
                                        ZipcodeSuggestionsView(zipViewModel: zipViewModel) { selectedZipcode in
                                            customZipcode = selectedZipcode
                                            showingSheet = false
                                        }
                                    }
                                
                                    
                            }
                            .padding(.vertical,1)
                        }
                    }
                    .padding(.vertical,1)
                    
                    
                    // Submit and Clear buttons
                    HStack {
                        Spacer(minLength: 20)
                        Button("Submit", action: {
                            // Handle submit action
                            // Close the keyboard if open
                            UIApplication.shared.endEditing()
                            print("keyword: " + keyword)
                            print("category: " + selectedCategory)
                            print("Used: " + String(conditionUsed))
                            print("New: " + String(conditionNew))
                            print("Specified: " + String(conditionUnspecified))
                            print("pickup: " + String(pickup))
                            print("freeshipping: " + String(freeShipping))
                            print("distance: " + String(distance))
                            if !useCustomLocation{
                                print("zipcode: " + zipcode)
                            }else{
                                print("custom zipcode: " + customZipcode)
                            }
                            if keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                print("Keyword is empty")
                                showKeywordError = true
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                    withAnimation {
//                                        showKeywordError = false
//                                    }
//                                }
                            } else {
                                showKeywordError = false
                                // Handle condition parameters
                                var conditions = [String]()
                                if conditionUsed { conditions.append("\"Used\"") }
                                if conditionNew { conditions.append("\"New\"") }
                                if conditionUnspecified { conditions.append("\"Unspecified\"") }
                                
                                // Handle shipping parameters
                                var shippings = [String]()
                                if pickup { shippings.append("\"Local Pickup\"") }
                                if freeShipping { shippings.append("\"Free Shipping\"") }
                                
                                viewModel.searchProducts(keyword: keyword, category: selectedCategory, conditions: conditions, shippings: shippings, distance: distance, customZipcode: customZipcode, useCustomLocation: useCustomLocation,zipcode:zipcode){
                                    showResults = true
                                }
                            }
                        })
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        Spacer(minLength: 30)
                        Button("Clear", action: {
                            // Handle clear action
                            keyword = ""
                            selectedCategory = "All"
                            conditionUsed = false
                            conditionNew = false
                            conditionUnspecified = false
                            pickup = false
                            freeShipping = false
                            distance = 10
                            distanceText = ""
                            useCustomLocation = false
                            customZipcode = ""
//                            zipcodeSuggestions = []
                            
                            showKeywordError = false
                            showResults = false
                            viewModel.products.removeAll()
                            
                        })
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        Spacer(minLength: 20)
                    }
                    .padding(.bottom)
                    
                }
                .onAppear(){
                    fetchZipcode()
                }
                .navigationBarTitle("Product Search", displayMode: .large)
                .navigationBarItems(trailing: NavigationLink(destination:FavoritesView(productsViewModel: viewModel)){
                    Image(systemName: "heart.circle")
                        .imageScale(.large)
                })
                
                Section {
                    if showResults {
                        Text("Results")
                            .font(.title).bold()
                        if !viewModel.products.isEmpty{
                            ForEach(viewModel.products) { product in
                                NavigationLink(destination:
                                                ProductDetailView(product: product, productsViewModel: viewModel)
                                ) {
                                    HStack {
                                        // AsyncImage to load an image from a URL
                                        AsyncImage(url: URL(string: product.image)) { image in
                                            image.resizable() // Make the image resizable
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 70, height: 70) // Set the frame for the image
                                        .cornerRadius(6)
                                        
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
                                            Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                                                .foregroundColor(.red)
                                                .imageScale(.large)
                                                .onTapGesture{
                                                    print("Button Clicked!!!")
                                                    print()
                                                    viewModel.toggleFavorite(for: product.itemId)
                                                }
                                        }
                                    }
                                }
                            }
                        }else{
                            Text("No results found")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                if showKeywordError {
                    let message = "Keyword is mandatory"
                    MessageView(message: message)
                }
            }
        }
    }
    
    private func updateDistance(){
        if let value = Int(distanceText){
            distance = value
            print("Updated distance value: \(distance)")
        }
    }
    private func fetchZipcode(){
        let url = "https://ipinfo.io/json?token=a64f51fae9465c"
        AF.request(url).response{ response in
            switch response.result{
            case .success(let data):
                if let data = data{
                    let json = JSON(data)
                    let postalCode = json["postal"].stringValue
                    DispatchQueue.main.async{
                        self.zipcode = postalCode
                    }
                    print("fetch executed: " + self.zipcode)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
//    private func fetchZipcodeSuggestions(for zipcode:String){
//
//        AF.request(url).responseData{response in
//            switch response.result{
//            case .success(let data):
//                let json = JSON(data)
//                let postalCodesArray = json["postalCodes"].arrayValue
//                let zipcodes = postalCodesArray.map { $0["postalCode"].stringValue }
//                DispatchQueue.main.async {
//                    self.zipcodeSuggestions = zipcodes
//                }
//                print(zipcodeSuggestions)
//            case .failure(let error):
//                print("Request error: \(error.localizedDescription)")
//            }
//            
//        }
//    }
    

}
// Define the checkbox style here
struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        return HStack {
            configuration.label
            
            Spacer()
            
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .blue : .primary)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}
//struct SearchFormView_Previews: PreviewProvider {
//    static var previews: some View {
//        let viewModel = ProductsViewModel()
//        SearchFormView(viewModel: viewModel)
//    }
//}
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct MessageView: View {
    @State var message: String
    var body: some View {
        HStack{
            Spacer()
            Text(message)
                .foregroundColor(.white)
                .padding()
            //                            .frame(maxWidth: .greatestFiniteMagnitude)
                .background(Color.black.opacity(0.75))
                .cornerRadius(10)
                .transition(.slide)
                .zIndex(1)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

struct ZipcodeSuggestionsView: View {
    @ObservedObject var zipViewModel: ZipcodeViewModel
    var onSelect: (String) -> Void

    var body: some View {
        NavigationView {
            List(zipViewModel.zipcodeSuggestions, id: \.self) { zipcode in
                Button(action: {
                    onSelect(zipcode)
                }) {
                    Text(zipcode)
                        .foregroundColor(.black) // Set font color to black
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Pincode suggestions")
                        .font(.title)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.black)
                }
            }
            .navigationBarItems(trailing: Button("Done") {
            })
        }
    }
}


