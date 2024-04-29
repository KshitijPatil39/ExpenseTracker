//
//  PlaidManager.swift
//  ExpenseTracker
//
//  Created by Kshitij Patil on 7/26/23.
//

import Foundation
import LinkKit

class PlaidManager {
    
    static let clientID = "clientId"
    static let secret = "secret"

    // Set up the API endpoint URL
    static let baseURL = "https://development.plaid.com"
    
    
    
    static func getLinkToken(completion: @escaping (Result<String, Error>) -> Void) {
        
        let endpoint = "/link/token/create"
        let urlString = self.baseURL + endpoint

        // Set up the request body
        let requestBody: [String: Any] = [
            "client_id": self.clientID,
            "secret": self.secret,
            "user": [
                "client_user_id": "user-id" // Replace "user-id" with a unique identifier for your user
            ],
            "client_name": "Your App Name",
            "products": ["transactions"],
            "country_codes": ["US"],
            "language": "en"
        ]

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        // Make the API request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data returned", code: 0, userInfo: nil)))
                return
            }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                if let jsonDict = jsonObject as? [String: Any], let linkToken = jsonDict["link_token"] as? String {
                    completion(.success(linkToken))
                } else {
                    completion(.failure(NSError(domain: "Invalid response format", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }

    static func createHandler(linkToken: String) -> Result<Handler, Plaid.CreateError> {
            let configuration = createLinkTokenConfiguration(with: linkToken)

            // This only results in an error if the token is malformed.
            return Plaid.create(configuration)
        }

    static func fetchAndSaveLinkToken(completion: @escaping (String?) -> Void) {
        getLinkToken { result in
            switch result {
            case .success(let token):
                // Pass the link token to the completion handler
                completion(token)
                // Perform any additional actions with the link token here
                print("Link token obtained:", token)
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                // Pass nil to the completion handler in case of failure
                completion(nil)
            }
        }
    }

    static func createLinkTokenConfiguration(with linkToken: String) -> LinkTokenConfiguration {
        var linkConfiguration = LinkTokenConfiguration(token: linkToken) { success in
            
            print("public-token: \(success.publicToken) metadata: \(success.metadata)")
            
            exchangePublicTokenForAccessToken(publicToken: "\(success.publicToken)") { result in
                            switch result {
                            case .success(let accessToken):
                                // Access token has been obtained and stored in AccessTokenStorage
                                // Perform any additional actions with the access token here
                                AccessTokenManager.accessToken = accessToken
                                print("Access token stored securely: \(accessToken)")
                            case .failure(let error):
                                print("Access Token Exchange Error: \(error.localizedDescription)")
                            }
                        }
                                
                            
                        }
        

       
        linkConfiguration.onExit = { exit in
            if let error = exit.error {
                print("exit with \(error)\n\(exit.metadata)")
            } else {
                // User exited the flow without an error.
                print("exit with \(exit.metadata)")
            }

        }


        linkConfiguration.onEvent = { event in
            print("Link Event: \(event)")
        }

        return linkConfiguration
    }
    
    static func exchangePublicTokenForAccessToken(publicToken: String, completion: @escaping (Result<String, Error>) -> Void) {
            
            let exchangeEndpoint = "/item/public_token/exchange"
            let exchangeURLString = baseURL + exchangeEndpoint

            // Set up the request body
            let requestBody: [String: Any] = [
                "client_id": clientID,
                "secret": secret,
                "public_token": publicToken
            ]

            guard let url = URL(string: exchangeURLString) else {
                completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

            // Make the API request to exchange the public token for the access token
            let exchangeSession = URLSession.shared
            let exchangeTask = exchangeSession.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data returned", code: 0, userInfo: nil)))
                    return
                }

                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    if let jsonDict = jsonObject as? [String: Any], let accessToken = jsonDict["access_token"] as? String {
                        // Successfully obtained the access token
                        // Update the AccessTokenStorage struct with the access token
                        AccessTokenManager.accessToken = accessToken
                        // Call the completion handler with the access token
                        completion(.success(accessToken))
                    } else {
                        completion(.failure(NSError(domain: "Invalid response format", code: 0, userInfo: nil)))
                    }
                } catch {
                    completion(.failure(error))
                }
            }

            exchangeTask.resume()
        }
    
    static func getAccounts(accessToken: String, completion: @escaping (Result<[AccountsResponse.BankAccount], Error>) -> Void) {
        let endpoint = "/accounts/balance/get"
        let getAcc = self.baseURL + endpoint
        
        let requestBody: [String: Any] = [
            "client_id": clientID,
            "secret": secret,
            "access_token": accessToken
        ]
        
        guard let url = URL(string: getAcc) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        // Convert the request body to Data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Perform the HTTP request
            URLSession.shared.dataTask(with: request) { data, response, error in
                // Handle the response or error
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                    return
                }
                
                do {
                    print("ACCESS_TOKEN: \(accessToken) Raw JSON Data: \(String(data: data, encoding: .utf8) ?? "")")
                    // Decode the JSON data into an array of BankAccount objects
                    let decoder = JSONDecoder()
                            // Convert snake_case to camelCase

                                // Catch and print any decoding errors for debugging purposes
                                do {
                                    let accountsResponse = try decoder.decode(AccountsResponse.self, from: data)
                                    completion(.success(accountsResponse.accounts))
                                } catch {
                                    print("Decoding Error: \(error)")
                                    completion(.failure(error))
                                }
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
    static func removeAccount(accessToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        let removeEndpoint = "/item/remove"
        let removeURLString = baseURL + removeEndpoint

        // Set up the request body
        let requestBody: [String: Any] = [
            "client_id": clientID,
            "secret": secret,
            "access_token": accessToken
        ]

        guard let url = URL(string: removeURLString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        // Make the API request to exchange the public token for the access token
        let exchangeSession = URLSession.shared
        let exchangeTask = exchangeSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data returned", code: 0, userInfo: nil)))
                return
            }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                if let jsonDict = jsonObject as? [String: Any], let requestId = jsonDict["request_id"] as? String {
                    // Successfully obtained the access token
                    // Update the AccessTokenStorage struct with the access token
                    AccessTokenManager.accessToken = ""
                    // Call the completion handler with the access token
                    completion(.success(requestId))
                } else {
                    completion(.failure(NSError(domain: "Invalid response format", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }

        exchangeTask.resume()
    }
    
    static func getTransactions(duration: Int?, accessToken: String, completion: @escaping (Result<[AccountsResponse.Transaction], Error>) -> Void) {
        let endpoint = "/transactions/get"
        let getAcc = self.baseURL + endpoint
        let todayDate = formatDate(Date())
        
        func formatDate(_ date: Date) -> String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                return dateFormatter.string(from: date)
            }
        var daysOffset = 0
                switch duration {
                case 1:
                    daysOffset = -30
                case 2:
                    daysOffset = -90
                case 3:
                    daysOffset = -180
                default:
                    daysOffset = -30
                }
        let beforeDate = Calendar.current.date(byAdding: .day, value: daysOffset, to: Date()) ?? Date()
                let pastDate = formatDate(beforeDate)
        
        let options: [String: Any] = [
                    "include_personal_finance_category": true,
                    "count": 500
                ]
        
        
        let requestBody: [String: Any] = [
            "client_id": clientID,
            "secret": secret,
            "access_token": accessToken,
            "start_date": pastDate,
            "end_date": todayDate,
            "options": options
        ]
        
        guard let url = URL(string: getAcc) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        // Convert the request body to Data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Perform the HTTP request
            URLSession.shared.dataTask(with: request) { data, response, error in
                // Handle the response or error
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                    return
                }
                
                do {
                    print("Raw JSON Data: \(String(data: data, encoding: .utf8) ?? "")")
                    // Decode the JSON data into an array of BankAccount objects
                    let decoder = JSONDecoder()
                            // Convert snake_case to camelCase

                                // Catch and print any decoding errors for debugging purposes
                                do {
                                    let transactions = try decoder.decode(AccountsResponse.self, from: data)
                                    completion(.success(transactions.transactions))
                                } catch {
                                    print("Decoding Error: \(error)")
                                    completion(.failure(error))
                                }
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }

}


