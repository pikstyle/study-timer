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
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Categories Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundColor(AppTheme.primaryGreen)
                                Text("Catégories")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                            }
                            
                            if viewModel.categories.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "folder.badge.plus")
                                        .font(.system(size: 48))
                                        .foregroundColor(AppTheme.textSecondary.opacity(0.3))
                                    
                                    Text("Aucune catégorie")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textSecondary)
                                        
                                    Text("Les catégories apparaîtront ici quand vous les créerez")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                LazyVStack(spacing: 8) {
                                    ForEach(viewModel.categories) { category in
                                        CategoryRowView(category: category) { newName in
                                            viewModel.renameCategory(category, to: newName)
                                        } onDelete: {
                                            viewModel.deleteCategory(category)
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
                        
                        // App Info Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(AppTheme.primaryGreen)
                                Text("Informations")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                InfoRowView(title: "Version", value: "1.0.0")
                                InfoRowView(title: "Build", value: "1")
                            }
                        }
                        .padding(20)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Terminé") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primaryGreen)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            viewModel.loadCategories()
        }
    }
}

struct CategoryRowView: View {
    let category: Category
    let onRename: (String) -> Void
    let onDelete: () -> Void
    
    @State private var showingRenameAlert = false
    @State private var newName = ""
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            Spacer()
            
            Button {
                newName = category.name
                showingRenameAlert = true
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.primaryGreen)
            }
        }
        .padding(12)
        .background(AppTheme.background)
        .cornerRadius(12)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                onDelete()
            } label: {
                Label("Supprimer", systemImage: "trash")
            }
            .tint(.red)
        }
        .alert("Renommer la catégorie", isPresented: $showingRenameAlert) {
            TextField("Nouveau nom", text: $newName)
            Button("Renommer") {
                onRename(newName)
            }
            .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            Button("Annuler", role: .cancel) { }
        } message: {
            Text("Entrez le nouveau nom de la catégorie")
        }
    }
}

struct InfoRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView()
}