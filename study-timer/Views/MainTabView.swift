//
//  TabView.swift
//  study-timer
//
//  Created by Simon M on 27/09/2025.
//

import SwiftUI

struct MainTabView: View {
    init() {
        // Configuration de la TabBar pour transparence sans arrière-plan vert
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.clear

        // Couleurs des items
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.5)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundView()

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
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
}
