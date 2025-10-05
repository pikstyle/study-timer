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
    var body: some View {
        NavigationStack {
            ScrollView {
                    VStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "1.calendar")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.blue)
                                Text("Aujourd'hui")
                                    .font(.title)
                                    .bold()
                                Spacer()
                            }
                            Text("Temps d'étude d'aujourd'hui")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.leading, 38)
                        }
                        .padding(.top, 25)
                        .padding(.horizontal)
                        VStack(spacing: 20) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Total")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(TimeFormatter.format(viewModel.todayTime))
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                            }
                            .padding(.horizontal)

                            if !viewModel.todayChartData.isEmpty {
                                Chart(viewModel.todayChartData) { dataPoint in
                                    SectorMark(
                                        angle: .value(
                                            Text(verbatim: dataPoint.categoryName),
                                            dataPoint.value
                                        ),
                                    )
                                    .foregroundStyle(
                                        by: .value(
                                            Text(verbatim: dataPoint.categoryName),
                                            dataPoint.categoryName
                                        )
                                    )
                                }
                                .frame(height: 200)
                                .chartLegend(alignment: .center)
                                .padding(.horizontal)
                            } else {
                                Text("Aucune session aujourd'hui")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                    .frame(height: 100)
                            }
                        }
                        .padding(.vertical, 20)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "7.calendar")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.green)
                                Text("Cette semaine")
                                    .font(.title)
                                    .bold()
                                Spacer()
                            }
                            Text("Temps d'étude de cette semaine")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.leading, 38)
                        }
                        .padding(.top, 30)
                        .padding(.horizontal)
                        VStack(spacing: 20) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Total")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(TimeFormatter.format(viewModel.weekTime))
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                }
                                Spacer()
                            }
                            .padding(.horizontal)

                            if !viewModel.weekChartData.isEmpty {
                                Chart(viewModel.weekChartData) { dataPoint in
                                    SectorMark(
                                        angle: .value(
                                            Text(verbatim: dataPoint.categoryName),
                                            dataPoint.value
                                        ),
                                    )
                                    .foregroundStyle(
                                        by: .value(
                                            Text(verbatim: dataPoint.categoryName),
                                            dataPoint.categoryName
                                        )
                                    )
                                }
                                .frame(height: 200)
                                .chartLegend(alignment: .center)
                                .padding(.horizontal)
                            } else {
                                Text("Aucune session cette semaine")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                    .frame(height: 100)
                            }
                        }
                        .padding(.vertical, 20)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "calendar")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.orange)
                                Text("Ce mois-ci")
                                    .font(.title)
                                    .bold()
                                Spacer()
                            }
                            Text("Temps d'étude de ce mois")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.leading, 38)
                        }
                        .padding(.top, 30)
                        .padding(.horizontal)
                        VStack(spacing: 20) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Total")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(TimeFormatter.format(viewModel.monthTime))
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                }
                                Spacer()
                            }
                            .padding(.horizontal)

                            if !viewModel.monthChartData.isEmpty {
                                Chart(viewModel.monthChartData) { dataPoint in
                                    SectorMark(
                                        angle: .value(
                                            Text(verbatim: dataPoint.categoryName),
                                            dataPoint.value
                                        ),
                                    )
                                    .foregroundStyle(
                                        by: .value(
                                            Text(verbatim: dataPoint.categoryName),
                                            dataPoint.categoryName
                                        )
                                    )
                                }
                                .frame(height: 200)
                                .chartLegend(alignment: .center)
                                .padding(.horizontal)
                            } else {
                                Text("Aucune session ce mois")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                    .frame(height: 100)
                            }
                        }
                        .padding(.vertical, 20)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                        Spacer()
                    }
                    .navigationTitle("Résumé")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Supprimer tout", role: .destructive) {
                                viewModel.clearAllData()
                            }
                        }
                    }
                }
            }
            .refreshable {
                viewModel.refresh()
            }
    }
}

#Preview {
    Accueil()
}
