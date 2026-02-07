//
//  Expense.swift
//  ExpenseSwiftData
//
//  Created by Dillon Dhayanandan on 21/07/2025.
//
import Foundation
import SwiftUI
import SwiftData

@Model
class Expense {
    var name: String
    var  date: Date
    var value: Double
    
    init(name: String, date: Date, value: Double) {
        self.name = name
        self.date = date
        self.value = value
    }
}

// Equatable conformance for efficient comparison
// Using object identity for SwiftData models
extension Expense: Equatable {
    static func == (lhs: Expense, rhs: Expense) -> Bool {
        lhs === rhs
    }
}
