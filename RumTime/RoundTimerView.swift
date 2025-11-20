//
//  GameTimerView.swift
//  RumTime
//
//  Created by James Maguire on 08/10/2022.
//

import SwiftUI
import SwiftData

struct RoundTimerView: View {
    let game: Game
    @Bindable var roundTimer: RoundTimer

    private func timeRemainingDescription(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        if mins > 0 {
            return "\(mins) minute\(mins == 1 ? "" : "s") and \(secs) second\(secs == 1 ? "" : "s") remaining"
        } else {
            return "\(secs) second\(secs == 1 ? "" : "s") remaining"
        }
    }

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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(roundTimer.activePlayer)'s turn")
        .accessibilityValue(timeRemainingDescription(roundTimer.secondsRemainingForTurn))
        .accessibilityHint("Double tap to end turn and move to next player")
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
            roundTimer.endTurn()
        }
        .alert("\(roundTimer.activePlayer)'s time is up!", isPresented: $roundTimer.isShowingAlert) {
            Button("OK", role: .cancel) {
                roundTimer.endTurn()
            }
        }
        .padding()
        .interactiveDismissDisabled()
    }
}

#Preview {
    do {
        let container = try ModelContainer(for: Game.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let game = Game.sampleData[0]
        container.mainContext.insert(game)

        return RoundTimerView(game: game, roundTimer: RoundTimer())
            .modelContainer(container)
    } catch {
        return RoundTimerView(game: Game.sampleData[0], roundTimer: RoundTimer())
    }
}
