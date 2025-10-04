//
//  Timer.swift
//  study-timer
//
//  Created by Simon M on 27/09/2025.
//

import SwiftUI

struct TimerView: View {
    @State private var seconds = 0
    @State private var isRunning = false
    @State private var timer: Timer?
    
    var timeString: String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%d:%02d:%02d", hours, minutes, secs)
    }
    
    var body: some View {
        VStack {
            Text(timeString)
                .font(.system(size: 64))
                .monospacedDigit()
                .padding()
            
            HStack {
                Button {
                    if isRunning {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                } label: {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                }
                .padding()
                .background(isRunning ? .red : .green)
                .foregroundStyle(.white)
                .cornerRadius(10)
                
                Button {
                    resetTimer()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .cornerRadius(10)
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            seconds += 1
        }
    }
    
    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
    }
    
    private func resetTimer() {
        stopTimer()
        seconds = 0
    }
}

#Preview {
    TimerView()
}
