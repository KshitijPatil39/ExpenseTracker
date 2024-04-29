//
//  ListView.swift
//  ExpenseTracker
//
//  Created by Kshitij Patil on 7/31/23.
//

//
//  TransactionView.swift
//  ExpenseTracker
//
//  Created by Kshitij Patil on 7/28/23.
//

import SwiftUI

struct ListView: View {
   var transactions: [AccountsResponse.Transaction]
    
    var body: some View {
        NavigationStack {
            List {
                        ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                            
                            Section(header: Text(formatDate(date)).font(.headline)) {
                                ForEach(groupedTransactions[date]!) { transaction in
                                        TransactionCard(transaction: transaction)
                                        .overlay(NavigationLink(destination: TransactionDetails(transaction: transaction), label: {EmptyView()})
                                            .opacity(0))
                                    
                                }
                            }
                        }
                    }
            .navigationTitle("Transactions")
           
        }
        
    }
    
    var groupedTransactions: [String: [AccountsResponse.Transaction]] {
            return Dictionary(grouping: transactions, by: { $0.date })
       
        
        }
    func formatDate(_ date: String) -> String {
        let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                if let date = dateFormatter.date(from: date) {
                    dateFormatter.dateFormat = "MMM, dd"
                    return dateFormatter.string(from: date)
                }
                return ""
        }
    
    
    
    
    

}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        let jsonData = """
                [{
                    "account_id": "JLZZrq6Rlkh57ZvyPL9QTMxlQkPG4BiBQplEW",
                    "account_owner": null,
                    "amount": 500,
                    "authorized_date": null,
                    "authorized_datetime": null,
                    "category": [
                        "Travel",
                        "Airlines and Aviation Services"
                    ],
                    "category_id": "22001000",
                    "check_number": null,
                    "date": "2023-05-15",
                    "datetime": null,
                    "iso_currency_code": "USD",
                    "location": {
                        "address": null,
                        "city": null,
                        "country": null,
                        "lat": null,
                        "lon": null,
                        "postal_code": null,
                        "region": null,
                        "store_number": null
                    },
                    "merchant_name": "United Airlines",
                    "name": "United Airlines",
                    "payment_channel": "in store",
                    "pending": false,
                    "pending_transaction_id": null,
                    "personal_finance_category": {
                        "detailed": "TRAVEL_FLIGHTS",
                        "primary": "TRAVEL"
                    },
                    "transaction_code": null,
                    "transaction_id": "eEKKkG3QA6TjNWxV5edKT7aG6bvJmWcrarNby",
                    "transaction_type": "special",
                    "unofficial_currency_code": null
                }]
                """.data(using: .utf8)!
        let decoder = JSONDecoder()
                do {
                    let transactions = try decoder.decode([AccountsResponse.Transaction].self, from: jsonData)
                    return AnyView(TransactionView(transactions: .constant(transactions)))
                } catch {
                    print("Error decoding JSON: \(error)")
                    return AnyView(Text("Error decoding JSON"))
                }
    }
}

