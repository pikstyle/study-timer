//
//  StudyRepository.swift
//  study-timer
//
//  Created by Claude on 04/10/2025.
//

import Foundation
import SwiftUI
import Combine

extension Notification.Name {
    static let sessionSaved = Notification.Name("sessionSaved")
    static let dataCleared = Notification.Name("dataCleared")
}

protocol StudyRepositoryProtocol {
    func getAllSessions() -> [StudySession]
    func saveSession(_ session: StudySession)
    func deleteSession(_ session: StudySession)
    func clearAllSessions()
    func getAllCategories() -> [Category]
}

class StudyRepository: StudyRepositoryProtocol {
    static let shared = StudyRepository()

    @AppStorage("sessions_data") private var sessionsData: Data = Data()
    @AppStorage("categories_data") private var categoriesData: Data = Data()

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
        categories.insert(Category(name: session.categoryName))
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
        UserDefaults.standard.removeObject(forKey: "sessions_data")
        UserDefaults.standard.removeObject(forKey: "categories_data")
        UserDefaults.standard.synchronize()

        saveData()

        // Notify that data was cleared
        NotificationCenter.default.post(name: .dataCleared, object: nil)
    }

    func getAllCategories() -> [Category] {
        return Array(categories).sorted { $0.name < $1.name }
    }

    private func saveData() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            sessionsData = encoded
        }
        if let encoded = try? JSONEncoder().encode(Array(categories)) {
            categoriesData = encoded
        }
    }

    private func loadData() {
        if let decoded = try? JSONDecoder().decode([StudySession].self, from: sessionsData) {
            sessions = decoded
        }
        if let decoded = try? JSONDecoder().decode([Category].self, from: categoriesData) {
            categories = Set(decoded)
        }
    }
}