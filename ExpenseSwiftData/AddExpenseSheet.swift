//
//  AddExpenseSheet.swift
//  ExpenseSwiftData
//
//  Created by Dillon Dhayanandan on 28/11/2025.
//
import SwiftUI
import CoreData
struct AddExpenseSheet: View {
    @Environment(\.modelContext) var context
    @Environment(\ .dismiss) var dismiss
    @State var name: String = ""
    @State var date :Date = .now
    @State var amount: Double = 0
    var body: some View {
        NavigationStack{
            
            Form {
                TextField("Expense Name", text: $name )
                DatePicker("Date", selection: $date)
                TextField("Amount",value: $amount, format: .currency(code: "GBP"))
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("New Expense`")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup (placement:.topBarLeading){
                    Button("Cancel"){
                        dismiss()
                    }
                }
                ToolbarItemGroup (placement: .topBarTrailing){
                    Button("Save"){
                        let expense = Expense(name: name, date: date, value: amount)
                        context.insert(expense)
                        dismiss()
                    }
                }
            }
            
        }
    }
}
