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
        categories.removeAll { $0.name == category.name }
    }
    
    func renameCategory(_ category: Category, to newName: String) {
        guard !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if new name already exists
        if categories.contains(where: { $0.name.lowercased() == trimmedName.lowercased() && $0.name != category.name }) {
            return
        }
        
        if let newCategory = repository.renameCategory(category, to: trimmedName) {
            if let index = categories.firstIndex(where: { $0.name == category.name }) {
                categories[index] = newCategory
                categories.sort { $0.name < $1.name }
            }
        }
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