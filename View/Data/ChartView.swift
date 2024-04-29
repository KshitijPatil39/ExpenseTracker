//
//  ChartView.swift
//  ExpenseTracker
//
//  Created by Kshitij Patil on 7/29/23.
//

import SwiftUI

struct ChartView: View {
    var categories: [CategoryAggregation]
    var names: [String] { categories.map { $0.name } }
    var values: [Double] { categories.map{$0.totalAmount} }
    
    
    var body: some View {
        ScrollView {
            VStack{
                PieChartView(
                    values: values,
                    names: names,
                    formatter: {value in String(format: "$%.2f", value)},
                    colors: [Color.red, Color.purple, Color.orange, Color.blue, Color.green, Color.pink]
                )
                .padding(7.0)
            }
        }
                
    }
}


struct ChartView_Previews: PreviewProvider {
   
    static var previews: some View {
        let data: [CategoryAggregation] = [CategoryAggregation(name: "McDonalds", totalAmount: 100.0), CategoryAggregation(name: "Apple", totalAmount: 400.0), CategoryAggregation(name: "Subway", totalAmount: 200.0)]
        ChartView(categories: data)
    }
}

//struct CategoryAggregation: Identifiable {
//    let id = UUID()
//    let name: String
//    let totalAmount: Double
//}
