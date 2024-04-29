struct AccountsResponse: Decodable {
    let accounts: [BankAccount]
    let item: Item?
    let transactions: [Transaction]!

    struct BankAccount: Codable, Identifiable, Equatable {
        let id: String
        let balances: Balances?
        let mask: String
        let name: String
        let officialName: String?
        let subtype: String
        let type: String

        enum CodingKeys: String, CodingKey {
            case id = "account_id"
            case balances
            case mask
            case name
            case officialName = "official_name"
            case subtype
            case type
        }
        
        struct Balances: Codable, Equatable {
            let available: Double?
            let current: Double
            let isoCurrencyCode: String
            let limit: Double?
            let unofficialCurrencyCode: String?

            enum CodingKeys: String, CodingKey {
                case available
                case current
                case isoCurrencyCode = "iso_currency_code"
                case limit
                case unofficialCurrencyCode = "unofficial_currency_code"
            }
        }
    }

    struct Item: Decodable {
        let availableProducts: [String]
        let billedProducts: [String]
        let consentExpirationTime: String?
        let error: String?
        let institutionID: String
        let itemID: String
        let optionalProducts: [String]?
        let products: [String]
        let updateType: String
        let webhook: String?

        enum CodingKeys: String, CodingKey {
            case availableProducts = "available_products"
            case billedProducts = "billed_products"
            case consentExpirationTime = "consent_expiration_time"
            case error
            case institutionID = "institution_id"
            case itemID = "item_id"
            case optionalProducts = "optional_products"
            case products
            case updateType = "update_type"
            case webhook
        }
    }
    
    struct Transaction: Codable, Identifiable, Equatable {
        let id: String
        let accountId: String
        let accountOwner: String?
        let amount: Double
        let date: String
        let isoCurrencyCode: String?
        let location: Location
        let merchantName: String?
        let name: String
        let paymentChannel: String
        let pending: Bool
        let pendingTransactionId: String?
        let personalFinanceCategory: PersonalFinanceCategory
        let transactionType: String
        let unofficialCurrencyCode: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "transaction_id"
            case accountId = "account_id"
            case accountOwner = "account_owner"
            case amount
            case date
            case isoCurrencyCode
            case location
            case merchantName = "merchant_name"
            case name
            case paymentChannel = "payment_channel"
            case pending
            case pendingTransactionId = "pending_transaction_id"
            case personalFinanceCategory = "personal_finance_category"
            case transactionType = "transaction_type"
            case unofficialCurrencyCode
        }
    }

    struct Location: Codable, Equatable {
        let address: String?
        let city: String?
        let country: String?
        let lat: Double?
        let lon: Double?
        let postalCode: String?
        let region: String?
        let storeNumber: String?
    }

    struct PersonalFinanceCategory: Codable, Equatable {
        let detailed: String
        let primary: String
    }

}


