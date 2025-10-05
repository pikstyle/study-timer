//
//  StudySession.swift
//  study-timer
//
//  Created by Claude on 04/10/2025.
//

import Foundation

struct StudySession: Codable, Identifiable, Equatable {
    let id: UUID
    let duration: TimeInterval
    let categoryName: String
    let date: Date

    init(duration: TimeInterval, categoryName: String, date: Date = Date()) {
        self.id = UUID()
        self.duration = duration
        self.categoryName = categoryName
        self.date = date
    }
}

extension StudySession {
    var formattedDuration: String {
        TimeFormatter.format(duration)
    }

    var isToday: Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }

    var isThisWeek: Bool {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return date >= startOfWeek
    }

    var isThisMonth: Bool {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        return date >= startOfMonth
    }
}