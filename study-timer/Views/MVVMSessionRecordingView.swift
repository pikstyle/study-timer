//
//  MVVMSessionRecordingView.swift
//  study-timer
//
//  Created by Claude on 04/10/2025.
//

import SwiftUI

struct MVVMSessionRecordingView: View {
    @StateObject private var viewModel: SessionRecordingViewModel
    @Environment(\.dismiss) private var dismiss

    let onSessionSaved: () -> Void

    init(sessionDuration: TimeInterval, onSessionSaved: @escaping () -> Void = {}) {
        self.onSessionSaved = onSessionSaved
        self._viewModel = StateObject(wrappedValue: SessionRecordingViewModel(
            sessionDuration: sessionDuration,
            onSessionSaved: onSessionSaved
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        // Header
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primaryGreen.opacity(0.15))
                                    .frame(width: 64, height: 64)

                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(AppTheme.primaryGreen)
                            }

                            Text("Enregistrer la session")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)

                            Text("Sauvegardez votre temps d'étude")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.top, 20)

                        // Session Details Card
                        VStack(alignment: .leading, spacing: 24) {

                            // Duration Display
                            VStack(alignment: .leading, spacing: 12) {
                                Label {
                                    Text("DURÉE")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .tracking(1)
                                        .foregroundColor(AppTheme.textSecondary)
                                } icon: {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(AppTheme.primaryGreen)
                                }

                                Text(viewModel.formattedDuration)
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.primaryGreen)
                            }

                            Divider()
                                .background(AppTheme.divider)

                            // Category Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Label {
                                    Text("CATÉGORIE")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .tracking(1)
                                        .foregroundColor(AppTheme.textSecondary)
                                } icon: {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(AppTheme.primaryGreen)
                                }

                                if viewModel.availableCategories.isEmpty {
                                    Button {
                                        viewModel.showNewCategoryAlert()
                                    } label: {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                            Text("Créer une catégorie")
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(AppTheme.primaryGreen)
                                        .frame(maxWidth: .infinity)
                                        .padding(16)
                                        .background(AppTheme.background)
                                        .cornerRadius(12)
                                    }
                                } else {
                                    VStack(spacing: 8) {
                                        // Selected category display or create new button
                                        if let selectedCategory = viewModel.selectedCategory {
                                            HStack {
                                                Text(selectedCategory.name)
                                                    .foregroundColor(AppTheme.textPrimary)
                                                    .fontWeight(.medium)
                                                Spacer()
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(AppTheme.primaryGreen)
                                            }
                                            .padding(16)
                                            .background(AppTheme.primaryGreen.opacity(0.1))
                                            .cornerRadius(12)
                                        }
                                        
                                        // Categories list with swipe actions
                                        ForEach(viewModel.availableCategories) { category in
                                            Button {
                                                viewModel.selectCategory(category)
                                            } label: {
                                                HStack {
                                                    Text(category.name)
                                                        .foregroundColor(AppTheme.textPrimary)
                                                        .fontWeight(viewModel.selectedCategory?.name == category.name ? .medium : .regular)
                                                    Spacer()
                                                    if viewModel.selectedCategory?.name == category.name {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundColor(AppTheme.primaryGreen)
                                                    }
                                                }
                                                .padding(12)
                                                .background(AppTheme.background)
                                                .cornerRadius(8)
                                            }
                                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                Button {
                                                    viewModel.deleteCategory(category)
                                                } label: {
                                                    Label("Supprimer", systemImage: "trash")
                                                }
                                                .tint(.red)
                                            }
                                        }
                                        
                                        // Add new category button
                                        Button {
                                            viewModel.showNewCategoryAlert()
                                        } label: {
                                            HStack {
                                                Image(systemName: "plus.circle")
                                                Text("Nouvelle catégorie")
                                                    .fontWeight(.medium)
                                            }
                                            .foregroundColor(AppTheme.primaryGreen)
                                            .frame(maxWidth: .infinity)
                                            .padding(12)
                                            .background(AppTheme.background)
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
                        .padding(.horizontal, 20)

                        Spacer()

                        // Save Button
                        Button {
                            if viewModel.saveSession() {
                                dismiss()
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))

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
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppTheme.textSecondary)
                            Text("Annuler")
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                }
            }
        }
        .alert("Nouvelle catégorie", isPresented: $viewModel.showingNewCategoryAlert) {
            TextField("Nom de la catégorie", text: $viewModel.newCategoryName)
            Button("Créer") {
                viewModel.createNewCategory()
            }
            .disabled(viewModel.newCategoryName.isEmpty)
            Button("Annuler", role: .cancel) {
                viewModel.newCategoryName = ""
            }
        } message: {
            Text("Entrez le nom de la nouvelle catégorie")
        }
    }
}

#Preview {
    MVVMSessionRecordingView(sessionDuration: 3665)
}