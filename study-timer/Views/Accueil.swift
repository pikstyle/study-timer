//
//  Accueil.swift
//  study-timer
//
//  Created by Simon M on 27/09/2025.
//

import SwiftUI
import Charts

struct Accueil: View {
    @StateObject private var viewModel = StatisticsViewModel()
    @State private var selectedPeriod: StatsPeriod?
    @State private var showingDetailedStats = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Today's stats
                        Button {
                            selectedPeriod = .today
                            showingDetailedStats = true
                        } label: {
                            StatCard(
                                icon: "sun.max.fill",
                                title: "Aujourd'hui",
                                subtitle: "Temps d'étude",
                                totalTime: Int(viewModel.todayTime),
                                chartData: viewModel.todayChartData,
                                accentColor: AppTheme.primaryGreen
                            )
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Week stats
                        Button {
                            selectedPeriod = .week
                            showingDetailedStats = true
                        } label: {
                            StatCard(
                                icon: "calendar.badge.clock",
                                title: "Cette semaine",
                                subtitle: "7 derniers jours",
                                totalTime: Int(viewModel.weekTime),
                                chartData: viewModel.weekChartData,
                                accentColor: Color(hex: "0A84FF")
                            )
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Month stats
                        Button {
                            selectedPeriod = .month
                            showingDetailedStats = true
                        } label: {
                            StatCard(
                                icon: "chart.bar.fill",
                                title: "Ce mois",
                                subtitle: "30 derniers jours",
                                totalTime: Int(viewModel.monthTime),
                                chartData: viewModel.monthChartData,
                                accentColor: Color(hex: "FF9F0A")
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Statistiques")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.clearAllData()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(AppTheme.primaryGreen)
                    }
                }
            }
            .refreshable {
                viewModel.refresh()
            }
            .sheet(isPresented: $showingDetailedStats) {
                if let period = selectedPeriod {
                    DetailedStatsView(period: period)
                }
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let totalTime: Int
    let chartData: [ChartDataPoint]
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(accentColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()
            }

            // Total time
            VStack(alignment: .leading, spacing: 8) {
                Text("TEMPS TOTAL")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textSecondary)
                    .tracking(1.2)

                Text(TimeFormatter.format(TimeInterval(totalTime)))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(accentColor)
            }

            // Chart
            if !chartData.isEmpty {
                VStack(spacing: 12) {
                    Chart(chartData) { dataPoint in
                        SectorMark(
                            angle: .value(
                                Text(verbatim: dataPoint.categoryName),
                                dataPoint.value
                            ),
                            innerRadius: .ratio(0.5)
                        )
                        .foregroundStyle(
                            by: .value(
                                Text(verbatim: dataPoint.categoryName),
                                dataPoint.categoryName
                            )
                        )
                    }
                    .frame(height: 220)
                    .chartLegend(position: .bottom, alignment: .center)

                    // Category breakdown
                    VStack(spacing: 8) {
                        ForEach(chartData) { dataPoint in
                            HStack {
                                Circle()
                                    .fill(categoryColor(for: dataPoint.categoryName))
                                    .frame(width: 8, height: 8)

                                Text(dataPoint.categoryName)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textPrimary)

                                Spacer()

                                Text(TimeFormatter.format(dataPoint.value))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.top, 8)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 48))
                        .foregroundColor(AppTheme.textSecondary.opacity(0.3))

                    Text("Aucune session enregistrée")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
            }
        }
        .padding(24)
        .background(AppTheme.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }

    private func categoryColor(for name: String) -> Color {
        // Utiliser une fonction centralisée pour la cohérence des couleurs
        return CategoryColors.color(for: name)
    }
}

#Preview {
    Accueil()
}
