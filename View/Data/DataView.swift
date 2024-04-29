//
//  DataView.swift
//  ExpenseTracker
//
//  Created by Kshitij Patil on 7/29/23.
//

import SwiftUI

struct DataView: View {
    @Binding var transactions: [AccountsResponse.Transaction]
    @State private var selectedTopTransactionsCount: Int = 5
    @State private var selectedOption: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker(selection: $selectedOption, label: Text("Select Option")) {
                    Text("Transactions").tag(0)
                    Text("Categories").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                if let mostOccurredTransactions = aggregateMostOccurredTransactions()?.prefix(selectedTopTransactionsCount) {
                    if selectedOption == 0 {
                        List {
                            Section(header: sectionHeader) {
                                ForEach(mostOccurredTransactions) { transaction in
                                    HStack {
                                        
                                        
                                        AsyncImage(url: transaction.imgurl) { image in
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
                                        
                                        
                                        
                                        Text(transaction.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Text("$\(String(format: "%.2f", transaction.totalAmount))")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                    }
                                    .overlay(NavigationLink(destination: ListView(transactions: filterTransactions(transactionName: transaction.name)), label: {EmptyView()})
                                        .opacity(0))
                                    
                                    
                                    
                                }
                                .textCase(.none)
                                
                            }
                            .listStyle(PlainListStyle())
                            
                        }
                    } else {
                        if let mostOccurredCategories = aggregateMostOccurredCategories() {
//                            List {
//                                Section(header: sectionHeader) {
//                                    ForEach(mostOccurredCategories) { category in
//
//                                        HStack {
//
//                                            Text(category.name)
//                                                .font(.headline)
//                                                .foregroundColor(.primary)
//
//                                            Spacer()
//
//                                            Text("$\(String(format: "%.2f", category.totalAmount))")
//                                                .font(.subheadline)
//                                                .foregroundColor(.blue)
//                                        }
//                                        .overlay(NavigationLink(destination: ListView(transactions: filterCategories(transactionName: category.name)), label: {EmptyView()})
//                                            .opacity(0))
//
//
//                                    }
//                                    .textCase(.none)
//
//                                }
//                                .listStyle(PlainListStyle())
//
//                            }
                            ChartView(categories: Array(mostOccurredCategories.prefix(6)))
                        }
                    }
                    
                } else {
                    Text("No most occurred transactions found.")
                        .foregroundColor(.gray)
                }
                
                
                
            }
            .navigationTitle("Data")
        }
        .onAppear {
            // Set the selectedTopTransactionsCount to 5 when the "Data" tab appears
            if (selectedTopTransactionsCount != 10) {
                selectedTopTransactionsCount = 5
            }
        }
    }
    
    func filterTransactions(transactionName: String) -> [AccountsResponse.Transaction] {
        return transactions.filter ({ $0.name == transactionName })
    }
    
    func filterCategories(transactionName: String) -> [AccountsResponse.Transaction] {
        return transactions.filter ({ $0.personalFinanceCategory.primary == transactionName })
    }
    
    func aggregateMostOccurredTransactions() -> [TransactionAggregation]? {
        let groupedTransactions = Dictionary(grouping: transactions, by: { $0.name })
        
        // Calculate the total amount and name for each group
        let aggregatedTransactions: [TransactionAggregation] = groupedTransactions.compactMap { transactionId, transactions in
            guard let transaction = transactions.first else {
                return nil
            }
            let domain: String
            if let name = transaction.merchantName {
                let filteredName = name.filter { !$0.isPunctuation }
                domain = String(filteredName.filter { !" \n\t\r".contains($0) })
            } else {
                domain = ""
            }
            let imageURL = URL(string: "https://logo.clearbit.com/\(domain).com?size=30")
            let totalAmount = transactions.reduce(0) { $0 + $1.amount }
            return TransactionAggregation(
                transactionId: transactionId,
                name: transaction.name,
                totalAmount: totalAmount,
                type: transaction.personalFinanceCategory.primary,
                domain: domain,
                imgurl: imageURL
                
            )
        }
        
        // Filter and return transactions with positive total amount (occurred more than once)
        let mostOccurredTransactions = aggregatedTransactions.filter { $0.totalAmount > 0 }
        
        // Sort the most occurred transactions based on their total amount in descending order
        let sortedTransactions = mostOccurredTransactions.sorted { $0.totalAmount > $1.totalAmount }
        
        // If no most occurred transactions are found, return nil
        guard !sortedTransactions.isEmpty else {
            return nil
        }
        
        return sortedTransactions
        
    }
    
    func aggregateMostOccurredCategories() -> [CategoryAggregation]? {
        let groupedTransactions = Dictionary(grouping: transactions, by: { $0.personalFinanceCategory.primary })
        
        // Calculate the total amount for each category
        let aggregatedCategories: [CategoryAggregation] = groupedTransactions.compactMap { categoryName, transactions in
            let totalAmount = transactions.reduce(0) { $0 + $1.amount }
            return CategoryAggregation(
                name: categoryName,
                totalAmount: totalAmount
            )
        }
        
        // Filter and return transactions with positive total amount (occurred more than once)
        // Filter and return categories with positive total amount (occurred more than once)
        let mostOccurredCategories = aggregatedCategories.filter { $0.totalAmount > 0 }
        
        // Sort the most occurred categories based on their total amount in descending order
        let sortedCategories = mostOccurredCategories.sorted { $0.totalAmount > $1.totalAmount }
        
        // If no most occurred categories are found, return nil
        guard !sortedCategories.isEmpty else {
            return nil
        }
        
        return sortedCategories
        
    }
    
    var sectionHeader: some View {
        HStack {
            Text("Top Spent")
                .font(.headline)
                .foregroundColor(.blue)
            Spacer()
            if let mostOccurredTransactions = aggregateMostOccurredTransactions(), mostOccurredTransactions.count > 5 {
                Picker("Top Transactions", selection: $selectedTopTransactionsCount) {
                    Text("Top 5").tag(5)
                    Text("Top 10").tag(10)
                    Text("All").tag(Int.max)
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedTopTransactionsCount) { _ in
                    // No need to fetch transactions here as we are using a fixed data array
                }
            }
        }
    }
    
    
    // ... (Other existing code remains the same
    
    
    
}




struct TransactionAggregation: Identifiable {
    let id = UUID()
    let transactionId: String?
    let name: String
    let totalAmount: Double
    let type: String
    let domain: String?
    let imgurl: URL?
}

struct CategoryAggregation: Identifiable {
    let id = UUID()
    let name: String
    let totalAmount: Double
}


//struct CategoryAggregation: Identifiable {
//    let id = UUID()
//    let transactionId: String?
//    let name: String
//    let totalAmount: Double
//}

struct DataView_Previews: PreviewProvider {
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
            return AnyView(DataView(transactions: .constant(transaction)))
        } catch {
            print("Error decoding JSON: \(error)")
            return AnyView(Text("Error decoding JSON"))
        }
    }
}
