//
//  Category.swift
//  study-timer
//
//  Created by Claude on 04/10/2025.
//

import Foundation

struct Category: Codable, Identifiable {
    let name: String
    var colorId: String

    var id: String { name }

    init(name: String, colorId: String = "pink") {
        self.name = name
        self.colorId = colorId
    }
}

// MARK: - Equatable & Hashable
// L'égalité et le hash se basent uniquement sur le nom
// pour éviter les doublons lors de la mise à jour de la couleur
extension Category: Equatable, Hashable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

extension Category {
    static let defaultCategories = [
        Category(name: "Maths", colorId: "blue"),
        Category(name: "Informatique", colorId: "lavender"),
        Category(name: "Statistiques", colorId: "mint"),
        Category(name: "Physique", colorId: "peach"),
        Category(name: "Chimie", colorId: "yellow")
    ]
}
