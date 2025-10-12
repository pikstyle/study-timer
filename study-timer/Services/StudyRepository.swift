//
//  StudyRepository.swift
//  study-timer
//
//  Created by Claude on 04/10/2025.
//

import Foundation
import SwiftUI
import Combine
import WidgetKit

extension Notification.Name {
    static let sessionSaved = Notification.Name("sessionSaved")
    static let dataCleared = Notification.Name("dataCleared")
    static let categoryDeleted = Notification.Name("categoryDeleted")
    static let categoryRenamed = Notification.Name("categoryRenamed")
}

protocol StudyRepositoryProtocol {
    func getAllSessions() -> [StudySession]
    func saveSession(_ session: StudySession)
    func deleteSession(_ session: StudySession)
    func clearAllSessions()
    func getAllCategories() -> [Category]
    func createCategory(_ category: Category)
    func deleteCategory(_ category: Category)
    func renameCategory(_ oldCategory: Category, to newName: String) -> Category?
    func updateCategory(_ category: Category)
}

class StudyRepository: StudyRepositoryProtocol {
    static let shared = StudyRepository()

    // IMPORTANT: App Group pour partager les données avec le widget
    private let appGroupID = "group.com.jeune-sim.study-timer"
    private var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? UserDefaults.standard
    }

    private var sessions: [StudySession] = []
    private var categories: Set<Category> = []

    private init() {
        loadData()
    }

    func getAllSessions() -> [StudySession] {
        return sessions.sorted { $0.date > $1.date }
    }

    func saveSession(_ session: StudySession) {
        sessions.append(session)
        // Only create a new category if it doesn't exist
        // If it already exists, keep the existing one with its color
        if !categories.contains(where: { $0.name == session.categoryName }) {
            categories.insert(Category(name: session.categoryName))
        }
        saveData()

        // Notify that a session was saved
        NotificationCenter.default.post(name: .sessionSaved, object: session)
    }

    func deleteSession(_ session: StudySession) {
        sessions.removeAll { $0.id == session.id }
        saveData()
    }

    func clearAllSessions() {
        sessions.removeAll()
        categories.removeAll()

        // Clear UserDefaults completely
        sharedDefaults.removeObject(forKey: "sessions_data")
        sharedDefaults.removeObject(forKey: "categories_data")
        sharedDefaults.synchronize()

        // Notify that data was cleared
        NotificationCenter.default.post(name: .dataCleared, object: nil)
    }

    func getAllCategories() -> [Category] {
        return Array(categories).sorted { $0.name < $1.name }
    }
    
    func createCategory(_ category: Category) {
        categories.insert(category)
        saveData()
        
        // Notify that a category was created
        NotificationCenter.default.post(name: .categoryRenamed, object: nil)
    }

    func deleteCategory(_ category: Category) {
        // Remove the category from the set
        categories.remove(category)
        
        // Update sessions to use a default category or handle orphaned sessions
        // For simplicity, we'll remove sessions with this category
        sessions.removeAll { $0.categoryName == category.name }
        
        saveData()
        
        // Notify that a category was deleted
        NotificationCenter.default.post(name: .categoryDeleted, object: category)
    }

    func renameCategory(_ oldCategory: Category, to newName: String) -> Category? {
        guard !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }

        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        // Keep the same colorId when renaming
        let newCategory = Category(name: trimmedName, colorId: oldCategory.colorId)

        // Check if new name already exists
        if categories.contains(where: { $0.name == trimmedName }) {
            return nil
        }

        // Remove old category and add new one
        categories.remove(oldCategory)
        categories.insert(newCategory)

        // Update all sessions with the old category name
        for index in sessions.indices {
            if sessions[index].categoryName == oldCategory.name {
                sessions[index] = StudySession(
                    id: sessions[index].id,
                    duration: sessions[index].duration,
                    categoryName: trimmedName,
                    date: sessions[index].date
                )
            }
        }

        saveData()

        // Notify that a category was renamed
        NotificationCenter.default.post(name: .categoryRenamed, object: ["old": oldCategory, "new": newCategory])
        return newCategory
    }

    func updateCategory(_ category: Category) {
        // Remove old version and insert updated version
        categories.remove(category)
        categories.insert(category)
        saveData()

        // Notify that a category was updated
        NotificationCenter.default.post(name: .categoryRenamed, object: nil)
    }

    private func saveData() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            sharedDefaults.set(encoded, forKey: "sessions_data")
            print("✅ Saved \(sessions.count) sessions to App Group")
        }
        if let encoded = try? JSONEncoder().encode(Array(categories)) {
            sharedDefaults.set(encoded, forKey: "categories_data")
            print("✅ Saved \(categories.count) categories to App Group")
        }

        // Force synchronisation
        if sharedDefaults.synchronize() {
            print("✅ UserDefaults synchronized successfully")
        } else {
            print("⚠️ UserDefaults synchronization might have failed")
        }

        // Rafraîchir tous les widgets après la sauvegarde
        print("🔄 Reloading all widget timelines...")
        WidgetCenter.shared.reloadAllTimelines()

        // Force aussi un rafraîchissement spécifique pour chaque widget
        WidgetCenter.shared.reloadTimelines(ofKind: "TodaySmallWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "WeekSmallWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "MonthSmallWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "OverviewMediumWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "DetailedLargeWidget")
        print("✅ Widget refresh commands sent")
    }

    private func loadData() {
        if let data = sharedDefaults.data(forKey: "sessions_data"),
           let decoded = try? JSONDecoder().decode([StudySession].self, from: data) {
            sessions = decoded
        }
        if let data = sharedDefaults.data(forKey: "categories_data"),
           let decoded = try? JSONDecoder().decode([Category].self, from: data) {
            categories = Set(decoded)
        }
    }
}