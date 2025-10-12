//
//  study_timerApp.swift
//  study-timer
//
//  Created by Simon M on 27/09/2025.
//

import SwiftUI

@main
struct study_timerApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                    // S'assurer que le service de timer en arrière-plan sauvegarde les données
                    BackgroundTimerService.shared.handleAppWillTerminate()
                }
        }
    }
}
