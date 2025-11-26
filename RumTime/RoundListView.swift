//
//  RoundListView.swift
//  RumTime
//
//  Created by James Maguire on 25.11.25.
//

import SwiftUI
import SwiftData

struct RoundListView: View {
    let game: Game
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var editingRound: Round?
    @State private var roundData = Round.Data()
    @State private var showingClearConfirmation = false

    var body: some View {
        NavigationView {
            List {
                if game.rounds.isEmpty {
                    ContentUnavailableView(
                        "No Rounds Yet",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("Rounds will appear here after you finish playing")
                    )
                } else {
                    ForEach(game.rounds) { round in
                        Button {
                            editingRound = round
                            roundData = round.data
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(round.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.headline)

                                    HStack(spacing: 4) {
                                        Image(systemName: "trophy.fill")
                                        Text(round.winner.playerName)
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Round History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                            Image(systemName: "chevron.left")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if !game.rounds.isEmpty {
                        Button(role: .destructive) {
                            showingClearConfirmation = true
                        } label: {
                            Text("Clear All")
                        }
                    }
                }
            }
            .alert("Clear Round History?", isPresented: $showingClearConfirmation) {
                Button("Clear All", role: .destructive) {
                    game.rounds.removeAll()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete all \(game.rounds.count) round(s)? This action cannot be undone.")
            }
            .sheet(item: $editingRound) { round in
                RoundEditView(round: round, roundData: $roundData, game: game)
            }
        }
    }
}

struct RoundEditView: View {
    let round: Round
    @Binding var roundData: Round.Data
    let game: Game
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationView {
            ScoreView(round: $roundData, onDelete: {
                modelContext.delete(round)
                dismiss()
            })
            .navigationTitle("Edit Round")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveChanges() {
        // Use Game's calculateScores to apply proper scoring logic
        let newScores = game.calculateScores(from: roundData)
        round.scores.removeAll()
        round.scores.append(contentsOf: newScores)
    }
}
