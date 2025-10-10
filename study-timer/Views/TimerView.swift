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
                AppTheme.background.ignoresSafeArea()

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

                        // Timer text centré sans cercle
                        VStack(spacing: 12) {
                            Text(viewModel.timeString)
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.textPrimary)
                                .monospacedDigit()

                            if viewModel.isRunning {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(AppTheme.primaryGreen)
                                        .frame(width: 8, height: 8)
                                        .scaleEffect(viewModel.isRunning ? 1.0 : 0.5)
                                        .animation(.easeInOut(duration: 0.8).repeatForever(), value: viewModel.isRunning)

                                    Text("En cours")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.primaryGreen)
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
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if viewModel.isRunning {
                                        viewModel.stopTimer()
                                    } else {
                                        viewModel.startTimer()
                                    }
                                }
                            } label: {
                                VStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(viewModel.isRunning ? Color(hex: "FF453A") : AppTheme.primaryGreen)
                                            .frame(width: 64, height: 64)

                                        Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(.white)
                                    }

                                    Text(viewModel.isRunning ? "Pause" : "Démarrer")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(AppTheme.cardBackground)
                            .cornerRadius(20)

                            // Reset Button
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.resetTimer()
                                }
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
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(AppTheme.cardBackground)
                            .cornerRadius(20)
                        }

                        // Save Button
                        Button {
                            showingSessionRecording = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))

                                Text("Enregistrer la session")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                viewModel.canSaveSession
                                    ? AppTheme.greenGradient
                                    : LinearGradient(colors: [Color.gray.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(16)
                        }
                        .disabled(!viewModel.canSaveSession)
                        .opacity(viewModel.canSaveSession ? 1.0 : 0.5)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
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
