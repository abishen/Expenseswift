//
//  ContentView.swift
//  ExpenseSwiftData
//
//  Created by Dillon Dhayanandan on 21/07/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isExpanded = false
    @Environment(\.modelContext) private var context
    @Query(sort: \Expense.date) var expenses: [Expense]
    var body: some View {
        NavigationStack{
            List{
                ForEach(expenses) { expense in
                    ExpenseCell(expense: expense)
                    
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        context.delete(expenses[index])
                    }
                }
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isExpanded) { AddExpenseSheet()}
            .toolbar {
                if !expenses.isEmpty {
                    Button("Add Expense", systemImage: "plus") {
                        isExpanded = true
                    }
                }
            }
            .overlay {
                if expenses.isEmpty {
                    ContentUnavailableView(label: {
                        Label("No Expenses", systemImage: "list.bullet.rectangle.portrait")
                    }, description: {
                        Text("Add your first expense.")
                    }, actions: {
                        Button("Add Expense") {
                            isExpanded = true
                        }
                    }).offset(y: -60)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
struct ExpenseCell: View {
    var expense: Expense
    var body: some View {
        HStack{
            Text(expense.date, format: .dateTime.month(.abbreviated).day())
                .frame(width: 70, alignment: .leading)
            Text(expense.name)
            Spacer()
            Text(expense.value, format: .currency(code: "USD"))
        }
       
    }
}
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
                TextField("Amount",value: $amount, format: .currency(code: "USD"))
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("New Expense")
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

struct UpdateExpenseSheet: View {

    @Bindable var expense: Expense
    @Environment(\ .dismiss) var dismiss

    var body: some View {
        NavigationStack{
            
            Form {
                TextField("Expense Name", text: $expense.name )
                DatePicker("Date", selection: $expense.date)
                TextField("Amount",value: $expense.value, format: .currency(code: "USD"))
                    .keyboardType(.decimalPad)
            }
        }
    }
}

