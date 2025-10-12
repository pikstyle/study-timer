//
//  CategoryColorPicker.swift
//  study-timer
//
//  Created by Claude on 11/10/2025.
//

import SwiftUI

struct CategoryColorPicker: View {
    @Binding var selectedColorId: String
    let title: String

    init(selectedColorId: Binding<String>, title: String = "Couleur") {
        self._selectedColorId = selectedColorId
        self.title = title
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(title.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .tracking(1)
                    .foregroundColor(AppTheme.textSecondary)
            } icon: {
                Image(systemName: "paintpalette.fill")
                    .foregroundColor(AppTheme.primaryGreen)
            }

            // Grille de couleurs
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 50), spacing: 12)], spacing: 12) {
                ForEach(PastelColors.all) { pastelColor in
                    ColorButton(
                        pastelColor: pastelColor,
                        isSelected: selectedColorId == pastelColor.id
                    ) {
                        selectedColorId = pastelColor.id
                    }
                }
            }
        }
    }
}

struct ColorButton: View {
    let pastelColor: PastelColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(pastelColor.color)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                )
                .overlay(
                    Circle()
                        .stroke(AppTheme.primaryGreen, lineWidth: isSelected ? 2 : 0)
                        .padding(-3)
                )
                .shadow(color: pastelColor.color.opacity(0.4), radius: isSelected ? 8 : 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()

        VStack {
            CategoryColorPicker(selectedColorId: .constant("pink"))
                .padding()
        }
    }
}
