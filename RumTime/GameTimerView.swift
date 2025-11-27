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
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let strokeWidth = size * 0.05  // 5% of size
            let arcWidth = size * 0.025    // 2.5% of size

            ZStack {
                Circle()
                    .strokeBorder(lineWidth: strokeWidth)
                    .foregroundColor(timeRemaining > 10 ? theme.accentColor: .black)

                TimeView(totalSeconds: timeRemaining)
                    .foregroundColor(timeRemaining > 10 ? theme.accentColor: .black)
                    .padding(size * 0.15)

                PlayerArc(startingTime: startingTime, timeRemaining: timeRemaining)
                    .rotation(Angle(degrees: -90))
                    .stroke(timeRemaining > 15 ? theme.mainColor: .red, style: StrokeStyle(lineWidth: arcWidth, lineCap: .round))
                    .padding(strokeWidth / 2)
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
