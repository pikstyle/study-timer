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
        NavigationStack {
            ZStack {
                AppTheme.backgroundView()

                VStack(spacing: 32) {
                    // Titre personnalisé
                    HStack {
                        Text("Timer")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    Spacer()

                    // Timer Display
                    VStack(spacing: 16) {
                        Text("CHRONOMÈTRE")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.textSecondary)
                            .tracking(2)

                        // Timer text centré
                        VStack(spacing: 12) {
                            Text(viewModel.timeString)
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.textPrimary)
                                .monospacedDigit()

                            if viewModel.isRunning {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(AppTheme.brightGreen)
                                        .frame(width: 8, height: 8)
                                        .glowEffect(color: AppTheme.brightGreen, radius: 4)
                                        .scaleEffect(viewModel.isRunning ? 1.0 : 0.5)
                                        .animation(.easeInOut(duration: 0.8).repeatForever(), value: viewModel.isRunning)

                                    Text("En cours")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.lightGreen)
                                }
                            }
                        }
                    }

                    Spacer()

                    // Control Buttons
                    VStack(spacing: 20) {
                        HStack(spacing: 16) {
                            // Start/Pause Button
                            Button {
                                if viewModel.isRunning {
                                    viewModel.stopTimer()
                                } else {
                                    viewModel.startTimer()
                                }
                            } label: {
                                VStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(viewModel.isRunning ? Color(hex: "FF453A") : AppTheme.primaryGreen)
                                            .frame(width: 64, height: 64)
                                            .animation(.easeInOut(duration: 0.3), value: viewModel.isRunning)

                                        Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(.white)
                                            .animation(.easeInOut(duration: 0.3), value: viewModel.isRunning)
                                    }

                                    Text(viewModel.isRunning ? "Pause" : "Démarrer")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                            }
                            .glassControlButton(
                                accentColor: viewModel.isRunning ? Color(hex: "FF453A") : AppTheme.primaryGreen,
                                isActive: true
                            )
                            .animation(.easeInOut(duration: 0.3), value: viewModel.isRunning)

                            // Reset Button
                            Button {
                                viewModel.resetTimer()
                            } label: {
                                VStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "0A84FF"))
                                            .frame(width: 64, height: 64)

                                        Image(systemName: "arrow.counterclockwise")
                                            .font(.system(size: 28))
                                            .foregroundColor(.white)
                                    }

                                    Text("Réinitialiser")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                            }
                            .disabled(!viewModel.hasActiveSession)
                            .glassControlButton(
                                accentColor: Color(hex: "0A84FF"),
                                isActive: true
                            )
                        }

                        // Save Button
                        Button {
                            showingSessionRecording = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))

                                Text("Enregistrer la session")
                            }
                        }
                        .disabled(!viewModel.canSaveSession)
                        .primaryButtonStyle(isEnabled: viewModel.canSaveSession)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .grainEffect()
            }
            .navigationBarHidden(true)
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
