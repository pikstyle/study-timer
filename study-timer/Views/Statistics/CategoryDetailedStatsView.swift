//
//  CategoryDetailedStatsView.swift
//  study-timer
//
//  Created by Claude on 11/10/2025.
//

import SwiftUI
import Charts

struct CategoryDetailedStatsView: View {
    let categoryName: String
    @StateObject private var viewModel = StatisticsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Bouton de navigation en haut
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Retour")
                            }
                            .foregroundColor(AppTheme.primaryGreen)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    // Header avec titre
                    VStack(spacing: 16) {
                        // Icône et titre
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(categoryColor.opacity(0.15))
                                    .frame(width: 56, height: 56)

                                Image(systemName: "folder.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(categoryColor)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(categoryName)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.textPrimary)

                                Text("\(categorySessions.count) session\(categorySessions.count > 1 ? "s" : "") enregistrée\(categorySessions.count > 1 ? "s" : "")")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                            }

                            Spacer()
                        }

                        // Temps total
                        VStack(alignment: .leading, spacing: 8) {
                            Text("TEMPS TOTAL")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.textSecondary)
                                .tracking(1.2)

                            Text(TimeFormatter.format(totalTime))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .glassCard()
                    .padding(.horizontal, 20)

                    // Overview section
                    VStack(alignment: .leading, spacing: 16) {
                        // Ranking text
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(categoryColor.opacity(0.15))
                                    .frame(width: 40, height: 40)

                                Text("\(categoryRank)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(categoryColor)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(categoryRankingText)
                                    .font(.subheadline)
                                    .foregroundColor(Color.white.opacity(0.85))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.vertical, 8)

                        Divider()
                            .background(Color.white.opacity(0.1))

                        // Statistiques clés
                        VStack(spacing: 16) {
                            OverviewStatRow(
                                icon: "clock.arrow.2.circlepath",
                                label: "Moyenne par session",
                                value: TimeFormatter.format(averageSessionTime),
                                color: categoryColor
                            )

                            OverviewStatRow(
                                icon: "calendar.day.timeline.left",
                                label: "Moyenne par jour",
                                value: TimeFormatter.format(averageDailyTime),
                                color: categoryColor
                            )

                            OverviewStatRow(
                                icon: "sun.max.fill",
                                label: "Aujourd'hui",
                                value: TimeFormatter.format(todayTime),
                                color: AppTheme.todayAccent
                            )

                            OverviewStatRow(
                                icon: "calendar.badge.clock",
                                label: "Cette semaine",
                                value: TimeFormatter.format(weekTime),
                                color: AppTheme.weekAccent
                            )

                            OverviewStatRow(
                                icon: "chart.bar.fill",
                                label: "Ce mois",
                                value: TimeFormatter.format(monthTime),
                                color: AppTheme.monthAccent
                            )
                        }
                    }
                    .glassCard()
                    .padding(.horizontal, 20)

                    // Timeline Chart - évolution temporelle du mois
                    timelineChartView
                        .glassCard()
                        .padding(.horizontal, 20)

                    // Sessions list
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Sessions")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Text("\(categorySessions.count) session\(categorySessions.count > 1 ? "s" : "")")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }

                        if categorySessions.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 48))
                                    .foregroundColor(AppTheme.textSecondary.opacity(0.3))

                                Text("Aucune session enregistrée")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(categorySessions) { session in
                                    CategorySessionRowView(session: session, categoryColor: categoryColor)
                                }
                            }
                        }
                    }
                    .glassCard()
                    .padding(.horizontal, 20)

                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
            .background(
                AppTheme.backgroundView()
            )
            .grainEffect()
        }
    }

    private var categoryColor: Color {
        CategoryColors.color(for: categoryName)
    }

    private var totalTime: TimeInterval {
        viewModel.categoryTimes[categoryName] ?? 0
    }

    private var todayTime: TimeInterval {
        viewModel.todaySessions
            .filter { $0.categoryName == categoryName }
            .reduce(0) { $0 + $1.duration }
    }

    private var weekTime: TimeInterval {
        viewModel.weekSessions
            .filter { $0.categoryName == categoryName }
            .reduce(0) { $0 + $1.duration }
    }

    private var monthTime: TimeInterval {
        viewModel.monthSessions
            .filter { $0.categoryName == categoryName }
            .reduce(0) { $0 + $1.duration }
    }

    private var categorySessions: [StudySession] {
        StudyRepository.shared.getAllSessions()
            .filter { $0.categoryName == categoryName }
            .sorted { $0.date > $1.date }
    }

    private var averageSessionTime: TimeInterval {
        guard !categorySessions.isEmpty else { return 0 }
        let total = categorySessions.reduce(0) { $0 + $1.duration }
        return total / TimeInterval(categorySessions.count)
    }

    private var averageDailyTime: TimeInterval {
        guard !categorySessions.isEmpty else { return 0 }

        let calendar = Calendar.current
        let sessionsByDay = Dictionary(grouping: categorySessions) { session -> Date in
            calendar.startOfDay(for: session.date)
        }

        let daysWithSessions = sessionsByDay.count
        guard daysWithSessions > 0 else { return 0 }

        let total = categorySessions.reduce(0) { $0 + $1.duration }
        return total / TimeInterval(daysWithSessions)
    }

    private var categoryRank: Int {
        let allCategories = viewModel.categoriesWithStats
        if let rank = allCategories.firstIndex(where: { $0.category.name == categoryName }) {
            return rank + 1
        }
        return 0
    }

    private var categoryRankingText: String {
        let rank = categoryRank
        let totalCategories = viewModel.categoriesWithStats.count

        guard rank > 0 else {
            return "Statistiques de la catégorie"
        }

        if rank == 1 {
            return "Catégorie dans laquelle vous passez le plus de temps"
        } else if rank == 2 {
            return "2ème catégorie sur \(totalCategories)"
        } else if rank == 3 {
            return "3ème catégorie sur \(totalCategories)"
        } else {
            return "\(rank)ème catégorie sur \(totalCategories)"
        }
    }

    private var timelineData: [TimelineDataPoint] {
        // Prendre toutes les sessions de cette catégorie (pas seulement le mois)
        let sessions = categorySessions
        guard !sessions.isEmpty else { return [] }

        _ = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"

        // Créer un point de données pour chaque session
        var dataPoints: [TimelineDataPoint] = []
        for (index, session) in sessions.enumerated().reversed() {
            // Limiter à 30 dernières sessions pour ne pas surcharger le graphique
            if dataPoints.count >= 30 { break }

            dataPoints.append(TimelineDataPoint(
                period: dateFormatter.string(from: session.date),
                periodValue: index,
                totalTime: session.duration,
                date: session.date
            ))
        }

        return dataPoints.reversed()
    }

    @ViewBuilder
    private var timelineChartView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.xyaxis.line")
                    .foregroundColor(AppTheme.textPrimary)
                Text("Évolution temporelle")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
            }

            if timelineData.isEmpty || timelineData.allSatisfy({ $0.totalTime == 0 }) {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 48))
                        .foregroundColor(AppTheme.textSecondary.opacity(0.3))

                    Text("Pas assez de données")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            } else {
                Chart(timelineData) { dataPoint in
                    LineMark(
                        x: .value("Période", dataPoint.period),
                        y: .value("Temps", dataPoint.totalTime / 60)
                    )
                    .foregroundStyle(categoryColor)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                    PointMark(
                        x: .value("Période", dataPoint.period),
                        y: .value("Temps", dataPoint.totalTime / 60)
                    )
                    .foregroundStyle(categoryColor)
                    .symbolSize(50)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let minutes = value.as(Double.self) {
                                Text(ChartFormatter.formatMinutes(minutes))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Category Session Row View
struct CategorySessionRowView: View {
    let session: StudySession
    let categoryColor: Color

    var body: some View {
        HStack(spacing: 16) {
            // Indicateur de catégorie
            Circle()
                .fill(categoryColor)
                .frame(width: 12, height: 12)

            // Informations de la session
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.formattedDuration)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.textPrimary)

                    Spacer()
                }

                Text(formatDate(session.date))
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.4))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDate(date, inSameDayAs: Date()) {
            formatter.dateFormat = "HH:mm"
            return "Aujourd'hui à \(formatter.string(from: date))"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            formatter.dateFormat = "EEEE à HH:mm"
            return formatter.string(from: date).capitalized
        } else {
            formatter.dateFormat = "dd/MM à HH:mm"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Overview Stat Row
struct OverviewStatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            // Icône
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color.white.opacity(0.9))
            }

            // Label
            Text(label)
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.75))

            Spacer()

            // Value
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.white.opacity(0.95))
        }
    }
}

#Preview {
    CategoryDetailedStatsView(categoryName: "Maths")
}
