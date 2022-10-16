//
//  GameTimerView.swift
//  RumTime
//
//  Created by James Maguire on 08/10/2022.
//

import SwiftUI

struct RoundTimerView: View {
    @Binding var game: Game
    @StateObject var gameTimer: GameTimer
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(gameTimer.secondsRemainingForTurn > 10 ? gameTimer.activeTheme.mainColor: .red)
            VStack {
                GameTimerView(
                    turn: gameTimer.turn,
                    startingTime: gameTimer.startingTime,
                    timeRemaining: gameTimer.secondsRemainingForTurn,
                    currentPlayer: gameTimer.activePlayer,
                    theme: gameTimer.activeTheme
                )
                    .onTapGesture {
                        gameTimer.endTurn()
                    }
                    .padding(.horizontal)
                GameFooterView(
                    turn: gameTimer.turn,
                    nextPlayer: gameTimer.nextPlayer,
                    theme: gameTimer.activeTheme
                )
            }
            .padding(.top)
        }
        .alert("\(gameTimer.activePlayer) pick up 3!", isPresented: $gameTimer.isShowingAlert) {
            Button("OK", role: .cancel) {
                gameTimer.endTurn()
            }
        }
        .padding()
    }
}

struct RoundTimerView_Previews: PreviewProvider {
    static var previews: some View {
        RoundTimerView(game: .constant(Game.sampleData[0]), gameTimer: GameTimer())
    }
}
