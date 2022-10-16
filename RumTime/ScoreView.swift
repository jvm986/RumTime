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
            Section(header: Text("Scores")) {
                ForEach($round.scores) { $score in
                    Picker(score.player.name, selection: $score.score) {
                            ForEach(0 ..< 200) {
                                Text("\($0) points")
                            }
                        }
                        .accessibilityValue("\(Int(score.score)) points")
                }
            }
        }
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView(round: .constant(Round.sampleData[0].data))
    }
}
