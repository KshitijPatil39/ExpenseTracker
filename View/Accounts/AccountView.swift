//
//  AccountView.swift
//  ExpenseTracker
//
//  Created by Kshitij Patil on 7/26/23.
//

import SwiftUI

struct AccountView: View {
    @Binding var accounts: [AccountsResponse.BankAccount]
    @Binding var transactions: [AccountsResponse.Transaction]
    
    
    var body: some View {
        VStack {
//            if accounts.isEmpty {
//                Text("Add new account")
//                    .font(.title)
//                    .foregroundColor(.blue)
//                    .padding()
//            } else {
                List {
                    Section(header: Text("Credit Card")) {
                        ForEach(accounts.filter { $0.type == "credit" }) { account in
                            NavigationLink(destination: {AccountDetails(transactions: $transactions, accountId: account.id, accoutName: account.name)}) {
                                                AccountsCard(account: account)
                                            }
                                        }
                        
                                    }
                                    
                                    Section(header: Text("Depository accounts")) {
                                        ForEach(accounts.filter { $0.type == "depository" }) { account in
                                            NavigationLink(destination: {AccountDetails(transactions: $transactions, accountId: account.id, accoutName: account.name)}) {
                                                AccountsCard(account: account)
                                            }
                                        }
                                        
                                    }
                                    
                                    Section(header: Text("Loans")) {
                                        ForEach(accounts.filter { $0.type == "loan" }) { account in
                                            NavigationLink(destination: {AccountDetails(transactions: $transactions, accountId: account.id, accoutName: account.name)}) {
                                                AccountsCard(account: account)
                                            }
                                        }
                                    }
                }
                .refreshable {
                                // This block will be executed when the user pulls down to refresh
                                // Call fetchAccounts from the parent ContentView
                                fetchAccounts()
                            }
            }
        
    }
    func fetchAccounts() {
        let accessToken = "access-development-b3a66061-d776-40f0-a535-fbdcc9a1f0a8" // Get the access token from AccessTokenManager
//        let accessToken = AccessTokenManager.accessToken
            guard !accessToken.isEmpty else {
                print("Access token is empty. Plaid flow might not have completed yet.")
                return
            }
        
            print("called")
            // Call the getAccounts function with the access token after completing the Plaid flow
            PlaidManager.getAccounts(accessToken: accessToken) { result in
                switch result {
                case .success(let fetchedAccounts):
                    // Update the accounts binding with the fetched data
                    DispatchQueue.main.async {
//                        if self.accounts.isEmpty {
                        self.accounts = fetchedAccounts
//                        } else {
//                            self.accounts.append(contentsOf: fetchedAccounts)
//                        }
                        }
                case .failure(let error):
                    // Handle the error, e.g., show an error message
                    print("Error fetching accounts: \(error)")
                }
            }
        }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        let jsonData = """
        [
            {
              "account_id": "xMnbeyXqAAHQ9LP3GdyKIwVJ5Vvp73C6ZlRaP",
              "balances": {
                "available": 100,
                "current": 110,
                "iso_currency_code": "USD",
                "limit": null,
                "unofficial_currency_code": null
              },
              "mask": "0000",
              "name": "Plaid Checking",
              "official_name": "Plaid Gold Standard 0% Interest Checking",
              "subtype": "checking",
              "type": "depository"
            },
            {
              "account_id": "KXD8z6Vd11sn8y5P6RWZT1mebRKR6eCRjwaXp",
              "balances": {
                "available": 200,
                "current": 210,
                "iso_currency_code": "USD",
                "limit": null,
                "unofficial_currency_code": null
              },
              "mask": "1111",
              "name": "Plaid Saving",
              "official_name": "Plaid Silver Standard 0.1% Interest Saving",
              "subtype": "savings",
              "type": "depository"
            }]
        """.data(using: .utf8)!
        
        let transactionData = """
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
        if let bankAccounts = try? decoder.decode([AccountsResponse.BankAccount].self, from: jsonData),
           let transactions = try? decoder.decode([AccountsResponse.Transaction].self, from: transactionData){
            return AnyView(AccountView(accounts: .constant(bankAccounts), transactions: .constant(transactions)))
        } else {
            print("Error decoding JSON")
            return AnyView(Text("Error decoding JSON"))
        }
    }
}

