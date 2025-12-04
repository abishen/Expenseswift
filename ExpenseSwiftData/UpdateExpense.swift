//
//  UpdateExpense.swift
//  ExpenseSwiftData
//
//  Created by Dillon Dhayanandan on 28/11/2025.
//
import SwiftUI
import Foundation

struct UpdateExpenseSheet: View {

    @Bindable var expense: Expense
    @Environment(\ .dismiss) var dismiss

    var body: some View {
        NavigationStack{
            
            Form {
                TextField("Expense Name", text: $expense.name )
                DatePicker("Date", selection: $expense.date)
                TextField("Amount",value: $expense.value, format: .currency(code: "GBP"))
                    .keyboardType(.decimalPad)
            }
        }
    }
}
