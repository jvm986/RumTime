//
//  GameFooterView.swift
//  RumTime
//
//  Created by James Maguire on 08/10/2022.
//

import SwiftUI

struct GameFooterView: View {
    let turn: Int
    let nextPlayer: String
    let theme: Theme
    let timeRemaining: Double
    
    private var turnText: String {
        return "\(nextPlayer) is next"
    }
    
    var body: some View {
        VStack {
                Text(turnText)
            .foregroundColor(timeRemaining > 10 ? theme.accentColor: .black)
        }
        .font(.title2)
        .padding([.bottom, .horizontal])
        .accessibilityLabel(turnText)
        .accessibilityAddTraits(.isStaticText)
    }
}

struct GameFooterView_Previews: PreviewProvider {
    static var previews: some View {
        GameFooterView(
            turn: 1,
            nextPlayer: Game.sampleData[0].players[0].name,
            theme: Theme.chive,
            timeRemaining: 12
        )
    }
}
