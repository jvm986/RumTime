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

    var body: some View {
        NavigationStack {
            Form {
            Section(header: Text("Winner")) {
                Picker("Select Winner", selection: winnerID) {
                    ForEach(round.scores) { score in
                        Text(score.playerName)
                            .tag(score.playerID)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityLabel("Winner picker")
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

                if let onDelete = onDelete {
                    Section {
                        Button(role: .destructive) {
                            onDelete()
                        } label: {
                            HStack {
                                Spacer()
                                Label("Delete Round", systemImage: "trash")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Record Scores")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if let onResume = onResume {
                        Button("Resume") {
                            onResume()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if let onRecord = onRecord {
                        Button("Record") {
                            onRecord()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ScoreView(round: .constant((Round.sampleData[0].data)))
}
