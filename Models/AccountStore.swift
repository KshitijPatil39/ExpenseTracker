//
//  AccountStore.swift
//  ExpenseTracker
//
//  Created by Kshitij Patil on 7/26/23.
//


import Foundation
import SwiftUI

@MainActor
class AccountStore: ObservableObject {
    @Published var accounts: [AccountsResponse.BankAccount] = []
    @Published var transactions: [AccountsResponse.Transaction] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("accounts.data")
    }
    
    func load() async throws {
            do {
                let fileURL = try Self.fileURL()
                var accounts: [AccountsResponse.BankAccount]
                
                if let data = try? Data(contentsOf: fileURL) {
                    accounts = try JSONDecoder().decode([AccountsResponse.BankAccount].self, from: data)
                } else {
                    accounts = []
                }
                
                self.accounts = accounts
            } catch {
                print("Error loading data: \(error)")
            }
            
    }
        
        func save(accounts: [AccountsResponse.BankAccount]) async throws {
            let task = Task {
                let data = try JSONEncoder().encode(accounts)
                let outfile = try Self.fileURL()
                try data.write(to: outfile)
            }
            
            _ = try await task.value
        }
    
}
