//
//  TimerViewModel.swift
//  study-timer
//
//  Created by Claude on 04/10/2025.
//

import Foundation
import Combine

class TimerViewModel: ObservableObject {
    @Published var seconds: Int = 0
    @Published var isRunning: Bool = false
    @Published var savedSessions: [TimerSession] = []

    private var timer: Timer?
    private let repository: StudyRepositoryProtocol

    init(repository: StudyRepositoryProtocol = StudyRepository.shared) {
        self.repository = repository
    }

    var timeString: String {
        TimeFormatter.formatTimer(TimeInterval(seconds))
    }

    var canSaveSession: Bool {
        seconds > 0
    }

    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.seconds += 1
        }
    }

    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func resetTimer() {
        stopTimer()
        seconds = 0
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

    deinit {
        timer?.invalidate()
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