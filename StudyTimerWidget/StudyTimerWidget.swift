//
//  StudyTimerWidget.swift
//  StudyTimerWidget
//
//  Created by Claude Code
//

import WidgetKit
import SwiftUI
import Charts

// MARK: - Widget Period
enum WidgetPeriod: String, CaseIterable, Hashable {
    case today = "Aujourd'hui"
    case week = "Cette semaine"
    case month = "Ce mois"

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
}

// MARK: - Timeline Entry
struct StudyTimerEntry: TimelineEntry {
    let date: Date
    let period: WidgetPeriod
    let totalTime: TimeInterval
    let chartData: [ChartDataPoint]
}

// MARK: - Timeline Provider
struct StudyTimerProvider: TimelineProvider {
    let period: WidgetPeriod

    func placeholder(in context: Context) -> StudyTimerEntry {
        StudyTimerEntry(
            date: Date(),
            period: period,
            totalTime: 0,
            chartData: []
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (StudyTimerEntry) -> Void) {
        let entry = createEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StudyTimerEntry>) -> Void) {
        let entry = createEntry()

        // Rafraîchir le widget toutes les 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }

    private func createEntry() -> StudyTimerEntry {
        let repository = WidgetStudyRepository.shared
        let sessions = repository.getAllSessions()
        let calendar = Calendar.current

        // Filtrer les sessions selon la période
        let filteredSessions: [WidgetStudySession]
        switch period {
        case .today:
            filteredSessions = sessions.filter { calendar.isDate($0.date, inSameDayAs: Date()) }
        case .week:
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
            filteredSessions = sessions.filter { $0.date >= weekStart }
        case .month:
            let monthStart = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
            filteredSessions = sessions.filter { $0.date >= monthStart }
        }

        let totalTime = filteredSessions.reduce(0) { $0 + $1.duration }

        // Créer les données du chart
        let categories = Dictionary(grouping: filteredSessions, by: { $0.categoryName })
            .mapValues { $0.reduce(0) { $0 + $1.duration } }

        let chartData = categories.map { name, time in
            ChartDataPoint(categoryName: name, value: time)
        }.sorted { $0.value > $1.value }

        return StudyTimerEntry(
            date: Date(),
            period: period,
            totalTime: totalTime,
            chartData: chartData
        )
    }
}


// MARK: - Small Widget View
struct SmallWidgetView: View {
    var entry: StudyTimerEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header compact
            HStack(spacing: 6) {
                Image(systemName: entry.period.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                Text(entry.period.rawValue)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 8)

            Spacer()

            // Time principal
            Text(TimeFormatter.formatCompact(entry.totalTime))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            // Subtitle
            Text(entry.period.subtitle)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 2)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(14)
        .background(widgetBackground)
    }
}

// MARK: - Medium Overview Widget View
struct OverviewMediumView: View {
    var entry: AllPeriodsEntry

    var body: some View {
        HStack(spacing: 0) {
            ForEach([WidgetPeriod.today, .week, .month], id: \.self) { period in
                if period != .today {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 1)
                        .padding(.vertical, 12)
                }

                PeriodCompactView(
                    period: period,
                    time: entry.periods[period]?.time ?? 0
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(14)
        .background(widgetBackground)
    }
}

// MARK: - Period Compact View (for Medium widget)
struct PeriodCompactView: View {
    let period: WidgetPeriod
    let time: TimeInterval

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: period.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))

            Text(TimeFormatter.formatCompact(time))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(shortTitle(for: period))
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(1)
        }
    }

    private func shortTitle(for period: WidgetPeriod) -> String {
        switch period {
        case .today: return "Aujourd'hui"
        case .week: return "Semaine"
        case .month: return "Mois"
        }
    }
}

// MARK: - Large Detailed Widget View
struct DetailedLargeView: View {
    var entry: AllPeriodsEntry

    var body: some View {
        VStack(spacing: 0) {
            // Title
            HStack {
                Text("Statistiques")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.bottom, 16)

            // Les 3 périodes
            VStack(spacing: 12) {
                ForEach([WidgetPeriod.today, .week, .month], id: \.self) { period in
                    PeriodDetailRow(
                        period: period,
                        time: entry.periods[period]?.time ?? 0,
                        chartData: entry.periods[period]?.chartData ?? []
                    )

                    if period != .month {
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 1)
                            .padding(.horizontal, 4)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(widgetBackground)
    }
}

// MARK: - Period Detail Row (for Large widget)
struct PeriodDetailRow: View {
    let period: WidgetPeriod
    let time: TimeInterval
    let chartData: [ChartDataPoint]

    var body: some View {
        HStack(spacing: 12) {
            // Icon + Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: period.icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)

                    Text(period.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                }

                Text(TimeFormatter.formatCompact(time))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(width: 120, alignment: .leading)

            Spacer()

            // Mini categories
            if !chartData.isEmpty {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(Array(chartData.prefix(2))) { dataPoint in
                        HStack(spacing: 5) {
                            Circle()
                                .fill(WidgetCategoryColors.color(for: dataPoint.categoryName))
                                .frame(width: 5, height: 5)

                            Text(dataPoint.categoryName)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)

                            Text(TimeFormatter.formatCompact(dataPoint.value))
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Background
private var widgetBackground: some View {
    LinearGradient(
        stops: [
            .init(color: Color.black, location: 0.0),
            .init(color: Color(hex: "0a1f0a"), location: 1.0)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - All Periods Provider
struct AllPeriodsProvider: TimelineProvider {
    func placeholder(in context: Context) -> AllPeriodsEntry {
        AllPeriodsEntry(date: Date(), periods: [:])
    }

    func getSnapshot(in context: Context, completion: @escaping (AllPeriodsEntry) -> Void) {
        let entry = createEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AllPeriodsEntry>) -> Void) {
        let entry = createEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func createEntry() -> AllPeriodsEntry {
        let repository = WidgetStudyRepository.shared
        let sessions = repository.getAllSessions()
        let calendar = Calendar.current

        var periods: [WidgetPeriod: (time: TimeInterval, chartData: [ChartDataPoint])] = [:]

        for period in WidgetPeriod.allCases {
            let filteredSessions: [WidgetStudySession]
            switch period {
            case .today:
                filteredSessions = sessions.filter { calendar.isDate($0.date, inSameDayAs: Date()) }
            case .week:
                let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
                filteredSessions = sessions.filter { $0.date >= weekStart }
            case .month:
                let monthStart = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
                filteredSessions = sessions.filter { $0.date >= monthStart }
            }

            let totalTime = filteredSessions.reduce(0) { $0 + $1.duration }
            let categories = Dictionary(grouping: filteredSessions, by: { $0.categoryName })
                .mapValues { $0.reduce(0) { $0 + $1.duration } }
            let chartData = categories.map { ChartDataPoint(categoryName: $0.key, value: $0.value) }
                .sorted { $0.value > $1.value }

            periods[period] = (time: totalTime, chartData: chartData)
        }

        return AllPeriodsEntry(date: Date(), periods: periods)
    }
}

struct AllPeriodsEntry: TimelineEntry {
    let date: Date
    let periods: [WidgetPeriod: (time: TimeInterval, chartData: [ChartDataPoint])]
}

// MARK: - Widget Bundle
@main
struct StudyTimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodaySmallWidget()
        WeekSmallWidget()
        MonthSmallWidget()
        OverviewMediumWidget()
        DetailedLargeWidget()
    }
}

// MARK: - Small Widgets (3)
struct TodaySmallWidget: Widget {
    let kind: String = "TodaySmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StudyTimerProvider(period: .today)) { entry in
            SmallWidgetView(entry: entry)
                .containerBackground(for: .widget) { widgetBackground }
        }
        .configurationDisplayName("Aujourd'hui")
        .description("Temps d'étude d'aujourd'hui")
        .supportedFamilies([.systemSmall])
    }
}

struct WeekSmallWidget: Widget {
    let kind: String = "WeekSmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StudyTimerProvider(period: .week)) { entry in
            SmallWidgetView(entry: entry)
                .containerBackground(for: .widget) { widgetBackground }
        }
        .configurationDisplayName("Cette semaine")
        .description("Temps d'étude de la semaine")
        .supportedFamilies([.systemSmall])
    }
}

struct MonthSmallWidget: Widget {
    let kind: String = "MonthSmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StudyTimerProvider(period: .month)) { entry in
            SmallWidgetView(entry: entry)
                .containerBackground(for: .widget) { widgetBackground }
        }
        .configurationDisplayName("Ce mois")
        .description("Temps d'étude du mois")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Medium Widget (Vue d'ensemble)
struct OverviewMediumWidget: Widget {
    let kind: String = "OverviewMediumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AllPeriodsProvider()) { entry in
            OverviewMediumView(entry: entry)
                .containerBackground(for: .widget) { widgetBackground }
        }
        .configurationDisplayName("Vue d'ensemble")
        .description("Aujourd'hui, semaine et mois en un coup d'œil")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Large Widget (Statistiques complètes)
struct DetailedLargeWidget: Widget {
    let kind: String = "DetailedLargeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AllPeriodsProvider()) { entry in
            DetailedLargeView(entry: entry)
                .containerBackground(for: .widget) { widgetBackground }
        }
        .configurationDisplayName("Statistiques complètes")
        .description("Toutes vos statistiques détaillées")
        .supportedFamilies([.systemLarge])
    }
}

// MARK: - Previews
#Preview("Today Small", as: .systemSmall) {
    TodaySmallWidget()
} timeline: {
    StudyTimerEntry(
        date: Date(),
        period: .today,
        totalTime: 7200,
        chartData: [
            ChartDataPoint(categoryName: "Maths", value: 3600),
            ChartDataPoint(categoryName: "Informatique", value: 2400)
        ]
    )
}

#Preview("Overview Medium", as: .systemMedium) {
    OverviewMediumWidget()
} timeline: {
    AllPeriodsEntry(
        date: Date(),
        periods: [
            .today: (time: 7200, chartData: []),
            .week: (time: 14400, chartData: []),
            .month: (time: 28800, chartData: [])
        ]
    )
}

#Preview("Detailed Large", as: .systemLarge) {
    DetailedLargeWidget()
} timeline: {
    AllPeriodsEntry(
        date: Date(),
        periods: [
            .today: (time: 7200, chartData: [
                ChartDataPoint(categoryName: "Maths", value: 3600),
                ChartDataPoint(categoryName: "Info", value: 3600)
            ]),
            .week: (time: 14400, chartData: [
                ChartDataPoint(categoryName: "Maths", value: 7200),
                ChartDataPoint(categoryName: "Info", value: 7200)
            ]),
            .month: (time: 28800, chartData: [
                ChartDataPoint(categoryName: "Maths", value: 14400),
                ChartDataPoint(categoryName: "Info", value: 14400)
            ])
        ]
    )
}
