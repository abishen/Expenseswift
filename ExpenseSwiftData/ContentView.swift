//
//  ContentView.swift
//  ExpenseSwiftData
//
//  Created by Dillon Dhayanandan on 21/07/2025.
//

import SwiftUI
import SwiftData
import Charts

struct ContentView: View {
    @StateObject private var viewModel = ExpenseListViewModel()

    @State private var isPresentingAdd = false
    @State private var selectedExpense: Expense?

    @Environment(\.modelContext) private var context
    @Query(sort: \Expense.date) private var expenses: [Expense]
    

    private var groupedExpenses: [(key: Date, values: [Expense])] {
        let groups = Dictionary(grouping: expenses) { expense in
            Calendar.current.startOfDay(for: expense.date)
        }
        return groups
            .map { (key: $0.key, values: $0.value) }
            .sorted { $0.key > $1.key }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedExpenses, id: \.key) { group in
                    Section(header: Text(group.key, style: .date)) {
                        ForEach(group.values) { expense in
                            ExpenseCell(expense: expense)
                                .swipeActions(edge: .leading) {
                                    Button {
                                        selectedExpense = expense
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                        .onDelete { indexSet in
                            // Map the indexSet (indices within the section) to the
                            // actual Expense objects and delete them from the model
                            let toDelete = indexSet.compactMap { idx in
                                group.values.indices.contains(idx) ? group.values[idx] : nil
                            }
                            toDelete.forEach { context.delete($0) }
                        }
                    }
                }
            }
            .navigationTitle("Expenses : £\(viewModel.totalFormatted)")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isPresentingAdd) {
                AddExpenseSheet()
            }
            // Sheet to edit an existing expense. UpdateExpenseSheet uses @Bindable
            // so we can pass the model instance directly.
            .sheet(item: $selectedExpense) { expense in
                UpdateExpenseSheet(expense: expense)
            }
            .toolbar {
                if !viewModel.isEmpty {
                    Button("Add Expense", systemImage: "plus") {
                        isPresentingAdd = true
                    }
                }
            }
            .overlay {
                if viewModel.isEmpty {
                    EmptyExpensesView {
                        isPresentingAdd = true
                    }
                    .offset(y: -60)
                }
            }
            // Keep the ViewModel in sync with SwiftData query results
            .onAppear {
                viewModel.update(expenses: expenses)
            }
            .onChange(of: expenses) { _, newValue in
                viewModel.update(expenses: newValue)
            }
        }

        ExpensesChartView(slices: viewModel.chartSlices)
            .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
    }
}

private struct ExpensesChartView: View {
    let slices: [(name: String, value: Double)]

    var body: some View {
        Chart(slices, id: \.name) { slice in
            SectorMark(
                angle: .value(Text(verbatim: slice.name), slice.value)
            )
            .foregroundStyle(by: .value(Text(verbatim: slice.name), slice.name))
        }
    }
}

private struct EmptyExpensesView: View {
    var onAdd: () -> Void

    var body: some View {
        ContentUnavailableView(
            label: {
                Label("No Expenses", systemImage: "list.bullet.rectangle.portrait")
            },
            description: {
                Text("Add your first expense.")
            },
            actions: {
                Button("Add Expense", action: onAdd)
            }
        )
    }
}

#Preview {
    ContentView()
}
