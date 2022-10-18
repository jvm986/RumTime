//
//  GameTimerView.swift
//  RumTime
//
//  Created by James Maguire on 08/10/2022.
//

import SwiftUI

struct RoundTimerView: View {
    @Binding var game: Game
    @StateObject var roundTimer: RoundTimer
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(roundTimer.secondsRemainingForTurn > 10 ? roundTimer.activeTheme.mainColor: .red)
            VStack {
                GameTimerView(
                    turn: roundTimer.turn,
                    startingTime: roundTimer.startingTime,
                    timeRemaining: roundTimer.secondsRemainingForTurn,
                    currentPlayer: roundTimer.activePlayer,
                    theme: roundTimer.activeTheme
                )
                .padding(.horizontal)
                GameFooterView(
                    turn: roundTimer.turn,
                    nextPlayer: roundTimer.nextPlayer,
                    theme: roundTimer.activeTheme,
                    timeRemaining: roundTimer.secondsRemainingForTurn
                )
            }
            .padding(.top)
        }
        .onTapGesture {
            roundTimer.endTurn()
        }
        .alert("\(roundTimer.activePlayer) pick up 3!", isPresented: $roundTimer.isShowingAlert) {
            Button("OK", role: .cancel) {
                roundTimer.endTurn()
            }
        }
        .padding()
        .interactiveDismissDisabled()
    }
}

struct RoundTimerView_Previews: PreviewProvider {
    static var previews: some View {
        RoundTimerView(game: .constant(Game.sampleData[0]), roundTimer: RoundTimer())
    }
}
