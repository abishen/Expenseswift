//
//  AddExpenseSheet.swift
//  ExpenseSwiftData
//
//  Created by Dillon Dhayanandan on 28/11/2025.
//
import SwiftUI
import CoreData
import UIKit

struct AddExpenseSheet: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @State var name: String = ""
    @State var date: Date = .now
    @State var amount: Double = 0
    @State private var image: UIImage?
    @State private var isShowingImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .camera

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .cornerRadius(8)
                    }
                    HStack {
                        Button {
                            // If camera not available (simulator), fall back to photo library
                            imagePickerSource = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
                            isShowingImagePicker = true
                        } label: {
                            Label("Capture / Choose Photo", systemImage: "camera"
                            )
                        }
                        Spacer()
                        if image != nil {
                            Button(role: .destructive) {
                                image = nil
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
                TextField("Expense Name", text: $name)
                DatePicker("Date", selection: $date)
                TextField("Amount", value: $amount, format: .currency(code: "GBP"))
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save") {
                        let expense = Expense(name: name, date: date, value: amount, imageData: image?.jpegData(compressionQuality: 0.8))
                        context.insert(expense)
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $image, sourceType: imagePickerSource)
        }
    }
}
