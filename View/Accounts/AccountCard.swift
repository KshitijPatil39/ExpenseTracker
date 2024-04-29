//
//  AccountCard.swift
//  ExpenseTracker
//
//  Created by Kshitij Patil on 7/26/23.
//

import SwiftUI

struct AccountsCard: View {
    let account: AccountsResponse.BankAccount
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(account.name)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            HStack {
                if let available = account.balances?.available, let isoCurrencyCode = account.balances?.isoCurrencyCode {
                    Label("\(available, specifier: "%.2f") \(isoCurrencyCode)", systemImage: "creditcard")
                        .accessibilityLabel("Available Balance: \(available, specifier: "%.2f") \(isoCurrencyCode)")
                } else if let limit = account.balances?.limit, let isoCurrencyCode = account.balances?.isoCurrencyCode {
                    Label("\(limit, specifier: "%.2f") \(isoCurrencyCode)", systemImage: "creditcard")
                        .accessibilityLabel("Limit: \(limit, specifier: "%.2f") \(isoCurrencyCode)")
                }
                
                
                Spacer()
                if let current = account.balances?.current, let isoCurrencyCode = account.balances?.isoCurrencyCode {
                                    Label("\(current, specifier: "%.2f") \(isoCurrencyCode)", systemImage: "dollarsign.circle")
                                        .accessibilityLabel("Current Balance: \(current, specifier: "%.2f") \(isoCurrencyCode)")
                                }
            }
            .font(.caption)
            
        }
        .padding()
    }
}

struct AccountsCard_Previews: PreviewProvider {
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

        let decoder = JSONDecoder()
        do {
            let bankAccount = try decoder.decode([AccountsResponse.BankAccount].self, from: jsonData)
            return AnyView(AccountsCard(account: bankAccount[0]))
        } catch {
            print("Error decoding JSON: \(error)")
            return AnyView(Text("Error decoding JSON"))
        }
    }
}

