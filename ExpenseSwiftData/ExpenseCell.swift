//
//  ExpenseCell.swift
//  ExpenseSwiftData
//
//  Created by Dillon Dhayanandan on 28/11/2025.
//

import SwiftUI
struct ExpenseCell: View {
    var expense: Expense
    var body: some View {
        HStack{
            Text(expense.date, format: .dateTime.month(.abbreviated).day())
                .frame(width: 70, alignment: .leading)
            Text(expense.name)
            Spacer()
            Text(expense.value, format: .currency(code: "GBP"))
        }
       
    }
}
