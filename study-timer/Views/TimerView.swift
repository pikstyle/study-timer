//
//  Timer.swift
//  study-timer
//
//  Created by Simon M on 27/09/2025.
//

import SwiftUI

struct TimerView: View {
    @StateObject private var viewModel = TimerViewModel()
    @State private var showingSessionRecording = false
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()

                VStack(spacing: 10) {
                    Text("Temps d'étude")
                        .font(.title2)
                        .foregroundColor(.secondary)

                    Text(viewModel.timeString)
                        .font(.system(size: 72, weight: .light, design: .monospaced))
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 40)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .padding(.horizontal)

                VStack(spacing: 20) {
                    Text("Contrôles")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 20) {
                        Button {
                            if viewModel.isRunning {
                                viewModel.stopTimer()
                            } else {
                                viewModel.startTimer()
                            }
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                                    .font(.title2)
                                Text(viewModel.isRunning ? "Pause" : "Start")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                        .frame(width: 80, height: 80)
                        .background(viewModel.isRunning ? .red : .green)
                        .foregroundStyle(.white)
                        .cornerRadius(15)

                        Button {
                            viewModel.resetTimer()
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.title2)
                                Text("Reset")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                        .frame(width: 80, height: 80)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(15)

                        Button {
                            showingSessionRecording = true
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.down.badge.clock.fill")
                                    .font(.title2)
                                Text("Save")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                        .frame(width: 80, height: 80)
                        .background(!viewModel.canSaveSession ? .gray : .orange)
                        .foregroundStyle(.white)
                        .cornerRadius(15)
                        .disabled(!viewModel.canSaveSession)
                    }
                }

                Spacer()

            // Affichage des sessions sauvegardées
            if !viewModel.savedSessions.isEmpty {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Sessions récentes")
                        .font(.headline)
                        .padding(.horizontal)

                    List {
                            ForEach(Array(viewModel.savedSessions.enumerated()), id: \.offset) { index, session in
                                HStack {
                                    Text("Session \(index + 1)")
                                        .font(.body)
                                    Spacer()
                                    Text(session.formattedDuration)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .frame(maxHeight: 200)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                        .padding(.horizontal)
                }
            } else {
                Spacer()
            }
            }
            .navigationTitle("Timer")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingSessionRecording) {
            MVVMSessionRecordingView(
                sessionDuration: TimeInterval(viewModel.seconds)
            ) {
                // Reset timer after session is saved
                viewModel.resetTimer()
            }
        }
    }
}

#Preview {
    TimerView()
}
