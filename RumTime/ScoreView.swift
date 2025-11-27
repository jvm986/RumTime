//
//  ScoreView.swift
//  RumTime
//
//  Created by James Maguire on 15/10/2022.
//

import SwiftUI

struct ScoreView: View {
    @Binding var round: Round.Data
    var onDelete: (() -> Void)?
    var onResume: (() -> Void)?
    var onRecord: (() -> Void)?
    var onBack: (() -> Void)?
    var navigationTitle: String = "Record Scores"

    private var winnerID: Binding<UUID> {
        Binding(
            get: {
                round.scores.first(where: { $0.isWinner })?.playerID ?? UUID()
            },
            set: { newID in
                round.setWinner(id: newID)
            }
        )
    }

    private var winnerTheme: Theme {
        round.winner.playerTheme
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                Form {
                Section(header: Text("Winner")) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.orange)

                        Picker("Select Winner", selection: winnerID) {
                            ForEach(round.scores) { score in
                                Text(score.playerName)
                                    .tag(score.playerID)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.primary)
                        .accessibilityLabel("Winner picker")
                    }
                }

                Section(header: Text("Scores")) {
                    ForEach($round.scores) { $score in
                        if !score.isWinner {
                            HStack {
                                Text(score.playerName)
                                Spacer()
                                Picker("", selection: $score.score) {
                                    ForEach(0 ..< 200, id: \.self) {
                                        Text("\($0) points")
                                    }
                                }
                                .accessibilityLabel("Score for \(score.playerName)")
                                .accessibilityValue("\(Int(score.score)) points")
                            }
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Add padding to account for floating button
                if onRecord != nil {
                    Color.clear.frame(height: 70)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let onResume = onResume {
                        Button {
                            onResume()
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                    } else if let onBack = onBack {
                        Button {
                            onBack()
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if let onDelete = onDelete {
                        Button("Cancel", role: .destructive) {
                            onDelete()
                        }
                        .foregroundColor(.red)
                        .accessibilityHint(onResume == nil ? "Delete the round" : "Cancel the round")
                    }
                }
            }
        }

            // Floating Record/Save Button
            if let onRecord = onRecord {
                Button {
                    onRecord()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text(onResume == nil ? "Save Round" : "Record Round")
                            .font(.callout)
                            .fontWeight(.semibold)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .background(
                        Capsule()
                            .fill(winnerTheme.mainColor)
                    )
                    .foregroundColor(winnerTheme.accentColor)
                }
                .accessibilityHint(onResume == nil ? "Saves changes to the round" : "Records the round and returns to the game")
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
    }
}

#Preview {
    ScoreView(round: .constant((Round.sampleData[0].data)))
}
