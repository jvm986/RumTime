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
                Label(round.winner.player.name, systemImage: "rosette")
            }
            Section(header: Text("Scores")) {
                ForEach($round.scores) { $score in
                    if !score.isWinner {
                        HStack {
                            Label(score.player.name, systemImage: "person")
                                .onTapGesture {
                                    round.setWinner(id: score.player.id)
                                }
                            Spacer()
                            Picker("", selection: $score.score) {
                                ForEach(1 ..< 200, id: \.self) {
                                    Text("\($0) points")
                                }
                            }
                            .accessibilityValue("\(Int(score.score)) points")
                        }
                    }
                }
            }
        }
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView(round: .constant((Round.sampleData[0].data)))
    }
}
