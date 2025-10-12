//
//  SettingsView.swift
//  study-timer
//
//  Created by Claude on 08/10/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Titre personnalisé
                HStack {
                    Text("Réglages")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 8)

                List {
                    // Section Catégories
                    Section {
                        NavigationLink {
                            CategoriesManagementView()
                                .environmentObject(viewModel)
                        } label: {
                            SettingsRowView(
                                title: "Catégories",
                                subtitle: "\(viewModel.categories.count) catégorie\(viewModel.categories.count > 1 ? "s" : "")",
                                icon: "folder.fill",
                                iconColor: .blue
                            )
                        }
                    }

                    // Section Données
                    Section {
                        Button {
                            showingDeleteConfirmation = true
                        } label: {
                            SettingsRowView(
                                title: "Supprimer toutes les données",
                                subtitle: "Efface toutes les sessions et catégories",
                                icon: "trash.fill",
                                iconColor: .red
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    } footer: {
                        Text("Cette action est irréversible. Toutes vos sessions d'étude et catégories seront définitivement supprimées.")
                            .font(.caption)
                            .foregroundColor(AppTheme.textLabel)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .background(
                AppTheme.backgroundView()
            )
            .grainEffect()
            .navigationBarHidden(true)
            .alert("Supprimer toutes les données ?", isPresented: $showingDeleteConfirmation) {
                Button("Annuler", role: .cancel) { }
                Button("Supprimer", role: .destructive) {
                    viewModel.clearAllData()
                }
            } message: {
                Text("Cette action est irréversible. Toutes vos sessions d'étude et catégories seront définitivement supprimées.")
            }
        }
        .onAppear {
            viewModel.loadCategories()
        }
    }
}

struct SettingsRowView: View {
    let title: String
    let subtitle: String?
    let icon: String
    let iconColor: Color
    
    init(title: String, subtitle: String? = nil, icon: String, iconColor: Color) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
    }
    
    var body: some View {
        HStack {
            // Icône avec background coloré
            RoundedRectangle(cornerRadius: 6)
                .fill(iconColor)
                .frame(width: 28, height: 28)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(AppTheme.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(AppTheme.textLabel)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

// Vue séparée pour la gestion des catégories
struct CategoriesManagementView: View {
    @EnvironmentObject private var viewModel: SettingsViewModel
    @State private var showingNewCategoryAlert = false
    @State private var newCategoryName = ""
    
    var body: some View {
        List {
            Section {
                // Catégories existantes
                ForEach(viewModel.categories) { category in
                    CategoryRowView(category: category) { newName in
                        viewModel.renameCategory(category, to: newName)
                    } onDelete: {
                        viewModel.deleteCategory(category)
                    }
                }
                
                // Bouton Ajouter une catégorie
                Button {
                    showingNewCategoryAlert = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppTheme.accentPrimary)
                        Text("Ajouter une catégorie")
                            .foregroundColor(AppTheme.accentPrimary)
                    }
                }
                
            } footer: {
                if viewModel.categories.isEmpty {
                    Text("Aucune catégorie créée. Les catégories vous permettent d'organiser vos sessions d'étude.")
                } else {
                    Text("Balayez vers la gauche pour supprimer une catégorie.")
                }
            }
        }
        .navigationTitle("Catégories")
        .navigationBarTitleDisplayMode(.large)
        .alert("Nouvelle catégorie", isPresented: $showingNewCategoryAlert) {
            TextField("Nom de la catégorie", text: $newCategoryName)
            Button("Créer") {
                createNewCategory()
            }
            .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            Button("Annuler", role: .cancel) {
                newCategoryName = ""
            }
        } message: {
            Text("Entrez le nom de la nouvelle catégorie")
        }
    }
    
    private func createNewCategory() {
        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        viewModel.createCategory(trimmedName)
        newCategoryName = ""
        showingNewCategoryAlert = false
    }
}

struct CategoryRowView: View {
    let category: Category
    let onRename: (String) -> Void
    let onDelete: () -> Void
    @EnvironmentObject private var viewModel: SettingsViewModel

    @State private var showingRenameAlert = false
    @State private var newName = ""

    var body: some View {
        NavigationLink(destination: CategoryEditView(category: category, viewModel: viewModel)) {
            HStack {
                // Icône de catégorie avec couleur
                RoundedRectangle(cornerRadius: 6)
                    .fill(PastelColors.color(for: category.colorId))
                    .frame(width: 28, height: 28)
                    .overlay {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(.body)
                        .foregroundColor(AppTheme.textPrimary)
                }

                Spacer()
            }
            .padding(.vertical, 4)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                onDelete()
            } label: {
                Label("Supprimer", systemImage: "trash")
            }
            .tint(.red)
        }
    }
}

// Vue dédiée pour éditer une catégorie
struct CategoryEditView: View {
    let category: Category
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var categoryName: String
    @State private var selectedColorId: String
    @State private var showingDeleteConfirmation = false

    init(category: Category, viewModel: SettingsViewModel) {
        self.category = category
        self.viewModel = viewModel
        self._categoryName = State(initialValue: category.name)
        self._selectedColorId = State(initialValue: category.colorId)
    }

    var body: some View {
        List {
            Section {
                // Nom
                HStack {
                    Text("Nom")
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    TextField("Nom de la catégorie", text: $categoryName)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(AppTheme.textLabel)
                }
            }

            Section {
                // Couleur - Navigation vers une vue dédiée
                NavigationLink {
                    CategoryColorSelectionView(selectedColorId: $selectedColorId)
                } label: {
                    HStack {
                        Text("Couleur")
                            .foregroundColor(AppTheme.textPrimary)

                        Spacer()

                        // Preview de la couleur
                        Circle()
                            .fill(PastelColors.color(for: selectedColorId))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }

            Section {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Supprimer la catégorie")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Modifier")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Enregistrer") {
                    saveChanges()
                }
                .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .alert("Supprimer la catégorie ?", isPresented: $showingDeleteConfirmation) {
            Button("Annuler", role: .cancel) { }
            Button("Supprimer", role: .destructive) {
                viewModel.deleteCategory(category)
                dismiss()
            }
        } message: {
            Text("Cette action est irréversible. Toutes les sessions associées à cette catégorie seront également supprimées.")
        }
    }

    private func saveChanges() {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        // Update name if changed
        if trimmedName != category.name {
            viewModel.renameCategory(category, to: trimmedName)
        }

        // Update color if changed
        if selectedColorId != category.colorId {
            var updatedCategory = category
            updatedCategory.colorId = selectedColorId
            viewModel.updateCategoryColor(updatedCategory, colorId: selectedColorId)
        }

        dismiss()
    }
}

// Vue dédiée pour sélectionner une couleur
struct CategoryColorSelectionView: View {
    @Binding var selectedColorId: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            // Grille de couleurs
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ], spacing: 20) {
                ForEach(PastelColors.all) { pastelColor in
                    Button {
                        selectedColorId = pastelColor.id
                        dismiss()
                    } label: {
                        Circle()
                            .fill(pastelColor.color)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: selectedColorId == pastelColor.id ? 3 : 0)
                            )
                            .overlay(
                                Circle()
                                    .stroke(AppTheme.primaryGreen, lineWidth: selectedColorId == pastelColor.id ? 2 : 0)
                                    .padding(-3)
                            )
                            .shadow(color: pastelColor.color.opacity(0.4), radius: selectedColorId == pastelColor.id ? 12 : 6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 40)

            Spacer()
        }
        .background(AppTheme.backgroundView())
        .grainEffect()
        .navigationTitle("Choisir une couleur")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
}

// Vue d'information pour le timer en arrière-plan
struct BackgroundTimerInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.2.circlepath")
                            .font(.system(size: 64))
                            .foregroundColor(.orange)
                        
                        Text("Timer en arrière-plan")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Continuez à étudier même quand l'app est fermée")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textLabel)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                    
                    // Comment ça marche
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Comment ça marche ?")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        FeatureRow(
                            icon: "play.circle.fill",
                            title: "Démarrer le timer",
                            description: "Lancez votre session d'étude normalement"
                        )
                        
                        FeatureRow(
                            icon: "iphone",
                            title: "Fermez l'app",
                            description: "Le timer continue de tourner en arrière-plan"
                        )
                        
                        FeatureRow(
                            icon: "bell.fill",
                            title: "Notifications",
                            description: "Recevez des notifications à 5min, 15min, 30min et 1h"
                        )
                        
                        FeatureRow(
                            icon: "arrow.clockwise",
                            title: "Reprenez où vous étiez",
                            description: "En rouvrant l'app, le timer affiche le temps exact"
                        )
                    }
                    
                    Divider()
                    
                    // Paramètres requis
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Paramètres requis")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "bell.badge")
                                    .foregroundColor(AppTheme.accentPrimary)
                                    .frame(width: 20)
                                Text("Notifications")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("Autorisées ✓")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            
                            Text("Les notifications sont automatiquement demandées au premier démarrage du timer.")
                                .font(.caption)
                                .foregroundColor(AppTheme.textLabel)
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.2.circlepath")
                                    .foregroundColor(.orange)
                                    .frame(width: 20)
                                Text("Actualisation en arrière-plan")
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            
                            Text("Pour une expérience optimale, activez l'actualisation en arrière-plan dans Réglages > Général > Actualisation en arrière-plan > Study Timer")
                                .font(.caption)
                                .foregroundColor(AppTheme.textLabel)
                            
                            Button("Ouvrir les Réglages") {
                                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(settingsUrl)
                                }
                            }
                            .font(.caption)
                            .foregroundColor(AppTheme.accentPrimary)
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Timer en arrière-plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(AppTheme.textLabel)
            }
            
            Spacer()
        }
    }
}
