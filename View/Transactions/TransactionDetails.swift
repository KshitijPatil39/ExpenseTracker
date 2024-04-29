import SwiftUI
import MapKit

struct TransactionDetails: View {
    let transaction: AccountsResponse.Transaction
    var val: String {
        if(transaction.pending){
            return "Pending"
        } else {
            return "On your statement as \(transaction.merchantName ?? transaction.name)"
        }
    }
    var latitude: CLLocationDegrees {
        transaction.location.lat!
    }
    var longitude: CLLocationDegrees {
        transaction.location.lon!
    }
    
    var domain: String {
        if let name = transaction.merchantName {
            let filteredName = name.filter { !$0.isPunctuation }
            return String(filteredName.filter { !" \n\t\r".contains($0) })
        }
        return ""
    }
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                            Section(header: Text(transaction.personalFinanceCategory.primary).font(.subheadline)) {
                                VStack(alignment:.leading, spacing: 8) {
                                    HStack {
                                       
                                        if !domain.isEmpty{
                                            AsyncImage(url: URL(string: "https://logo.clearbit.com/\(domain).com?size=30")) { image in
                                                // Image loaded successfully
                                                image
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                            } placeholder: {
                                                // Placeholder image or text when loading
                                                Image(systemName: "dollarsign")
                                                    .foregroundColor(.gray)
                                            }
                                            .frame(width: 30, height: 30)
                                        }
                                        Text(transaction.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("$\(String(format: "%.2f", transaction.amount))")
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Text("\(formattedDate)")
                                        .font(.subheadline)
                                    Text("\(val)")
                                    Text("Payment mode: \(transaction.paymentChannel)")
                                    
                                }
                                .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                                
                            }
                            .padding()
                            Divider()
                            Section(header: Text("Store details")){
                                if let lat = transaction.location.lat, let lon = transaction.location.lon {
                                    MapView(lat: lat, long: lon)
                                        .frame(height: 300)
                                } else {
                                    Text("Location not available")
                                        .foregroundColor(.red)
                                }
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                
                                Text(transaction.location.address ?? "Address not available")
                                Text(transaction.location.city ?? "City not available")
                                Text(transaction.location.region ?? "Region not available")
                                Text(transaction.location.postalCode ?? "Postal code not available")
                                Text(transaction.location.storeNumber ?? "Store number not available")
                                    .foregroundColor(.blue)
                                
                                
                            }
                            .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 0))
                            
                        }
                .padding()
            }
            }
        
        .toolbar(.hidden, for: .tabBar)
        
    }
    
    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: Date()) // Replace Date() with your actual transaction date
    }
    
}

struct TransactionDetails_Previews: PreviewProvider {
    static var previews: some View {
        let jsonData = """
        [
            {
              "account_id": "BxBXxLj1m4HMXBm9WZZmCWVbPjX16EHwv99vp",
              "amount": 2307.21,
              "iso_currency_code": "USD",
              "unofficial_currency_code": null,
              "category": [
                "Shops",
                "Computers and Electronics"
              ],
              "category_id": "19013000",
              "check_number": null,
              "date": "2017-01-29",
              "datetime": "2017-01-27T11:00:00Z",
              "authorized_date": "2017-01-27",
              "authorized_datetime": "2017-01-27T10:34:50Z",
              "location": {
                "address": "300 Post St",
                "city": "San Francisco",
                "region": "CA",
                "postal_code": "94108",
                "country": "US",
                "lat": 40.740352,
                "lon": -74.001761,
                "store_number": "1235"
              },
              "name": "Apple Store",
              "merchant_name": "Apple",
              "payment_meta": {
                "by_order_of": null,
                "payee": null,
                "payer": null,
                "payment_method": null,
                "payment_processor": null,
                "ppd_id": null,
                "reason": null,
                "reference_number": null
              },
              "payment_channel": "in store",
              "pending": false,
              "pending_transaction_id": null,
              "personal_finance_category": {
                "primary": "GENERAL_MERCHANDISE",
                "detailed": "GENERAL_MERCHANDISE_ELECTRONICS"
              },
              "account_owner": null,
              "transaction_id": "lPNjeW1nR6CDn5okmGQ6hEpMo4lLNoSrzqDje",
              "transaction_code": null,
              "transaction_type": "place"
            }
          ]
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        do {
            let transaction = try decoder.decode([AccountsResponse.Transaction].self, from: jsonData)
            return AnyView(TransactionDetails(transaction: transaction[0]))
        } catch {
            print("Error decoding JSON: \(error)")
            return AnyView(Text("Error decoding JSON"))
        }
    }
}
