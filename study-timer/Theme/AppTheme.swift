//
//  AppTheme.swift
//  study-timer
//
//  Created by Claude Code
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors
    static let background = Color(hex: "1C1C1E")
    static let cardBackground = Color(hex: "2C2C2E")
    static let primaryGreen = Color(hex: "32D74B")
    static let secondaryGreen = Color(hex: "30D158")
    static let accentGreen = Color(hex: "34C759")
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "98989D")
    static let divider = Color(hex: "3A3A3C")

    // Gradient for special effects
    static let greenGradient = LinearGradient(
        colors: [Color(hex: "32D74B"), Color(hex: "30D158")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Shadows
    static func cardShadow() -> some View {
        Color.black.opacity(0.3)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Category Colors
struct CategoryColors {
    private static let availableColors: [String] = [
        "FF453A", // Rouge
        "0A84FF", // Bleu
        "FFD60A", // Jaune
        "FF9F0A", // Orange
        "BF5AF2", // Violet
        "34C759", // Vert
        "FF375F", // Rose
        "5AC8FA", // Bleu clair
        "AF52DE", // Violet clair
        "FF8C00", // Orange foncé
        "32ADE6", // Bleu moyen
        "5AD427", // Vert lime
    ]
    
    private static var categoryColorMap: [String: String] = [:]
    private static var usedColorIndices: Set<Int> = []
    
    static func color(for categoryName: String) -> Color {
        // Si on a déjà une couleur pour cette catégorie, la retourner
        if let hexColor = categoryColorMap[categoryName] {
            return Color(hex: hexColor)
        }
        
        // Sinon, assigner une nouvelle couleur unique
        let colorIndex = findNextAvailableColorIndex()
        let hexColor = availableColors[colorIndex]
        categoryColorMap[categoryName] = hexColor
        usedColorIndices.insert(colorIndex)
        
        return Color(hex: hexColor)
    }
    
    private static func findNextAvailableColorIndex() -> Int {
        for i in 0..<availableColors.count {
            if !usedColorIndices.contains(i) {
                return i
            }
        }
        // Si toutes les couleurs sont utilisées, réinitialiser et recommencer
        usedColorIndices.removeAll()
        return 0
    }
    
    // Fonction pour réinitialiser les couleurs si nécessaire
    static func resetColors() {
        categoryColorMap.removeAll()
        usedColorIndices.removeAll()
    }

    // Fonction pour transférer la couleur d'une ancienne catégorie vers une nouvelle lors du renommage
    static func renameCategory(from oldName: String, to newName: String) {
        if let hexColor = categoryColorMap[oldName] {
            categoryColorMap[newName] = hexColor
            categoryColorMap.removeValue(forKey: oldName)
        }
    }
}
