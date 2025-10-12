//
//  BackgroundTimerService.swift
//  study-timer
//
//  Created by Claude on 09/10/2025.
//

import Foundation
import UserNotifications
import UIKit
import Combine

class BackgroundTimerService: ObservableObject {
    static let shared = BackgroundTimerService()
    
    private let userDefaults = UserDefaults.standard
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // Keys pour UserDefaults
    private enum Keys {
        static let timerStartDate = "timer_start_date"
        static let timerInitialSeconds = "timer_initial_seconds"
        static let isTimerRunning = "is_timer_running"
        static let lastKnownSeconds = "last_known_seconds"
    }
    
    private init() {
        setupNotificationPermissions()
    }
    
    // MARK: - Public Interface
    
    /// Démarre le timer en arrière-plan
    func startBackgroundTimer(initialSeconds: Int) {
        let startDate = Date()
        userDefaults.set(startDate, forKey: Keys.timerStartDate)
        userDefaults.set(initialSeconds, forKey: Keys.timerInitialSeconds)
        userDefaults.set(true, forKey: Keys.isTimerRunning)
        userDefaults.set(initialSeconds, forKey: Keys.lastKnownSeconds)
        
        scheduleTimerNotifications()
    }
    
    /// Arrête le timer en arrière-plan
    func stopBackgroundTimer() {
        userDefaults.set(false, forKey: Keys.isTimerRunning)
        userDefaults.removeObject(forKey: Keys.timerStartDate)
        userDefaults.removeObject(forKey: Keys.timerInitialSeconds)
        userDefaults.removeObject(forKey: Keys.lastKnownSeconds)
        
        cancelTimerNotifications()
    }
    
    /// Calcule les secondes actuelles du timer en tenant compte du temps écoulé
    func getCurrentTimerSeconds() -> Int {
        guard isTimerRunning,
              let startDate = userDefaults.object(forKey: Keys.timerStartDate) as? Date else {
            return userDefaults.integer(forKey: Keys.lastKnownSeconds)
        }
        
        let initialSeconds = userDefaults.integer(forKey: Keys.timerInitialSeconds)
        let elapsedTime = Date().timeIntervalSince(startDate)
        let currentSeconds = initialSeconds + Int(elapsedTime)
        
        // Sauvegarder la valeur actuelle
        userDefaults.set(currentSeconds, forKey: Keys.lastKnownSeconds)
        
        return currentSeconds
    }
    
    /// Met à jour les secondes connues (appelé périodiquement quand l'app est active)
    func updateLastKnownSeconds(_ seconds: Int) {
        userDefaults.set(seconds, forKey: Keys.lastKnownSeconds)
    }
    
    /// Vérifie si le timer tourne en arrière-plan
    var isTimerRunning: Bool {
        return userDefaults.bool(forKey: Keys.isTimerRunning)
    }
    
    /// Réinitialise complètement le timer
    func resetTimer() {
        stopBackgroundTimer()
        userDefaults.set(0, forKey: Keys.lastKnownSeconds)
    }
    
    // MARK: - Notifications
    
    private func setupNotificationPermissions() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Erreur lors de la demande de permissions de notification: \(error)")
            }
        }
    }
    
    private func scheduleTimerNotifications() {
        // Annuler les notifications existantes
        cancelTimerNotifications()
        
        // Notification à 5 minutes
        scheduleNotification(
            identifier: "timer_5min",
            title: "Timer d'étude",
            body: "Vous étudiez depuis 5 minutes ! 📚",
            timeInterval: 5 * 60
        )
        
        // Notification à 15 minutes
        scheduleNotification(
            identifier: "timer_15min",
            title: "Timer d'étude",
            body: "Excellent ! 15 minutes d'étude accomplie ! 🎯",
            timeInterval: 15 * 60
        )
        
        // Notification à 30 minutes
        scheduleNotification(
            identifier: "timer_30min",
            title: "Timer d'étude",
            body: "Bravo ! 30 minutes d'étude continue ! 🏆",
            timeInterval: 30 * 60
        )
        
        // Notification à 1 heure
        scheduleNotification(
            identifier: "timer_1hour",
            title: "Timer d'étude",
            body: "Incroyable ! 1 heure d'étude ! Pensez à faire une pause 😊",
            timeInterval: 60 * 60
        )
    }
    
    private func scheduleNotification(identifier: String, title: String, body: String, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Erreur lors de la planification de la notification \(identifier): \(error)")
            }
        }
    }
    
    private func cancelTimerNotifications() {
        let identifiers = ["timer_5min", "timer_15min", "timer_30min", "timer_1hour"]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
}

// MARK: - App Lifecycle Notifications
extension BackgroundTimerService {
    
    func handleAppDidEnterBackground() {
        // L'app va en arrière-plan, rien de spécial à faire
        // Les UserDefaults et notifications sont déjà configurés
    }
    
    func handleAppWillEnterForeground() {
        // L'app revient au premier plan
        // Le TimerViewModel va automatiquement se synchroniser
    }
    
    func handleAppWillTerminate() {
        // L'app va se fermer complètement
        // Assurer que les données sont sauvegardées
        if isTimerRunning {
            let currentSeconds = getCurrentTimerSeconds()
            updateLastKnownSeconds(currentSeconds)
        }
    }
}
