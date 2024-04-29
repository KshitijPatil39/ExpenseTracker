//
//  AccessTokenManager.swift
//  ExpenseTracker
//
//  Created by Kshitij Patil on 7/26/23.
//

import Foundation

struct AccessTokenManager {
    private static let accessTokenKey = "accessToken"
        
        static var accessToken: String {
            get {
                return UserDefaults.standard.string(forKey: accessTokenKey) ?? ""
            }
            set {
                UserDefaults.standard.set(newValue, forKey: accessTokenKey)
            }
        }
}

struct Budget {
    static let budgetkey = "budget"
        
        static var budget: Double {
            get {
                return UserDefaults.standard.double(forKey: budgetkey) 
            }
            set {
                UserDefaults.standard.set(newValue, forKey: budgetkey)
            }
        }
}


