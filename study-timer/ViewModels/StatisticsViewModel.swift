//
//  StatisticsViewModel.swift
//  study-timer
//
//  Created by Claude on 04/10/2025.
//

import Foundation
import Combine
import SwiftUI

// Forward declaration pour éviter les imports circulaires
enum StatsPeriod: String, CaseIterable, Identifiable {
    case today = "Aujourd'hui"
    case week = "Cette semaine"
    case month = "Ce mois"

    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .today: return "sun.max.fill"
        case .week: return "calendar.badge.clock"
        case .month: return "chart.bar.fill"
        }
    }
    
    var subtitle: String {
        switch self {
        case .today: return "Temps d'étude"
        case .week: return "7 derniers jours"
        case .month: return "30 derniers jours"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .today: return AppTheme.primaryGreen
        case .week: return Color(hex: "0A84FF")
        case .month: return Color(hex: "FF9F0A")
        }
    }
}

class StatisticsViewModel: ObservableObject {
    @Published var todayTime: TimeInterval = 0
    @Published var weekTime: TimeInterval = 0
    @Published var monthTime: TimeInterval = 0
    @Published var categoryTimes: [String: TimeInterval] = [:]
    @Published var yesterdayTime: TimeInterval = 0
    @Published var dailyAverage: TimeInterval = 0
    @Published var weeklyAverage: TimeInterval = 0
    @Published var weekDailyAverage: TimeInterval = 0  // Moyenne/jour de la semaine en cours
    @Published var monthDailyAverage: TimeInterval = 0 // Moyenne/jour du mois en cours
    @Published var monthWeeklyAverage: TimeInterval = 0 // Moyenne/semaine du mois en cours

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

        NotificationCenter.default.publisher(for: .categoryDeleted)
            .sink { _ in
                self.calculateStatistics()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .categoryRenamed)
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
        let calendar = Calendar.current

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

        // Calculer le temps d'hier
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        yesterdayTime = sessions
            .filter { calendar.isDate($0.date, inSameDayAs: yesterday) }
            .reduce(0) { $0 + $1.duration }

        // Calculer la moyenne quotidienne (basée sur les 30 derniers jours)
        calculateDailyAverage(sessions: sessions, calendar: calendar)

        // Calculer la moyenne hebdomadaire (basée sur les 12 dernières semaines)
        calculateWeeklyAverage(sessions: sessions, calendar: calendar)

        // Calculer la moyenne quotidienne de la semaine en cours
        calculateWeekDailyAverage(sessions: sessions, calendar: calendar)

        // Calculer les moyennes du mois en cours
        calculateMonthAverages(sessions: sessions, calendar: calendar)
    }

    private func calculateDailyAverage(sessions: [StudySession], calendar: Calendar) {
        // Obtenir les sessions des 30 derniers jours
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentSessions = sessions.filter { $0.date >= thirtyDaysAgo }

        guard !recentSessions.isEmpty else {
            dailyAverage = 0
            return
        }

        // Grouper par jour et calculer le total par jour
        let sessionsByDay = Dictionary(grouping: recentSessions) { session -> Date in
            calendar.startOfDay(for: session.date)
        }

        // Calculer le nombre de jours avec au moins une session
        let daysWithSessions = sessionsByDay.count

        guard daysWithSessions > 0 else {
            dailyAverage = 0
            return
        }

        // Calculer le temps total et la moyenne
        let totalTime = recentSessions.reduce(0) { $0 + $1.duration }
        dailyAverage = totalTime / TimeInterval(daysWithSessions)
    }

    private func calculateWeeklyAverage(sessions: [StudySession], calendar: Calendar) {
        // Obtenir les sessions des 12 dernières semaines (environ 3 mois)
        let twelveWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -12, to: Date()) ?? Date()
        let recentSessions = sessions.filter { $0.date >= twelveWeeksAgo }

        guard !recentSessions.isEmpty else {
            weeklyAverage = 0
            return
        }

        // Grouper par semaine
        let sessionsByWeek = Dictionary(grouping: recentSessions) { session -> Date in
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: session.date)
            return weekInterval?.start ?? session.date
        }

        // Calculer le nombre de semaines avec au moins une session
        let weeksWithSessions = sessionsByWeek.count

        guard weeksWithSessions > 0 else {
            weeklyAverage = 0
            return
        }

        // Calculer le temps total et la moyenne
        let totalTime = recentSessions.reduce(0) { $0 + $1.duration }
        weeklyAverage = totalTime / TimeInterval(weeksWithSessions)
    }

    private func calculateWeekDailyAverage(sessions: [StudySession], calendar: Calendar) {
        // Obtenir les sessions de la semaine en cours
        let weekSessions = sessions.filter { $0.isThisWeek }

        guard !weekSessions.isEmpty else {
            weekDailyAverage = 0
            return
        }

        // Grouper par jour
        let sessionsByDay = Dictionary(grouping: weekSessions) { session -> Date in
            calendar.startOfDay(for: session.date)
        }

        let daysWithSessions = sessionsByDay.count

        guard daysWithSessions > 0 else {
            weekDailyAverage = 0
            return
        }

        // Calculer la moyenne quotidienne de la semaine
        let totalTime = weekSessions.reduce(0) { $0 + $1.duration }
        weekDailyAverage = totalTime / TimeInterval(daysWithSessions)
    }

    private func calculateMonthAverages(sessions: [StudySession], calendar: Calendar) {
        // Obtenir les sessions du mois en cours
        let monthSessions = sessions.filter { $0.isThisMonth }

        guard !monthSessions.isEmpty else {
            monthDailyAverage = 0
            monthWeeklyAverage = 0
            return
        }

        // Calculer la moyenne quotidienne du mois
        let sessionsByDay = Dictionary(grouping: monthSessions) { session -> Date in
            calendar.startOfDay(for: session.date)
        }

        let daysWithSessions = sessionsByDay.count

        if daysWithSessions > 0 {
            let totalTime = monthSessions.reduce(0) { $0 + $1.duration }
            monthDailyAverage = totalTime / TimeInterval(daysWithSessions)
        } else {
            monthDailyAverage = 0
        }

        // Calculer la moyenne hebdomadaire du mois
        let sessionsByWeek = Dictionary(grouping: monthSessions) { session -> Date in
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: session.date)
            return weekInterval?.start ?? session.date
        }

        let weeksWithSessions = sessionsByWeek.count

        if weeksWithSessions > 0 {
            let totalTime = monthSessions.reduce(0) { $0 + $1.duration }
            monthWeeklyAverage = totalTime / TimeInterval(weeksWithSessions)
        } else {
            monthWeeklyAverage = 0
        }
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

struct TimelineDataPoint: Identifiable {
    let id = UUID()
    let period: String      // "14h", "Lundi", "Semaine 1"
    let periodValue: Int    // 14, 1, 1 (pour le tri)
    let totalTime: TimeInterval
    let date: Date?         // Pour référence si nécessaire
}

// MARK: - Sessions Data
extension StatisticsViewModel {
    var todaySessions: [StudySession] {
        return repository.getAllSessions().filter { $0.isToday }
            .sorted { $0.date > $1.date } // Plus récentes en premier
    }
    
    var weekSessions: [StudySession] {
        return repository.getAllSessions().filter { $0.isThisWeek }
            .sorted { $0.date > $1.date }
    }
    
    var monthSessions: [StudySession] {
        return repository.getAllSessions().filter { $0.isThisMonth }
            .sorted { $0.date > $1.date }
    }
    
    func sessions(for period: StatsPeriod) -> [StudySession] {
        switch period {
        case .today: return todaySessions
        case .week: return weekSessions
        case .month: return monthSessions
        }
    }
    
    // MARK: - Timeline Data for Charts
    func timelineData(for period: StatsPeriod) -> [TimelineDataPoint] {
        switch period {
        case .today: return todayTimelineData
        case .week: return weekTimelineData
        case .month: return monthTimelineData
        }
    }
    
    private var todayTimelineData: [TimelineDataPoint] {
        let sessions = todaySessions
        guard !sessions.isEmpty else { return [] }
        
        // Groupe les sessions par heure
        let calendar = Calendar.current
        var hourlyData: [Int: TimeInterval] = [:]
        
        for session in sessions {
            let hour = calendar.component(.hour, from: session.date)
            hourlyData[hour, default: 0] += session.duration
        }
        
        // Trouve la plage d'heures
        let minHour = sessions.map { calendar.component(.hour, from: $0.date) }.min() ?? 0
        let maxHour = sessions.map { calendar.component(.hour, from: $0.date) }.max() ?? 23
        
        // Crée les points de données pour toutes les heures dans la plage
        var dataPoints: [TimelineDataPoint] = []
        for hour in minHour...maxHour {
            let totalTime = hourlyData[hour] ?? 0
            dataPoints.append(TimelineDataPoint(
                period: "\(hour)h",
                periodValue: hour,
                totalTime: totalTime,
                date: nil
            ))
        }
        
        return dataPoints.sorted { $0.periodValue < $1.periodValue }
    }
    
    private var weekTimelineData: [TimelineDataPoint] {
        let sessions = weekSessions
        guard !sessions.isEmpty else { return [] }
        
        let calendar = Calendar.current
        var dailyData: [Int: TimeInterval] = [:]
        
        // Groupe les sessions par jour de la semaine (1 = Lundi, 7 = Dimanche)
        for session in sessions {
            var weekday = calendar.component(.weekday, from: session.date)
            // Convertir de la convention US (1=Dimanche) vers EU (1=Lundi)
            weekday = weekday == 1 ? 7 : weekday - 1
            dailyData[weekday, default: 0] += session.duration
        }
        
        // Crée les points de données pour tous les jours de la semaine
        let dayNames = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"]
        var dataPoints: [TimelineDataPoint] = []
        
        for day in 1...7 {
            let totalTime = dailyData[day] ?? 0
            dataPoints.append(TimelineDataPoint(
                period: dayNames[day - 1],
                periodValue: day,
                totalTime: totalTime,
                date: nil
            ))
        }
        
        return dataPoints
    }
    
    private var monthTimelineData: [TimelineDataPoint] {
        let sessions = monthSessions
        guard !sessions.isEmpty else { return [] }
        
        let calendar = Calendar.current
        var weeklyData: [Int: TimeInterval] = [:]
        
        // Groupe les sessions par semaine du mois
        for session in sessions {
            let weekOfMonth = calendar.component(.weekOfMonth, from: session.date)
            weeklyData[weekOfMonth, default: 0] += session.duration
        }
        
        // Crée les points de données pour les 4 semaines
        var dataPoints: [TimelineDataPoint] = []
        for week in 1...4 {
            let totalTime = weeklyData[week] ?? 0
            dataPoints.append(TimelineDataPoint(
                period: "S\(week)",
                periodValue: week,
                totalTime: totalTime,
                date: nil
            ))
        }
        
        return dataPoints
    }
}