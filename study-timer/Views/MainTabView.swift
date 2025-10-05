//
//  TabView.swift
//  study-timer
//
//  Created by Simon M on 27/09/2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Accueil()
                .tabItem {
                    Label("", systemImage: "chart.pie.fill")
                }
            
            TimerView()
                .tabItem {
                    Label("", systemImage: "plus.circle.fill")
                }
            
            Text("Paramètres")
                .tabItem {
                    Label("", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}
