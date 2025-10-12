//
//  SettingsViewModel.swift
//  study-timer
//
//  Created by Claude on 08/10/2025.
//

import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var categories: [Category] = []
    
    private let repository: StudyRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: StudyRepositoryProtocol = StudyRepository.shared) {
        self.repository = repository
        setupNotifications()
        loadCategories()
    }
    
    func loadCategories() {
        categories = repository.getAllCategories()
    }
    
    func deleteCategory(_ category: Category) {
        repository.deleteCategory(category)
        // No need to update local list - the notification will handle it
    }
    
    func createCategory(_ categoryName: String) {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        // Check if category already exists
        if categories.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            return
        }
        
        let category = Category(name: trimmedName)
        repository.createCategory(category)
        
        // No need to update local list - the notification will handle it
        // The setupNotifications() method listens for .categoryRenamed which is sent by createCategory
    }
    
    func renameCategory(_ category: Category, to newName: String) {
        guard !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check if new name already exists
        if categories.contains(where: { $0.name.lowercased() == trimmedName.lowercased() && $0.name != category.name }) {
            return
        }

        let _ = repository.renameCategory(category, to: trimmedName)
        // No need to update local list - the notification will handle it
    }

    func updateCategoryColor(_ category: Category, colorId: String) {
        var updatedCategory = category
        updatedCategory.colorId = colorId
        repository.updateCategory(updatedCategory)
        loadCategories()
    }

    func clearAllData() {
        repository.clearAllSessions()
        loadCategories()
    }

    private func setupNotifications() {
        // Listen for category changes from other parts of the app
        NotificationCenter.default.publisher(for: .categoryDeleted)
            .sink { _ in
                self.loadCategories()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .categoryRenamed)
            .sink { _ in
                self.loadCategories()
            }
            .store(in: &cancellables)
            
        NotificationCenter.default.publisher(for: .sessionSaved)
            .sink { _ in
                self.loadCategories()
            }
            .store(in: &cancellables)
    }
}