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
    // Optional binary data for an attached photo (JPEG/PNG)
    var imageData: Data?
    
    init(name: String, date: Date, value: Double, imageData: Data? = nil) {
        self.name = name
        self.date = date
        self.value = value
        self.imageData = imageData
    }
}
