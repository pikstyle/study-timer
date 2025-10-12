//
//  TimerViewModel.swift
//  study-timer
//
//  Created by Claude on 04/10/2025.
//

import Foundation
import Combine
import UIKit

class TimerViewModel: ObservableObject {
    @Published var seconds: Int = 0
    @Published var isRunning: Bool = false
    @Published var savedSessions: [TimerSession] = []

    private var timer: Timer?
    private let repository: StudyRepositoryProtocol
    private let backgroundService = BackgroundTimerService.shared

    init(repository: StudyRepositoryProtocol = StudyRepository.shared) {
        self.repository = repository
        setupAppLifecycleObservers()
        restoreTimerState()
    }

    var timeString: String {
        TimeFormatter.formatTimer(TimeInterval(seconds))
    }

    var canSaveSession: Bool {
        seconds > 0
    }

    var hasActiveSession: Bool {
        seconds > 0
    }

    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        
        // Démarrer le service en arrière-plan
        backgroundService.startBackgroundTimer(initialSeconds: seconds)
        
        // Démarrer le timer local pour l'UI
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.seconds += 1
            // Mettre à jour périodiquement le service en arrière-plan
            self.backgroundService.updateLastKnownSeconds(self.seconds)
        }
    }

    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        // Arrêter le service en arrière-plan
        backgroundService.stopBackgroundTimer()
    }

    func resetTimer() {
        stopTimer()
        seconds = 0
        backgroundService.resetTimer()
    }

    func saveToLocalHistory() {
        guard seconds > 0 else { return }
        if isRunning {
            stopTimer()
        }

        let session = TimerSession(duration: TimeInterval(seconds), date: Date())
        savedSessions.append(session)
        seconds = 0
    }

    func recordSession(categoryName: String, date: Date = Date()) {
        guard seconds > 0 else { return }

        let session = StudySession(
            duration: TimeInterval(seconds),
            categoryName: categoryName,
            date: date
        )

        repository.saveSession(session)
        seconds = 0
    }
    
    // MARK: - Background Timer Restoration
    
    private func restoreTimerState() {
        if backgroundService.isTimerRunning {
            // Restaurer l'état du timer depuis l'arrière-plan
            seconds = backgroundService.getCurrentTimerSeconds()
            isRunning = true
            
            // Redémarrer le timer local pour l'UI
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.seconds += 1
                self.backgroundService.updateLastKnownSeconds(self.seconds)
            }
        } else {
            // Récupérer les dernières secondes connues
            seconds = backgroundService.getCurrentTimerSeconds()
        }
    }
    
    private func setupAppLifecycleObservers() {
        // Observer quand l'app va en arrière-plan
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        // Observer quand l'app revient au premier plan
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        // Observer quand l'app va se fermer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }
    
    @objc private func appDidEnterBackground() {
        backgroundService.handleAppDidEnterBackground()
    }
    
    @objc private func appWillEnterForeground() {
        if backgroundService.isTimerRunning {
            // Synchroniser avec le temps réel
            seconds = backgroundService.getCurrentTimerSeconds()
            
            // Redémarrer le timer local si nécessaire
            if isRunning && timer == nil {
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    self.seconds += 1
                    self.backgroundService.updateLastKnownSeconds(self.seconds)
                }
            }
        }
        backgroundService.handleAppWillEnterForeground()
    }
    
    @objc private func appWillTerminate() {
        backgroundService.handleAppWillTerminate()
    }

    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Helper Models
struct TimerSession: Identifiable {
    let id = UUID()
    let duration: TimeInterval
    let date: Date

    var formattedDuration: String {
        TimeFormatter.format(duration)
    }
}