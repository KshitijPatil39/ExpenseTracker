//
//  ContentView.swift
//  LinkDemo-SwiftUI
//
//  Copyright © 2023 Plaid Inc. All rights reserved.
//

import LinkKit
import SwiftUI
import Foundation

struct ContentView: View {
    @State private var plaidFlowCompleted = false
    @State private var isPresentingLink = false
    @State private var linkHandler: Handler?
    @State private var fetchingAccounts = false
    @State private var showConfirmationAlert = false
    @EnvironmentObject private var accountData: AccountStore
    @Binding var accounts: [AccountsResponse.BankAccount]
    @Binding var transactions: [AccountsResponse.Transaction]
    @State private var selectedTab = 0
    
    
    var body: some View {
        TabView(selection: $selectedTab){
            NavigationStack {
                
                VStack {
                    AccountView(accounts: $accounts, transactions: $transactions)
                        .navigationTitle("Bank accounts")
                        .toolbar {
                            if accounts.isEmpty{
                                Button(action: {
                                    isPresentingLink = true
                                    fetchAndCreateLinkConfiguration()
                                }) {
                                    Text("Add new")
                                }
                                .accessibilityLabel("Add New")
                            } else {
                                Button(action: {
                                    showConfirmationAlert = true
                                }) {
                                    Text("Remove")
                                }
                            }
                        }
                        .toolbar(.visible, for: .tabBar)
                    
                    
                    if fetchingAccounts {
                        ProgressView("Fetching Accounts...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
            }
            .tabItem {
                Label("Accounts", systemImage: "person")
            }
            .tag(0)
            
            TransactionView(transactions: $transactions)
                .navigationTitle("Transactions")
            
                .tabItem {
                    Label("Transactions", systemImage: "dollarsign.square")
                }
                .tag(1)
                .onChange(of: selectedTab) { newValue in
                    if newValue == 1 {
                        // Fetch transactions when the "Transactions" tab is clicked (tag 1)
                        self.transactions = transactions
                    }
                }
                .toolbar(.visible, for: .tabBar)
            
            BudgetView(transactions: $transactions)
                .tabItem {
                    Label("Budget", systemImage: "list.bullet.rectangle.portrait")
                }
                .tag(2)
            
            DataView(transactions: $transactions)
                .tabItem {
                    Label("Data", systemImage: "wallet.pass")
                }
                .tag(3)
            
        }
        .transition(.slide)
        .background(Color(UIColor.systemBackground))
        .sheet(
            isPresented: $isPresentingLink,
            onDismiss: {
                isPresentingLink = false
                fetchAccounts()
            },
            content: {
                
                if let handler = linkHandler {
                    LinkController(handler: handler)
                } else {
                    // Handle error case when the linkHandler is nil
                    Text("Error: Unable to present Plaid Link.")
                        .font(.title2)
                }
            }
            
        )
        .onChange(of: accounts) { newAccounts in
            // If the accounts change, set the plaidFlowCompleted flag to true
            // This will ensure that fetchAccounts is called in onAppear
            plaidFlowCompleted = true
            Task { do {
                try await accountData.save(accounts: accountData.accounts)
            } catch {
                print("Error saving data: \(error)")
            }
            }
        }
        .alert(isPresented: $showConfirmationAlert) {
            Alert(
                title: Text("Confirmation"),
                message: Text("Are you sure you want to remove the accounts?"),
                primaryButton: .default(Text("Remove")) {
                    // Perform the action to add a new account here
                    removeAccounts()
                    showConfirmationAlert = false
                },
                secondaryButton: .cancel()
            )
        }
        
    }
    
    
    
    private let backgroundColor: Color = Color(
        red: 247 / 256,
        green: 249 / 256,
        blue: 251 / 256,
        opacity: 1
    )
    
    private let plaidBlue: Color = Color(
        red: 0,
        green: 191 / 256,
        blue: 250 / 256,
        opacity: 1
    )
    
    
    
    
    func fetchAndCreateLinkConfiguration() {
        // Call the getLinkToken function with a completion handler
        PlaidManager.fetchAndSaveLinkToken { linkToken in
            if let linkToken = linkToken {
                let result = PlaidManager.createHandler(linkToken: linkToken)
                switch result {
                case .success(let handler):
                    // Present the Plaid Link flow using the handler
                    linkHandler = handler
                    isPresentingLink = true
                    
                case .failure(let error):
                    print("Link Handler Creation Error: \(error.localizedDescription)")
                }
            } else {
                print("Failed to get the link token.")
            }
        }
    }
    
    func fetchAccounts() {
        let accessToken = "access-development-b3a66061-d776-40f0-a535-fbdcc9a1f0a8" // Get the access token from AccessTokenManager
//        let accessToken = AccessTokenManager.accessToken
        print("ACCESS_TOKEN: \(accessToken)")
        guard !accessToken.isEmpty else {
            print("Access token is empty. Plaid flow might not have completed yet.")
            return
        }
        
        fetchingAccounts = true
        
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
                    fetchingAccounts = false
                }
                Task {
                    do {
                        try await accountData.save(accounts: fetchedAccounts)
                    } catch {
                        print("Error saving data: \(error)")
                    }
                }
            case .failure(let error):
                // Handle the error, e.g., show an error message
                print("Error fetching accounts: \(error)")
            }
        }
        
        PlaidManager.getTransactions(duration: nil, accessToken: accessToken) { result in
            switch result {
            case .success(let fetchedTransactions):
                // Update the accounts binding with the fetched data
                DispatchQueue.main.async {
                    //                        if self.accounts.isEmpty {
                    self.transactions = fetchedTransactions
                    //                        } else {
                    //                            self.accounts.append(contentsOf: fetchedAccounts)
                    //                        }
                }
                //                Task {
                //                    do {
                //                        try await accountData.save(accounts: fetchedAccounts.accounts)
                //                    } catch {
                //                        print("Error saving data: \(error)")
                //                    }
                //                }
            case .failure(let error):
                // Handle the error, e.g., show an error message
                print("Error fetching transactions: \(error)")
            }
        }
    }
    
    func removeAccounts() {
        let accessToken = AccessTokenManager.accessToken
        PlaidManager.removeAccount(accessToken: accessToken){ result in
            switch result {
            case .success(let requestId):
                print("Accounts removed successfully with request id:", requestId)
                DispatchQueue.main.async {
                    self.accounts = []
                }
                Task {
                    do {
                        try await accountData.save(accounts: [])
                    } catch {
                        print("Error saving data: \(error)")
                    }
                }
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                // Pass nil to the completion handler in case of failure
            }
        }
    }
    
    func fetchTransactions() {
        let accessToken = "access-development-b3a66061-d776-40f0-a535-fbdcc9a1f0a8" // Get the access token from AccessTokenManager
//        let accessToken = AccessTokenManager.accessToken
        guard !accessToken.isEmpty else {
            print("Access token is empty. Plaid flow might not have completed yet.")
            return
        }
        
        PlaidManager.getTransactions(duration: nil, accessToken: accessToken) { result in
            switch result {
            case .success(let fetchedTransactions):
                // Update the transactions binding with the fetched data
                DispatchQueue.main.async {
                    self.transactions = fetchedTransactions
                }
            case .failure(let error):
                // Handle the error, e.g., show an error message
                print("Error fetching transactions: \(error)")
            }
        }
    }
}

struct LinkView_Previews: PreviewProvider {
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
            return AnyView(ContentView(accounts: .constant(bankAccounts), transactions: .constant(transactions)))
        } else {
            print("Error decoding JSON")
            return AnyView(Text("Error decoding JSON"))
        }
    }
}
