//
//  ExpenseView.swift
//  ExpenseSwiftData
//
//  Created by Dillon Dhayanandan on 11/05/2026.
//

import SwiftUI
import UIKit

struct ExpenseView: View {
    @Bindable var expense: Expense
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Optional image at the top
                if let data = expense.imageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 240, maxHeight: 180)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                } else {
                    // Placeholder
                    Image(systemName: "photo.on.rectangle.angled")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96, height: 72)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .center, spacing: 6) {
                    Text(expense.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)

                    Text(expense.date, format: .dateTime.month(.abbreviated).day().hour().minute())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack(alignment: .firstTextBaseline) {
                    Spacer()
                    Text(expense.value, format: .currency(code: "GBP"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: 600)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding()
        }
        .navigationTitle("Expense")
        .navigationBarTitleDisplayMode(.inline)
    }
}
