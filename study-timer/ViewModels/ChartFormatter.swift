//
//  ChartFormatter.swift
//  study-timer
//
//  Created by Claude on 08/10/2025.
//

import Foundation

struct ChartFormatter {
    /// Formate la durée en minutes pour l'affichage dans les graphiques
    static func formatMinutes(_ minutes: Double) -> String {
        let totalMinutes = Int(minutes)
        
        if totalMinutes < 60 {
            return "\(totalMinutes)min"
        } else {
            let hours = totalMinutes / 60
            let remainingMinutes = totalMinutes % 60
            
            if remainingMinutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h\(remainingMinutes)"
            }
        }
    }
    
    /// Formate la durée en heures avec décimales pour l'affichage
    static func formatHours(_ seconds: TimeInterval) -> String {
        let hours = seconds / 3600
        if hours < 1 {
            let minutes = Int(seconds / 60)
            return "\(minutes)min"
        } else {
            return String(format: "%.1fh", hours)
        }
    }
}