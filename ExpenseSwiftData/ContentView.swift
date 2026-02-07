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

    @Environment(\.modelContext) private var context
    @Query(sort: \Expense.date) private var expenses: [Expense]

    var body: some View {
        NavigationStack {
            List {
                ForEach(expenses) { expense in
                    ExpenseCell(expense: expense)
                }
                .onDelete { indexSet in
                    // Use the same source of truth as the List (@Query) to determine deletions
                    let toDelete = indexSet.compactMap { idx in
                        expenses.indices.contains(idx) ? expenses[idx] : nil
                    }
                    toDelete.forEach { context.delete($0) }
                }
            }
            .navigationTitle("Expenses : £\(viewModel.totalFormatted)")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isPresentingAdd) {
                AddExpenseSheet()
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
