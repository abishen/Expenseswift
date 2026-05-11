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
    @State private var selectedTab = 0
    

    // Grouping is now handled by the ViewModel

    var body: some View {
        TabView(selection: $selectedTab) {
            // Expenses list tab
            NavigationStack {
                List {
                    ForEach(viewModel.groupedExpenses, id: \.key) { group in
                        Section(header: Text(group.key, style: .date)) {
                            ForEach(group.values) { expense in
                                NavigationLink {
                                    ExpenseView(expense: expense)
                                } label: {
                                    ExpenseCell(expense: expense)
                                }
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
                .sheet(item: $selectedExpense) { expense in
                    UpdateExpenseSheet(expense: expense)
                }
                .toolbar {
                    if !viewModel.isEmpty {
                        HStack {
                            Button("Add Expense", systemImage: "plus") {
                                isPresentingAdd = true
                            }
                            Button("Export", systemImage: "square.and.arrow.up") {
                                exportURL = viewModel.createCSV()
                                isShowingShare = true
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
                .onAppear {
                    viewModel.update(expenses: expenses)
                }
                .onChange(of: expenses) { _, newValue in
                    viewModel.update(expenses: newValue)
                }
            }
            .tabItem {
                Label("Expenses", systemImage: "sterlingsign.circle")
            }
            .tag(0)

            // Chart tab
            NavigationStack {
                ExpensesChartView(slices: viewModel.chartSlices)
                    .navigationTitle("Chart")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        // Allow export from chart tab as well
                        if !viewModel.isEmpty {
                            Button("Export", systemImage: "square.and.arrow.up") {
                                exportURL = viewModel.createCSV()
                                isShowingShare = true
                            }
                        }
                    }
            }
            .tabItem {
                Label("Chart", systemImage: "chart.pie.fill")
            }
            .tag(1)
        }
        // Share sheet for CSV
        .sheet(isPresented: $isShowingShare) {
            if let url = exportURL {
                ShareSheet(activityItems: [url])
            } else {
                Text("Unable to prepare export")
            }
        }
    }
}

// MARK: - CSV export
// CSV export is implemented in the ViewModel (MVVM)

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
