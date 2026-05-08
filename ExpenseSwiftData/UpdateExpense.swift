//
//  UpdateExpense.swift
//  ExpenseSwiftData
//
//  Created by Dillon Dhayanandan on 28/11/2025.
//
import SwiftUI
import Foundation
import SwiftData
import UIKit

struct UpdateExpenseSheet: View {
    @Bindable var expense: Expense
    @Environment(\.dismiss) var dismiss
    @State private var image: UIImage?
    @State private var isShowingImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .camera

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if let uiImage = image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .cornerRadius(8)
                    }
                    HStack {
                        Button {
                            imagePickerSource = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
                            isShowingImagePicker = true
                        } label: {
                            Label("Capture / Choose Photo", systemImage: "camera")
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

                TextField("Expense Name", text: $expense.name)
                DatePicker("Date", selection: $expense.date)
                TextField("Amount", value: $expense.value, format: .currency(code: "GBP"))
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        // Changes are auto-saved by SwiftData when the context is saved by the host view,
                        // but dismissing here is fine. If you need explicit save, handle it in the caller.
                        // Persist the selected image back to the model
                        expense.imageData = image?.jpegData(compressionQuality: 0.8)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let data = expense.imageData, let ui = UIImage(data: data) {
                image = ui
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $image, sourceType: imagePickerSource)
        }
    }
}
