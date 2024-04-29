//
//  TransactionMenu.swift
//  ExpenseTracker
//
//  Created by Kshitij Patil on 7/27/23.
//

//import SwiftUI
//
//struct TransactionMenu: View {
//    @State private var selectedTab = 0
//    @Binding var transactions: [AccountsResponse.Transaction]
//
//    
//    var body: some View {
//        TabView(selection: $selectedTab) {
//            TransactionView(transactions: $transactions)
//                .tabItem {
//                    Label("Home", systemImage: "house")
//                }
//                .tag(0)
//            Text("Data")
//                .tabItem {
//                    Label("Data", systemImage: "wallet.pass")
//                }
//                .tag(1)
//            Text("Account Details")
//                .tabItem {
//                    Label("Account", systemImage: "person")
//                }
//                .tag(2)
//        }
//    }
//}

//struct TransactionMenu_Previews: PreviewProvider {
//    static var previews: some View {
//        TransactionMenu()
//    }
//}
