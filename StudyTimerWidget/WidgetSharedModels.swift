//
//  WidgetSharedModels.swift
//  StudyTimerWidget
//
//  Created by Claude Code
//

import Foundation
import SwiftUI

// MARK: - Study Session
struct WidgetStudySession: Codable, Identifiable {
    let id: UUID
    let duration: TimeInterval
    let categoryName: String
    let date: Date
}

// MARK: - Category
struct WidgetCategory: Codable, Identifiable {
    let name: String
    var colorId: String
    var id: String { name }
}

// MARK: - Chart Data Point
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let categoryName: String
    let value: TimeInterval
}

// MARK: - Time Formatter
struct TimeFormatter {
    static func format(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60

        if hours > 0 {
            return String(format: "%dh%02dm%02ds", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%dm%02ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }

    static func formatCompact(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60

        if hours > 0 {
            return String(format: "%dh%02d", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
}

// MARK: - Widget Study Repository
class WidgetStudyRepository {
    static let shared = WidgetStudyRepository()

    // IMPORTANT: Doit correspondre à l'App Group ID configuré dans Xcode
    private let appGroupID = "group.com.jeune-sim.study-timer"
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    private init() {}

    func getAllSessions() -> [WidgetStudySession] {
        guard let sharedDefaults = sharedDefaults,
              let data = sharedDefaults.data(forKey: "sessions_data"),
              let sessions = try? JSONDecoder().decode([WidgetStudySession].self, from: data) else {
            return []
        }
        return sessions.sorted { $0.date > $1.date }
    }

    func getAllCategories() -> [WidgetCategory] {
        guard let sharedDefaults = sharedDefaults,
              let data = sharedDefaults.data(forKey: "categories_data"),
              let categories = try? JSONDecoder().decode([WidgetCategory].self, from: data) else {
            return []
        }
        return categories.sorted { $0.name < $1.name }
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

// MARK: - Widget Pastel Colors
struct WidgetPastelColors {
    static let all: [WidgetPastelColor] = [
        WidgetPastelColor(name: "", hex: "301A4B", id: "purple"),    // Violet profond
        WidgetPastelColor(name: "", hex: "6DB1BF", id: "cyan"),      // Cyan
        WidgetPastelColor(name: "", hex: "FFEAEC", id: "cream"),     // Crème rosé
        WidgetPastelColor(name: "", hex: "F39A9D", id: "coral"),     // Corail
        WidgetPastelColor(name: "", hex: "3F6C51", id: "forest")     // Vert forêt
    ]

    static func color(for id: String) -> Color {
        if let pastelColor = all.first(where: { $0.id == id }) {
            return Color(hex: pastelColor.hex)
        }
        return Color(hex: all[0].hex)
    }
}

struct WidgetPastelColor: Identifiable, Codable {
    let name: String
    let hex: String
    let id: String

    var color: Color {
        Color(hex: hex)
    }
}

// MARK: - Widget Category Colors
struct WidgetCategoryColors {
    static func color(for categoryName: String) -> Color {
        let categories = WidgetStudyRepository.shared.getAllCategories()
        if let category = categories.first(where: { $0.name == categoryName }) {
            return WidgetPastelColors.color(for: category.colorId)
        }
        return WidgetPastelColors.color(for: WidgetPastelColors.all[0].id)
    }
}
