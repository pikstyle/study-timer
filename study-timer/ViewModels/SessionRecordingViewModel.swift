//
//  SessionRecordingViewModel.swift
//  study-timer
//
//  Created by Claude on 04/10/2025.
//

import Foundation
import Combine

class SessionRecordingViewModel: ObservableObject {
    @Published var sessionDate = Date()
    @Published var selectedCategory: Category?
    @Published var availableCategories: [Category] = []
    @Published var showingNewCategoryAlert = false
    @Published var newCategoryName = ""

    let sessionDuration: TimeInterval
    private let repository: StudyRepositoryProtocol
    private let onSessionSaved: () -> Void

    init(
        sessionDuration: TimeInterval,
        repository: StudyRepositoryProtocol = StudyRepository.shared,
        onSessionSaved: @escaping () -> Void = {}
    ) {
        self.sessionDuration = sessionDuration
        self.repository = repository
        self.onSessionSaved = onSessionSaved
        loadCategories()
    }

    var formattedDuration: String {
        TimeFormatter.format(sessionDuration)
    }

    var canSaveSession: Bool {
        selectedCategory != nil
    }

    var categoryMenuText: String {
        selectedCategory?.name ?? "Sélectionner une catégorie"
    }

    func createNewCategory() {
        guard !newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let categoryName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        let category = Category(name: categoryName)

        // Add to local list
        if !availableCategories.contains(where: { $0.name == categoryName }) {
            availableCategories.append(category)
            availableCategories.sort { $0.name < $1.name }
        }

        selectedCategory = category
        newCategoryName = ""
        showingNewCategoryAlert = false

    }

    func saveSession() -> Bool {
        guard let category = selectedCategory else { return false }

        let session = StudySession(
            duration: sessionDuration,
            categoryName: category.name,
            date: sessionDate
        )

        repository.saveSession(session)
        onSessionSaved()
        return true
    }

    func showNewCategoryAlert() {
        showingNewCategoryAlert = true
    }

    func selectCategory(_ category: Category) {
        selectedCategory = category
    }

    private func loadCategories() {
        availableCategories = repository.getAllCategories()
    }
}