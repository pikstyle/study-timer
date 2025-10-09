//
//  TabView.swift
//  study-timer
//
//  Created by Simon M on 27/09/2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            TabView {
                Accueil()
                    .tabItem {
                        Label("Statistiques", systemImage: "chart.pie.fill")
                    }

                TimerView()
                    .tabItem {
                        Label("Timer", systemImage: "timer")
                    }

                SettingsView()
                    .tabItem {
                        Label("Réglages", systemImage: "gearshape.fill")
                    }
            }
            .accentColor(AppTheme.primaryGreen)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
}
