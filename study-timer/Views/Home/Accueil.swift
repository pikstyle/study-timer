//
//  Accueil.swift
//  study-timer
//
//  Created by Simon M on 27/09/2025.
//

import SwiftUI
import Charts

enum StatsViewMode: String, CaseIterable {
    case byDate = "Par dates"
    case byCategory = "Par catégories"
}

struct CategorySelection: Identifiable {
    let id = UUID()
    let categoryName: String
}

struct Accueil: View {
    @StateObject private var viewModel = StatisticsViewModel()
    @State private var selectedPeriod: StatsPeriod?
    @State private var selectedCategory: CategorySelection?
    @State private var viewMode: StatsViewMode = .byDate

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Titre personnalisé
                    HStack {
                        Text("Accueil")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                    }
                    .padding(.top, 20)

                    // Segmented Control pour changer de vue
                    Picker("Mode de vue", selection: $viewMode) {
                        ForEach(StatsViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 4)

                    // Contenu selon le mode sélectionné
                    if viewMode == .byDate {
                        dateStatsView
                    } else {
                        categoryStatsView
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(
                AppTheme.backgroundView()
            )
            .grainEffect()
            .navigationBarHidden(true)
            .refreshable {
                viewModel.refresh()
            }
            .sheet(item: $selectedPeriod) { period in
                DetailedStatsView(period: period)
            }
            .sheet(item: $selectedCategory) { selection in
                CategoryDetailedStatsView(categoryName: selection.categoryName)
            }
        }
    }

    // MARK: - Date Stats View
    @ViewBuilder
    private var dateStatsView: some View {
        VStack(spacing: 24) {
            // Today's stats
            Button {
                selectedPeriod = .today
            } label: {
                StatCard(
                    icon: "sun.max.fill",
                    title: "Aujourd'hui",
                    subtitle: "Temps d'étude",
                    totalTime: Int(viewModel.todayTime),
                    chartData: viewModel.todayChartData,
                    accentColor: AppTheme.todayAccent
                )
            }
            .buttonStyle(PlainButtonStyle())

            // Week stats
            Button {
                selectedPeriod = .week
            } label: {
                StatCard(
                    icon: "calendar.badge.clock",
                    title: "Cette semaine",
                    subtitle: "7 derniers jours",
                    totalTime: Int(viewModel.weekTime),
                    chartData: viewModel.weekChartData,
                    accentColor: AppTheme.weekAccent
                )
            }
            .buttonStyle(PlainButtonStyle())

            // Month stats
            Button {
                selectedPeriod = .month
            } label: {
                StatCard(
                    icon: "chart.bar.fill",
                    title: "Ce mois",
                    subtitle: "30 derniers jours",
                    totalTime: Int(viewModel.monthTime),
                    chartData: viewModel.monthChartData,
                    accentColor: AppTheme.monthAccent
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Category Stats View
    @ViewBuilder
    private var categoryStatsView: some View {
        VStack(spacing: 24) {
            ForEach(viewModel.categoriesWithStats, id: \.category.id) { categoryStats in
                Button {
                    selectedCategory = CategorySelection(categoryName: categoryStats.category.name)
                } label: {
                    CategoryStatCard(
                        category: categoryStats.category,
                        totalTime: Int(categoryStats.totalTime),
                        todayTime: categoryStats.todayTime,
                        weekTime: categoryStats.weekTime,
                        monthTime: categoryStats.monthTime
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }

            if viewModel.categoriesWithStats.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 48))
                        .foregroundColor(AppTheme.textSecondary.opacity(0.3))

                    Text("Aucune catégorie")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)

                    Text("Créez une session pour voir vos statistiques par catégorie")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
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
    var additionalStats: [(icon: String, label: String, value: String)]? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.textPrimary)
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
                    .foregroundColor(AppTheme.textPrimary)
            }

            // Additional stats badges
            if let stats = additionalStats, !stats.isEmpty {
                HStack(spacing: 12) {
                    ForEach(stats.indices, id: \.self) { index in
                        let stat = stats[index]
                        HStack(spacing: 6) {
                            Image(systemName: stat.icon)
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(stat.label)
                                    .font(.caption2)
                                    .foregroundColor(AppTheme.textSecondary)

                                Text(stat.value)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(8)
                    }
                }
            }

            // Chart
            chartContent
        }
        .glassCard()
    }

    @ViewBuilder
    private var chartContent: some View {
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
                    .foregroundStyle(CategoryColors.color(for: dataPoint.categoryName))
                }
                .frame(height: 220)

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
                                .foregroundColor(AppTheme.textPrimary)
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

    private func categoryColor(for name: String) -> Color {
        // Utiliser une fonction centralisée pour la cohérence des couleurs
        return CategoryColors.color(for: name)
    }
}

// MARK: - Category Stat Card
struct CategoryStatCard: View {
    let category: Category
    let totalTime: Int
    let todayTime: TimeInterval
    let weekTime: TimeInterval
    let monthTime: TimeInterval

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header avec l'icône et le nom de la catégorie
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(CategoryColors.color(for: category.name).opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: "folder.fill")
                        .font(.system(size: 22))
                        .foregroundColor(CategoryColors.color(for: category.name))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
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
                    .foregroundColor(AppTheme.textPrimary)
            }

            // Stats badges pour aujourd'hui, semaine, mois
            HStack(spacing: 12) {
                CategoryStatBadge(
                    icon: "sun.max.fill",
                    label: "Aujourd'hui",
                    value: TimeFormatter.format(todayTime),
                    color: AppTheme.todayAccent
                )

                CategoryStatBadge(
                    icon: "calendar",
                    label: "Semaine",
                    value: TimeFormatter.format(weekTime),
                    color: AppTheme.weekAccent
                )

                CategoryStatBadge(
                    icon: "chart.bar.fill",
                    label: "Mois",
                    value: TimeFormatter.format(monthTime),
                    color: AppTheme.monthAccent
                )
            }
        }
        .glassCard()
    }
}

// MARK: - Category Stat Badge
struct CategoryStatBadge: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(color)

                Text(label)
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary)
            }

            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(AppTheme.cardBackground)
        .cornerRadius(8)
    }
}

#Preview {
    Accueil()
}
