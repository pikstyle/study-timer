//
//  TimeFormatter.swift
//  study-timer
//
//  Created by Claude on 04/10/2025.
//

import Foundation

struct TimeFormatter {
    static func format(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60

        if hours > 0 {
            return String(format: "%dh%02dm%02ds", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%dm%02ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }

    static func formatTimer(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }

    static func formatCompact(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60

        if hours > 0 {
            return String(format: "%dh%02d", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
}