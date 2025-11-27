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

    private func timeRemainingDescription(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        if mins > 0 {
            return "\(mins) minute\(mins == 1 ? "" : "s") and \(secs) second\(secs == 1 ? "" : "s")"
        } else {
            return "\(secs) second\(secs == 1 ? "" : "s")"
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let strokeWidth = size * 0.05  // 5% of size
            let arcWidth = size * 0.025    // 2.5% of size

            ZStack {
                Circle()
                    .strokeBorder(lineWidth: strokeWidth)
                    .foregroundColor(timeRemaining > 10 ? theme.accentColor: .black)
                    .accessibilityHidden(true)

                TimeView(totalSeconds: timeRemaining)
                    .foregroundColor(timeRemaining > 10 ? theme.accentColor: .black)
                    .padding(size * 0.15)

                PlayerArc(startingTime: startingTime, timeRemaining: timeRemaining)
                    .rotation(Angle(degrees: -90))
                    .stroke(timeRemaining > 15 ? theme.mainColor: .red, style: StrokeStyle(lineWidth: arcWidth, lineCap: .round))
                    .padding(strokeWidth / 2)
                    .accessibilityHidden(true)
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(currentPlayer)'s turn")
            .accessibilityValue(timeRemainingDescription(timeRemaining))
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
