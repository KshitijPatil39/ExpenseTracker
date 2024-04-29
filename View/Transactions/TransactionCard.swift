//
//  TransactionCard.swift
//  ExpenseTracker
//
//  Created by Kshitij Patil on 7/28/23.
//

import SwiftUI

struct TransactionCard: View {
    let transaction: AccountsResponse.Transaction
    var domain: String {
        if let name = transaction.merchantName {
            let filteredName = name.filter { !$0.isPunctuation }
            return String(filteredName.filter { !" \n\t\r".contains($0) })
        }
        return ""
    }

    var body: some View {
        VStack(alignment: .leading) {
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

                Spacer()

                Text("$\(String(format: "%.2f", transaction.amount))")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        
    }
}

struct TransactionCard_Previews: PreviewProvider {
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
                    let transaction = try decoder.decode([AccountsResponse.Transaction].self, from: jsonData)
                    return AnyView(TransactionCard(transaction: transaction[0]))
                } catch {
                    print("Error decoding JSON: \(error)")
                    return AnyView(Text("Error decoding JSON"))
                }
    }
}
