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
    @State private var isShowingShare = false
    @State private var exportURL: URL?
    

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
            .navigationTitle("Expenses : \(viewModel.totalFormatted)")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isPresentingAdd) {
                AddExpenseSheet()
            }
            // Sheet to edit an existing expense. UpdateExpenseSheet uses @Bindable
            // so we can pass the model instance directly.
            .sheet(item: $selectedExpense) { expense in
                UpdateExpenseSheet(expense: expense)
            }
            // CSV export share sheet
            .sheet(isPresented: $isShowingShare) {
                if let url = exportURL {
                    ShareSheet(activityItems: [url])
                } else {
                    Text("Unable to prepare export")
                }
            }
            .toolbar {
                if !viewModel.isEmpty {
                    HStack {
                        Button("Add Expense", systemImage: "plus") {
                            isPresentingAdd = true
                        }
                        Button("Export", systemImage: "square.and.arrow.up") {
                            if let url = createCSV() {
                                exportURL = url
                                isShowingShare = true
                            }
                        }
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

// MARK: - CSV export
extension ContentView {
    private func createCSV() -> URL? {
        let fm = FileManager.default
        let tmpDir = fm.temporaryDirectory
        let fileURL = tmpDir.appendingPathComponent("expenses_export_\(Int(Date().timeIntervalSince1970)).csv")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        var csv = "Date,Name,Amount\n"
        for expense in expenses {
            let date = dateFormatter.string(from: expense.date)
            let name = expense.name.replacingOccurrences(of: "\"", with: "\"\"")
            let amount = String(format: "%.2f", expense.value)
            // Escape name with quotes if it contains comma
            let safeName = name.contains(",") ? "\"\(name)\"" : name
            csv += "\(date),\(safeName),\(amount)\n"
        }

        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to write CSV: \(error)")
            return nil
        }
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
