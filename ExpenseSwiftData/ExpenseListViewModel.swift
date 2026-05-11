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
    // Grouped expenses by start of day (newest-first)
    @Published private(set) var groupedExpenses: [(key: Date, values: [Expense])] = []

    // Outputs
    @Published private(set) var totalFormatted: String = "0.00"
    @Published private(set) var isEmpty: Bool = true
    @Published private(set) var chartSlices: [(name: String, value: Double)] = []

    // Currency code could be made configurable later
    private let currencyCode = "GBP"

    func update(expenses: [Expense]) {
        self.expenses = expenses
        recompute()
        computeGroups()
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

        let total = expenses.map(\.value).reduce(0.0, +)
        totalFormatted = String(format: "%.2f", total)

        chartSlices = expenses.map { ($0.name, $0.value) }
    }

    private func computeGroups() {
        let groups = Dictionary(grouping: expenses) { expense in
            Calendar.current.startOfDay(for: expense.date)
        }
        groupedExpenses = groups
            .map { (key: $0.key, values: $0.value) }
            .sorted { $0.key > $1.key }
    }

    // Export expenses to CSV and return a file URL for sharing. Caller is responsible
    // for presenting a share sheet with the returned URL.
    func createCSV() -> URL? {
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
