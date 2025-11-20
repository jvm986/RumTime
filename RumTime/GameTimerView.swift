//
//  GameTimerView.swift
//  RumTime
//
//  Created by James Maguire on 08/10/2022.
//

import SwiftUI

struct GameTimerView: View {
    let turn: Int
    let startingTime: Int
    let timeRemaining: Double
    let currentPlayer: String
    let theme: Theme
    
    var body: some View {
        Circle()
            .strokeBorder(lineWidth: 24)
            .foregroundColor(timeRemaining > 10 ? theme.accentColor: .black)
            .overlay {
                TimeView(totalSeconds: timeRemaining)
                    .foregroundColor(timeRemaining > 10 ? theme.accentColor: .black)
                    .frame(maxWidth: 200)
            }
            .overlay {
                PlayerArc(startingTime: startingTime, timeRemaining: timeRemaining)
                    .rotation(Angle(degrees: -90))
                    .stroke(timeRemaining > 15 ? theme.mainColor: .red, lineWidth: 12)
            }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameTimerView(
            turn: 2,
            startingTime: 300,
            timeRemaining: 300,
            currentPlayer: "Wade Watts",
            theme: Theme.chive
        )
    }
}
