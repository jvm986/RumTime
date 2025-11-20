//
//  ScoreView.swift
//  RumTime
//
//  Created by James Maguire on 15/10/2022.
//

import SwiftUI

struct ScoreView: View {
    @Binding var round: Round.Data

    var body: some View {
        Form {
            Section(header: Text("Winner")) {
                ForEach($round.scores) { $score in
                    Button(action: {
                        round.setWinner(id: score.playerID)
                    }) {
                        HStack {
                            Image(systemName: score.isWinner ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(score.isWinner ? .green : .gray)
                                .imageScale(.large)
                            Text(score.playerName)
                                .foregroundColor(.primary)
                            Spacer()
                            if score.isWinner {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(score.isWinner ? "\(score.playerName), winner" : "Select \(score.playerName) as winner")
                    .accessibilityAddTraits(score.isWinner ? [.isButton, .isSelected] : .isButton)
                }
            }

            Section(header: Text("Scores")) {
                ForEach($round.scores) { $score in
                    if !score.isWinner {
                        HStack {
                            Text(score.playerName)
                            Spacer()
                            Picker("", selection: $score.score) {
                                ForEach(1 ..< 200, id: \.self) {
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
        .navigationTitle("Record Scores")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ScoreView(round: .constant((Round.sampleData[0].data)))
}
