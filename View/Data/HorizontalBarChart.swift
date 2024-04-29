////
////  HorizontalBarChart.swift
////  ExpenseTracker
////
////  Created by Kshitij Patil on 8/2/23.
////
//
//import SwiftUI
//
//struct HorizontalBarChart: View {
//    @Binding var transactions: [AccountsResponse.Transaction]
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            ForEach(dataPoints) { bar in
//                HStack {
//                    RoundedRectangle(cornerRadius: 8, style: .continuous)
//                        .foregroundColor(bar.legend.color)
//                        .frame(width: CGFloat(bar.endValue / self.max) * barMaxWidth, height: 16)
//                    
//                    Circle()
//                        .foregroundColor(bar.legend.color)
//                        .frame(width: 8, height: 8)
//                    
//                    Text(bar.legend.label) + Text(", ") + Text(bar.label)
//                    
//                    // TODO: temp fix
//                    Spacer()
//                }
//            }
//        }
//    }
//}
//
//struct HorizontalBarChart_Previews: PreviewProvider {
//    static var previews: some View {
//        let jsonData = """
//                [{
//                    "account_id": "JLZZrq6Rlkh57ZvyPL9QTMxlQkPG4BiBQplEW",
//                    "account_owner": null,
//                    "amount": 500,
//                    "authorized_date": null,
//                    "authorized_datetime": null,
//                    "category": [
//                        "Travel",
//                        "Airlines and Aviation Services"
//                    ],
//                    "category_id": "22001000",
//                    "check_number": null,
//                    "date": "2023-05-15",
//                    "datetime": null,
//                    "iso_currency_code": "USD",
//                    "location": {
//                        "address": null,
//                        "city": null,
//                        "country": null,
//                        "lat": null,
//                        "lon": null,
//                        "postal_code": null,
//                        "region": null,
//                        "store_number": null
//                    },
//                    "merchant_name": "United Airlines",
//                    "name": "United Airlines",
//                    "payment_channel": "in store",
//                    "pending": false,
//                    "pending_transaction_id": null,
//                    "personal_finance_category": {
//                        "detailed": "TRAVEL_FLIGHTS",
//                        "primary": "TRAVEL"
//                    },
//                    "transaction_code": null,
//                    "transaction_id": "eEKKkG3QA6TjNWxV5edKT7aG6bvJmWcrarNby",
//                    "transaction_type": "special",
//                    "unofficial_currency_code": null
//                }]
//                """.data(using: .utf8)!
//        let decoder = JSONDecoder()
//        do {
//            let transaction = try decoder.decode([AccountsResponse.Transaction].self, from: jsonData)
//            return AnyView(HorizontalBarChart(transactions: .constant(transaction)))
//        } catch {
//            print("Error decoding JSON: \(error)")
//            return AnyView(Text("Error decoding JSON"))
//        }
//    }
//}
