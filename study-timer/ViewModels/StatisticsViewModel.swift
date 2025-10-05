//
//  StatisticsViewModel.swift
//  study-timer
//
//  Created by Claude on 04/10/2025.
//

import Foundation
import Combine

class StatisticsViewModel: ObservableObject {
    @Published var todayTime: TimeInterval = 0
    @Published var weekTime: TimeInterval = 0
    @Published var monthTime: TimeInterval = 0
    @Published var categoryTimes: [String: TimeInterval] = [:]

    private let repository: StudyRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    init(repository: StudyRepositoryProtocol = StudyRepository.shared) {
        self.repository = repository
        calculateStatistics()

        // Listen for data updates
        NotificationCenter.default.publisher(for: .sessionSaved)
            .sink { _ in
                self.calculateStatistics()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .dataCleared)
            .sink { _ in
                self.calculateStatistics()
            }
            .store(in: &cancellables)
    }

    func refresh() {
        calculateStatistics()
    }

    func addTestData() {
        let testSessions = [
            StudySession(duration: 3600, categoryName: "Maths"),
            StudySession(duration: 1800, categoryName: "Informatique"),
            StudySession(duration: 2400, categoryName: "Statistiques")
        ]

        testSessions.forEach { repository.saveSession($0) }
        calculateStatistics()
    }

    func clearAllData() {
        repository.clearAllSessions()
        calculateStatistics()
    }

    func printDebugInfo() {
        print("=== STATISTIQUES DEBUG ===")
        print("Temps aujourd'hui: \(todayTime)")
        print("Temps semaine: \(weekTime)")
        print("Temps mois: \(monthTime)")
        print("Catégories: \(categoryTimes)")
        print("Nombre de sessions: \(repository.getAllSessions().count)")
        print("==========================")
    }

    private func calculateStatistics() {
        let sessions = repository.getAllSessions()

        todayTime = sessions
            .filter { $0.isToday }
            .reduce(0) { $0 + $1.duration }

        weekTime = sessions
            .filter { $0.isThisWeek }
            .reduce(0) { $0 + $1.duration }

        monthTime = sessions
            .filter { $0.isThisMonth }
            .reduce(0) { $0 + $1.duration }

        categoryTimes = Dictionary(grouping: sessions, by: { $0.categoryName })
            .mapValues { $0.reduce(0) { $0 + $1.duration } }
    }
}

// MARK: - Chart Data
extension StatisticsViewModel {
    var chartData: [ChartDataPoint] {
        return categoryTimes.map { name, time in
            ChartDataPoint(categoryName: name, value: time)
        }
    }

    var todayChartData: [ChartDataPoint] {
        let todaySessions = repository.getAllSessions().filter { $0.isToday }
        let todayCategories = Dictionary(grouping: todaySessions, by: { $0.categoryName })
            .mapValues { $0.reduce(0) { $0 + $1.duration } }

        return todayCategories.map { name, time in
            ChartDataPoint(categoryName: name, value: time)
        }
    }

    var weekChartData: [ChartDataPoint] {
        let weekSessions = repository.getAllSessions().filter { $0.isThisWeek }
        let weekCategories = Dictionary(grouping: weekSessions, by: { $0.categoryName })
            .mapValues { $0.reduce(0) { $0 + $1.duration } }

        return weekCategories.map { name, time in
            ChartDataPoint(categoryName: name, value: time)
        }
    }

    var monthChartData: [ChartDataPoint] {
        let monthSessions = repository.getAllSessions().filter { $0.isThisMonth }
        let monthCategories = Dictionary(grouping: monthSessions, by: { $0.categoryName })
            .mapValues { $0.reduce(0) { $0 + $1.duration } }

        return monthCategories.map { name, time in
            ChartDataPoint(categoryName: name, value: time)
        }
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let categoryName: String
    let value: TimeInterval
}