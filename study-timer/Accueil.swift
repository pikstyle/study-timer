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
            VStack {
                Text("Aujourd'hui :")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    .padding(.leading)
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
                Spacer()
            }
            .navigationTitle("Résumé")
        }
    }
}

#Preview {
    Accueil()
}
