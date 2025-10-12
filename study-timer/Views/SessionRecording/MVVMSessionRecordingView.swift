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
                AppTheme.backgroundView()

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
                                .background(AppTheme.darkGreen.opacity(0.3))

                            // Category Selection - Version Simplifiée
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

                                // Liste simple des catégories disponibles
                                VStack(spacing: 8) {
                                    ForEach(viewModel.availableCategories) { category in
                                        Button {
                                            viewModel.selectCategory(category)
                                        } label: {
                                            HStack(spacing: 12) {
                                                // Couleur de la catégorie
                                                Circle()
                                                    .fill(PastelColors.color(for: category.colorId))
                                                    .frame(width: 32, height: 32)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                    )

                                                Text(category.name)
                                                    .foregroundColor(AppTheme.textPrimary)
                                                    .fontWeight(.medium)

                                                Spacer()

                                                // Indicateur de sélection
                                                if viewModel.selectedCategory?.name == category.name {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(AppTheme.primaryGreen)
                                                        .font(.system(size: 20))
                                                }
                                            }
                                            .padding(16)
                                            .background(
                                                viewModel.selectedCategory?.name == category.name
                                                    ? AppTheme.primaryGreen.opacity(0.1)
                                                    : AppTheme.cardBackground
                                            )
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        viewModel.selectedCategory?.name == category.name
                                                            ? AppTheme.primaryGreen.opacity(0.3)
                                                            : Color.clear,
                                                        lineWidth: 1
                                                    )
                                            )
                                        }
                                    }
                                    
                                    // Bouton simple pour ajouter une catégorie
                                    NavigationLink(destination: NewCategoryView(viewModel: viewModel)) {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(AppTheme.primaryGreen)
                                            Text(viewModel.availableCategories.isEmpty ? "Créer votre première catégorie" : "Nouvelle catégorie")
                                                .fontWeight(.medium)
                                                .foregroundColor(AppTheme.primaryGreen)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                        .padding(16)
                                        .background(AppTheme.cardBackground)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(AppTheme.primaryGreen.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .glassCard(cornerRadius: 20, padding: 20)
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
                            }
                        }
                        .disabled(!viewModel.canSaveSession)
                        .primaryButtonStyle(isEnabled: viewModel.canSaveSession)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
                .grainEffect()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.clear, for: .navigationBar)
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
    }
}

// Vue dédiée pour créer une nouvelle catégorie avec choix de couleur
struct NewCategoryView: View {
    @ObservedObject var viewModel: SessionRecordingViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.primaryGreen.opacity(0.15))
                            .frame(width: 64, height: 64)

                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.primaryGreen)
                    }

                    Text("Nouvelle catégorie")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)

                    Text("Créez une catégorie personnalisée")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.top, 20)

                // Form
                VStack(alignment: .leading, spacing: 24) {
                    // Nom
                    VStack(alignment: .leading, spacing: 12) {
                        Label {
                            Text("NOM")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .tracking(1)
                                .foregroundColor(AppTheme.textSecondary)
                        } icon: {
                            Image(systemName: "textformat")
                                .foregroundColor(AppTheme.primaryGreen)
                        }

                        TextField("Ex: Mathématiques", text: $viewModel.newCategoryName)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(16)
                            .background(AppTheme.cardBackground)
                            .cornerRadius(12)
                            .foregroundColor(AppTheme.textPrimary)
                            .autocapitalization(.words)
                    }

                    Divider()
                        .background(AppTheme.darkGreen.opacity(0.3))

                    // Couleur
                    CategoryColorPicker(
                        selectedColorId: $viewModel.newCategoryColorId,
                        title: "Couleur"
                    )
                }
                .glassCard(cornerRadius: 20, padding: 20)
                .padding(.horizontal, 20)

                Spacer()

                // Bouton Créer
                Button {
                    viewModel.createNewCategory()
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))

                        Text("Créer la catégorie")
                    }
                }
                .disabled(viewModel.newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .primaryButtonStyle(isEnabled: !viewModel.newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .background(AppTheme.backgroundView())
        .grainEffect()
        .navigationTitle("Nouvelle catégorie")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MVVMSessionRecordingView(sessionDuration: 3665)
}