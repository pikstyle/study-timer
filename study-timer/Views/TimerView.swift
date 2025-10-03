//
//  Timer.swift
//  study-timer
//
//  Created by Simon M on 27/09/2025.
//
import SwiftUI
internal import Combine
struct TimerView: View {
    @State private var time = 0.0
    @State private var isRunning: Bool = false
    @State private var timer: Timer?
    
    var timeString: String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
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
                    Image(systemName: isRunning ? "pause" : "play")
                }
                .padding()
                .background(isRunning ? .red : .green)
                .foregroundStyle(.white)
                .cornerRadius(10)
                
                Button {
                    resetTimer()
                } label: {
                    Image(systemName: "restart")
                }
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .cornerRadius(10)
            }
        }
    }
    
    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            time += 0.01
        }
    }
    
    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
    }
    
    private func resetTimer() {
        stopTimer()
        time = 0.0
    }
}
#Preview {
    TimerView()
}
