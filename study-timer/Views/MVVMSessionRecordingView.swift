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
        NavigationView {
            VStack(spacing: 20) {
                Text("Enregistrer la session")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading) {
                        Text("Date")
                            .font(.headline)
                        DatePicker("Date de la session", selection: $viewModel.sessionDate, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                    }

                    VStack(alignment: .leading) {
                        Text("Temps d'étude")
                            .font(.headline)
                        Text(viewModel.formattedDuration)
                            .font(.title2)
                            .foregroundColor(.blue)
                    }

                    VStack(alignment: .leading) {
                        Text("Catégorie")
                            .font(.headline)

                        if viewModel.availableCategories.isEmpty {
                            Button("Créer une catégorie") {
                                viewModel.showNewCategoryAlert()
                            }
                            .foregroundColor(.blue)
                        } else {
                            Menu {
                                ForEach(viewModel.availableCategories) { category in
                                    Button(category.name) {
                                        viewModel.selectCategory(category)
                                    }
                                }

                                Divider()

                                Button("Nouvelle catégorie...") {
                                    viewModel.showNewCategoryAlert()
                                }
                            } label: {
                                HStack {
                                    Text(viewModel.categoryMenuText)
                                        .foregroundColor(viewModel.selectedCategory == nil ? .gray : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                Button {
                    if viewModel.saveSession() {
                        dismiss()
                    }
                } label: {
                    Text("Enregistrer la session")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.canSaveSession ? .blue : .gray)
                        .cornerRadius(12)
                }
                .disabled(!viewModel.canSaveSession)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
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