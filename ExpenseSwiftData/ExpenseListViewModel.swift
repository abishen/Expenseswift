//
//  ExpenseListViewModel.swift
//  ExpenseSwiftData
//
//  Created by Dillon Dhayanandan on 21/07/2025.
//

import Foundation

final class ExpenseListViewModel: ObservableObject {

    // Inputs
    @Published private(set) var expenses: [Expense] = []

    // Outputs
    @Published private(set) var totalFormatted: String = "0.00"
    @Published private(set) var isEmpty: Bool = true
    @Published private(set) var chartSlices: [(name: String, value: Double)] = []

    // Currency code could be made configurable later
    private let currencyCode = "GBP"
    
    // Reusable formatter to avoid creating new instances on every computation
    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter
    }()

    func update(expenses: [Expense]) {
        self.expenses = expenses
        recompute()
    }

    func deleteOffsets(_ offsets: IndexSet) -> [Expense] {
        // Return the concrete Expense instances to delete from SwiftData in the View.
        offsets.compactMap { index in
            guard expenses.indices.contains(index) else { return nil }
            return expenses[index]
        }
    }

    // MARK: - Private

    private func recompute() {
        isEmpty = expenses.isEmpty

        // Use reduce directly without intermediate map for better performance
        let total = expenses.reduce(0.0) { $0 + $1.value }
        // Fallback to plain number format (formatter should not return nil for valid NSNumber)
        totalFormatted = currencyFormatter.string(from: NSNumber(value: total)) ?? "0.00"

        // Map is already optimized by the compiler and reserves capacity internally
        chartSlices = expenses.map { ($0.name, $0.value) }
    }
}
