//
//  StudyTimerWidget.swift
//  StudyTimerWidget
//
//  Created by Claude Code
//

import WidgetKit
import SwiftUI
import Charts

// MARK: - Timeline Entry
struct StudyTimerEntry: TimelineEntry {
    let date: Date
    let todayTime: TimeInterval
    let chartData: [ChartDataPoint]
}

// MARK: - Timeline Provider
struct StudyTimerProvider: TimelineProvider {
    func placeholder(in context: Context) -> StudyTimerEntry {
        StudyTimerEntry(
            date: Date(),
            todayTime: 0,
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
        // Récupérer les données depuis le repository partagé
        let repository = WidgetStudyRepository.shared
        let sessions = repository.getAllSessions()

        // Calculer le temps d'aujourd'hui
        let todaySessions = sessions.filter { session in
            Calendar.current.isDate(session.date, inSameDayAs: Date())
        }

        let todayTime = todaySessions.reduce(0) { $0 + $1.duration }

        // Créer les données du chart
        let todayCategories = Dictionary(grouping: todaySessions, by: { $0.categoryName })
            .mapValues { $0.reduce(0) { $0 + $1.duration } }

        let chartData = todayCategories.map { name, time in
            ChartDataPoint(categoryName: name, value: time)
        }

        return StudyTimerEntry(
            date: Date(),
            todayTime: todayTime,
            chartData: chartData
        )
    }
}

// MARK: - Widget View
struct StudyTimerWidgetView: View {
    var entry: StudyTimerProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    var entry: StudyTimerEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)

                Text("Aujourd'hui")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }

            Spacer()

            Text(TimeFormatter.format(entry.todayTime))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Temps d'étude")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(widgetBackground)
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    var entry: StudyTimerEntry

    var body: some View {
        HStack(spacing: 16) {
            // Left side - Stats
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)

                    Text("Aujourd'hui")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("TEMPS TOTAL")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(1)

                    Text(TimeFormatter.format(entry.todayTime))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right side - Mini Chart
            if !entry.chartData.isEmpty {
                VStack(spacing: 8) {
                    Chart(entry.chartData) { dataPoint in
                        SectorMark(
                            angle: .value(
                                Text(verbatim: dataPoint.categoryName),
                                dataPoint.value
                            ),
                            innerRadius: .ratio(0.5)
                        )
                        .foregroundStyle(categoryColor(for: dataPoint.categoryName))
                    }
                    .frame(width: 100, height: 100)

                    // Category legend (max 2 items)
                    VStack(spacing: 4) {
                        ForEach(Array(entry.chartData.prefix(2))) { dataPoint in
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(categoryColor(for: dataPoint.categoryName))
                                    .frame(width: 6, height: 6)

                                Text(dataPoint.categoryName)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            } else {
                VStack {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 36))
                        .foregroundColor(.white.opacity(0.3))

                    Text("Aucune session")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(widgetBackground)
    }

    private func categoryColor(for name: String) -> Color {
        return WidgetCategoryColors.color(for: name)
    }
}

// MARK: - Large Widget View
struct LargeWidgetView: View {
    var entry: StudyTimerEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 44, height: 44)

                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Aujourd'hui")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Temps d'étude")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()
            }

            // Total time
            VStack(alignment: .leading, spacing: 6) {
                Text("TEMPS TOTAL")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(1.2)

                Text(TimeFormatter.format(entry.todayTime))
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            // Chart
            if !entry.chartData.isEmpty {
                VStack(spacing: 12) {
                    Chart(entry.chartData) { dataPoint in
                        SectorMark(
                            angle: .value(
                                Text(verbatim: dataPoint.categoryName),
                                dataPoint.value
                            ),
                            innerRadius: .ratio(0.5)
                        )
                        .foregroundStyle(categoryColor(for: dataPoint.categoryName))
                    }
                    .frame(height: 140)

                    // Category breakdown
                    VStack(spacing: 6) {
                        ForEach(entry.chartData) { dataPoint in
                            HStack {
                                Circle()
                                    .fill(categoryColor(for: dataPoint.categoryName))
                                    .frame(width: 8, height: 8)

                                Text(dataPoint.categoryName)
                                    .font(.subheadline)
                                    .foregroundColor(.white)

                                Spacer()

                                Text(TimeFormatter.format(dataPoint.value))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "chart.pie")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.3))

                    Text("Aucune session enregistrée")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(widgetBackground)
    }

    private func categoryColor(for name: String) -> Color {
        return WidgetCategoryColors.color(for: name)
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

// MARK: - Widget Configuration
@main
struct StudyTimerWidget: Widget {
    let kind: String = "StudyTimerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StudyTimerProvider()) { entry in
            StudyTimerWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    widgetBackground
                }
        }
        .configurationDisplayName("Temps d'étude")
        .description("Visualisez votre temps d'étude d'aujourd'hui")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Preview
#Preview(as: .systemMedium) {
    StudyTimerWidget()
} timeline: {
    StudyTimerEntry(
        date: Date(),
        todayTime: 7200,
        chartData: [
            ChartDataPoint(categoryName: "Maths", value: 3600),
            ChartDataPoint(categoryName: "Informatique", value: 2400),
            ChartDataPoint(categoryName: "Statistiques", value: 1200)
        ]
    )
}
