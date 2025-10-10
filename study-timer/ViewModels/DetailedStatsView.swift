//
//  DetailedStatsView.swift
//  study-timer
//
//  Created by Claude on 08/10/2025.
//

import SwiftUI
import Charts

struct DetailedStatsView: View {
    let period: StatsPeriod
    @StateObject private var viewModel = StatisticsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Boutons de navigation en haut
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

                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(AppTheme.primaryGreen)
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.horizontal, 20)

                    // Header avec résumé
                    VStack(spacing: 16) {
                        // Icône et titre
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(period.accentColor.opacity(0.15))
                                    .frame(width: 56, height: 56)

                                Image(systemName: period.icon)
                                    .font(.system(size: 26))
                                    .foregroundColor(period.accentColor)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(period.rawValue)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.textPrimary)

                                Text(period.subtitle)
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

                            Text(TimeFormatter.format(TimeInterval(totalTime)))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(period.accentColor)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Statistiques supplémentaires
                        HStack(spacing: 16) {
                            if period == .today {
                                // Afficher uniquement le temps d'hier pour la vue quotidienne
                                StatBadge(
                                    icon: "arrow.left.circle.fill",
                                    label: "Hier",
                                    value: TimeFormatter.format(viewModel.yesterdayTime),
                                    color: period.accentColor
                                )
                            } else if period == .week {
                                // Afficher la moyenne quotidienne de la semaine en cours
                                StatBadge(
                                    icon: "chart.line.uptrend.xyaxis",
                                    label: "Moyenne/jour",
                                    value: TimeFormatter.format(viewModel.weekDailyAverage),
                                    color: period.accentColor
                                )
                            } else if period == .month {
                                // Afficher les deux moyennes pour le mois
                                StatBadge(
                                    icon: "chart.bar.fill",
                                    label: "Moy/jour",
                                    value: TimeFormatter.format(viewModel.monthDailyAverage),
                                    color: period.accentColor
                                )

                                StatBadge(
                                    icon: "calendar.badge.clock",
                                    label: "Moy/semaine",
                                    value: TimeFormatter.format(viewModel.monthWeeklyAverage),
                                    color: period.accentColor
                                )
                            }
                        }
                    }
                    .padding(24)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 20)

                    // Timeline Chart
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "chart.xyaxis.line")
                                .foregroundColor(period.accentColor)
                            Text("Évolution temporelle")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        if timelineData.isEmpty {
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
                                    y: .value("Temps", dataPoint.totalTime / 60) // En minutes
                                )
                                .foregroundStyle(period.accentColor)
                                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                                PointMark(
                                    x: .value("Période", dataPoint.period),
                                    y: .value("Temps", dataPoint.totalTime / 60)
                                )
                                .foregroundStyle(period.accentColor)
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
                            .chartPlotStyle { plotArea in
                                plotArea.background(AppTheme.background.opacity(0.3))
                            }
                        }
                    }
                    .padding(24)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 20)

                    // Sessions list
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .foregroundColor(period.accentColor)
                            Text("Sessions")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Text("\(sessions.count) session\(sessions.count > 1 ? "s" : "")")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }

                        if sessions.isEmpty {
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
                                ForEach(sessions) { session in
                                    SessionRowView(session: session, accentColor: period.accentColor)
                                }
                            }
                        }
                    }
                    .padding(24)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 20)

                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
            .background(AppTheme.background)
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    private var totalTime: Int {
        switch period {
        case .today: return Int(viewModel.todayTime)
        case .week: return Int(viewModel.weekTime)
        case .month: return Int(viewModel.monthTime)
        }
    }

    private var sessions: [StudySession] {
        viewModel.sessions(for: period)
    }

    private var timelineData: [TimelineDataPoint] {
        viewModel.timelineData(for: period)
    }
}

struct SessionRowView: View {
    let session: StudySession
    let accentColor: Color

    var body: some View {
        HStack(spacing: 16) {
            // Indicateur de catégorie
            Circle()
                .fill(CategoryColors.color(for: session.categoryName))
                .frame(width: 12, height: 12)

            // Informations de la session
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.categoryName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.textPrimary)

                    Spacer()

                    Text(session.formattedDuration)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(accentColor)
                }

                Text(formatDate(session.date))
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.background)
        .cornerRadius(12)
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

struct StatBadge: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary)

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppTheme.background)
        .cornerRadius(10)
    }
}

#Preview {
    DetailedStatsView(period: .today)
}
