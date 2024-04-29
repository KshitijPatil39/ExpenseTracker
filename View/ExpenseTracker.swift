import SwiftUI

@main
struct Expense_SwiftUIApp: App {
    @StateObject private var accountData = AccountStore()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView(accounts: $accountData.accounts, transactions: $accountData.transactions)
                            .environmentObject(accountData)
                            .onAppear {
                                loadData()
                            }
        }
                .onChange(of: scenePhase) { newPhase in
                            if newPhase == .inactive || newPhase == .background {
                                Task {
                                    saveAccounts()
                                    }
                                }
                            }
    }
    

    private func loadData() {
        Task {
                    do {
                        try await accountData.load()
                    } catch {
                        print("Error loading data: \(error)")
                    }
                }
            }
    
    private func saveAccounts() {
        Task { do {
            try await accountData.save(accounts: accountData.accounts)
        } catch {
            print("Error saving data: \(error)")
        }
        }
    }
    
}
