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

                ScrollView {
                    VStack(spacing: 32) {
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
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                        }
                        .padding(.top, 40)

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

                        // Recent Sessions
                        if !viewModel.savedSessions.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .foregroundColor(AppTheme.primaryGreen)
                                    Text("Sessions récentes")
                                        .font(.headline)
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                                .padding(.horizontal, 20)

                                VStack(spacing: 12) {
                                    ForEach(Array(viewModel.savedSessions.enumerated()), id: \.offset) { index, session in
                                        HStack {
                                            ZStack {
                                                Circle()
                                                    .fill(AppTheme.primaryGreen.opacity(0.15))
                                                    .frame(width: 40, height: 40)

                                                Text("\(index + 1)")
                                                    .font(.subheadline)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(AppTheme.primaryGreen)
                                            }

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Session \(index + 1)")
                                                    .font(.subheadline)
                                                    .foregroundColor(AppTheme.textPrimary)

                                                Text(session.formattedDuration)
                                                    .font(.caption)
                                                    .foregroundColor(AppTheme.textSecondary)
                                            }

                                            Spacer()

                                            Text(session.formattedDuration)
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(AppTheme.primaryGreen)
                                        }
                                        .padding(16)
                                        .background(AppTheme.cardBackground)
                                        .cornerRadius(16)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Timer")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
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
