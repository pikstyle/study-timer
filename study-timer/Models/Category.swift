//
//  Category.swift
//  study-timer
//
//  Created by Claude on 04/10/2025.
//

import Foundation

struct Category: Codable, Identifiable, Equatable, Hashable {
    let name: String

    var id: String { name }

    init(name: String) {
        self.name = name
    }
}

extension Category {
    static let defaultCategories = [
        Category(name: "Maths"),
        Category(name: "Informatique"),
        Category(name: "Statistiques"),
        Category(name: "Physique"),
        Category(name: "Chimie")
    ]
}