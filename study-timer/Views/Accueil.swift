//
//  Accueil.swift
//  study-timer
//
//  Created by Simon M on 27/09/2025.
//

import SwiftUI
import Charts


struct Accueil: View {
    @State private var categories: [Categories] = [
        .init(name: "Maths", timeSpent: 0.33),
        .init(name: "Info", timeSpent: 0.33),
        .init(name: "Stats", timeSpent:  0.33)
    ]
    var body: some View {
        NavigationStack {
            ScrollView {
                    VStack {
                        HStack {
                            Image(systemName: "1.calendar")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding(.leading)
                            Text("Aujourd'hui :")
                                .font(.title)
                                .bold()
                            Spacer()
                        }
                        .padding(.top, 25)
                        HStack {
                            Text("2h30")
                                .font(.title2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(25)
                            Chart(categories) { category in
                                SectorMark(
                                    angle: .value(
                                        Text(verbatim: category.name),
                                        category.timeSpent
                                    ),
                                )
                                .foregroundStyle(
                                    by: .value(
                                        Text(verbatim: category.name),
                                        category.name
                                    )
                                )
                            }
                            .frame(width: 200, height: 200)
                            .chartLegend(alignment: .center)
                            .padding(25)
                        }
                        HStack {
                            Image(systemName: "7.calendar")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding(.leading)
                            Text("Dans la semainee :")
                                .font(.title)
                                .bold()
                            Spacer()
                        }
                        .padding(.top, 25)
                        HStack {
                            Text("9h50")
                                .font(.title2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(25)
                            Chart(categories) { category in
                                SectorMark(
                                    angle: .value(
                                        Text(verbatim: category.name),
                                        category.timeSpent
                                    ),
                                )
                                .foregroundStyle(
                                    by: .value(
                                        Text(verbatim: category.name),
                                        category.name
                                    )
                                )
                            }
                            .frame(width: 200, height: 200)
                            .chartLegend(alignment: .center)
                            .padding(25)
                        }
                        HStack {
                            Image(systemName: "calendar")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding(.leading)
                            Text("Ce mois-ci :")
                                .font(.title)
                                .bold()
                            Spacer()
                        }
                        .padding(.top, 25)
                        HStack {
                            Text("28h30")
                                .font(.title2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(25)
                            Chart(categories) { category in
                                SectorMark(
                                    angle: .value(
                                        Text(verbatim: category.name),
                                        category.timeSpent
                                    ),
                                )
                                .foregroundStyle(
                                    by: .value(
                                        Text(verbatim: category.name),
                                        category.name
                                    )
                                )
                            }
                            .frame(width: 200, height: 200)
                            .chartLegend(alignment: .center)
                            .padding(25)
                        }
                        Spacer()
                    }
                    .navigationTitle("Résumé")
                }
            }
    }
}

#Preview {
    Accueil()
}
