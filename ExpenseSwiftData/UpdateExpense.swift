//
//  UpdateExpense.swift
//  ExpenseSwiftData
//
//  Created by Dillon Dhayanandan on 28/11/2025.
//
import SwiftUI
import Foundation
import SwiftData

struct UpdateExpenseSheet: View {
    @Bindable var expense: Expense
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Expense Name", text: $expense.name)
                DatePicker("Date", selection: $expense.date)
                TextField("Amount", value: $expense.value, format: .currency(code: "GBP"))
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        // Changes are auto-saved by SwiftData when the context is saved by the host view,
                        // but dismissing here is fine. If you need explicit save, handle it in the caller.
                        dismiss()
                    }
                }
            }
        }
    }
}
