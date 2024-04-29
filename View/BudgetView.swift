import SwiftUI

struct BudgetView: View {
    @Binding var transactions: [AccountsResponse.Transaction]
    @State private var budgetAmount: Double = 0.0
    @State private var isBudgetSet: Bool = false
    @State private var isEditing: Bool = false
    
    init(transactions: Binding<[AccountsResponse.Transaction]>) {
        _transactions = transactions
        _budgetAmount = State(initialValue: Budget.budget) // Load budget from UserDefaults
        _isBudgetSet = State(initialValue: Budget.budget > 0) // Check if budget is set
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if !isBudgetSet || isEditing {
                    Text("Set Your Monthly Budget")
                        .font(.title)
                        .padding()
                    
                    TextField("Enter Budget Amount", value: $budgetAmount, formatter: NumberFormatter.currency)
                        .padding()
                        .keyboardType(.decimalPad)
                    
                } else {
                    Text("Your budget for the month: $\(String(format: "%.2f", budgetAmount))")
                        .font(.headline)
                        .padding()
                    
                    if isBudgetSet {
                        ProgressView(value: calculateBudgetProgress())
                            .progressViewStyle(BarProgressStyle(height: 30.0))
                        
                        Text("Spent: $\(String(format: "%.2f", calculateTotalSpentThisMonth().totalAmount))")
                            .font(.subheadline)
                            .padding(.top, -210)
                        
                        if (calculateTotalSpentThisMonth().totalAmount > budgetAmount) {
                            
                            Text("Bro you are broke!! Please limit your expenses.")
                        }
                    }
                }
                
                
                if isBudgetSet {
                    List {
                        
                        Section(header: Text("Transactions for this month")) {
                            ForEach(calculateTotalSpentThisMonth().transactions)
                            { transaction in
                                if transaction.amount >= 0 {
                                    TransactionCard(transaction: transaction)
                                        .overlay(NavigationLink(destination: TransactionDetails(transaction: transaction), label: {EmptyView()})
                                            .opacity(0))
                                }
                        }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Budget")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if isBudgetSet {
                            // Perform any action needed when "Edit Budget" is tapped
                            Budget.budget = budgetAmount
                            isEditing.toggle()
                        } else if budgetAmount > 0 {
                            Budget.budget = budgetAmount // Save the budget to UserDefaults
                            isBudgetSet = true
                        }
                    }) {
                        if isEditing { // Show "Done" button when editing
                            Text("Done")
                        } else
                        if isBudgetSet {
                            Text("Edit Budget")
                        } else {
                            Text("Set Budget")
                        }
                    }
                }
            }
        }
    }
    
    func calculateTotalSpentThisMonth() -> (totalAmount: Double, transactions: [AccountsResponse.Transaction]) {
        let today = Date()
        let calendar = Calendar.current
        
        // Get the first day of the current month
        let firstDayOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: today)))!
        
        let filteredTransactions = transactions.filter { transaction in
            if let transactionDate = BudgetView.transactionDateFormatter.date(from: transaction.date),
               calendar.isDate(transactionDate, inSameDayAs: today) || transactionDate > firstDayOfCurrentMonth {
                return true
            } else {
                return false
            }
        }
        
        let totalAmount = filteredTransactions.reduce(0) { total, transaction in
            if transaction.amount > 0 {
                return total + transaction.amount
            }
            return 0
        }
        
        return (totalAmount, filteredTransactions)
    }
    
    private static let transactionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    func calculateBudgetProgress() -> Double {
        if budgetAmount <= 0 {
            return 0
        } else {
            let totalSpent = calculateTotalSpentThisMonth().totalAmount
            return min(totalSpent / budgetAmount, 1.0)
        }
    }
}

extension NumberFormatter {
    static var currency: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }
}

struct BudgetView_Previews: PreviewProvider {
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
            let transactions = try decoder.decode([AccountsResponse.Transaction].self, from: jsonData)
            return AnyView(BudgetView(transactions: .constant(transactions)))
        } catch {
            print("Error decoding JSON: \(error)")
            return AnyView(Text("Error decoding JSON"))
        }
    }
}

struct BarProgressStyle: ProgressViewStyle {
 
    var color: Color = .purple
    var height: Double = 20.0
    var labelFontStyle: Font = .body
 
    func makeBody(configuration: Configuration) -> some View {
 
        let progress = configuration.fractionCompleted ?? 0.0
 
        GeometryReader { geometry in
 
            VStack(alignment: .leading) {
 
                configuration.label
                    .font(labelFontStyle)
 
                RoundedRectangle(cornerRadius: 10.0)
                    .fill(Color(uiColor: .systemGray5))
                    .frame(height: height)
                    .frame(width: geometry.size.width)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10.0)
                            .fill(color)
                            .frame(width: geometry.size.width * progress)
                            .overlay {
                                if let currentValueLabel = configuration.currentValueLabel {
 
                                    currentValueLabel
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                    }
 
            }
 
        }
    }
}
