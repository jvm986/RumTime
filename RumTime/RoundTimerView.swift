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
    var onPause: (() -> Void)?
    var onEnd: (() -> Void)?

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
        NavigationStack {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(roundTimer.secondsRemainingForTurn > 10 ? roundTimer.activeTheme.mainColor: .red)
                VStack {
                    Spacer()

                    GameTimerView(
                        turn: roundTimer.turn,
                        startingTime: roundTimer.startingTime,
                        timeRemaining: roundTimer.secondsRemainingForTurn,
                        currentPlayer: roundTimer.activePlayer,
                        theme: roundTimer.activeTheme
                    )
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal, 40)

                    Spacer()

                    GameFooterView(
                        turn: roundTimer.turn,
                        nextPlayer: roundTimer.nextPlayer,
                        theme: roundTimer.activeTheme,
                        timeRemaining: roundTimer.secondsRemainingForTurn
                    )
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(roundTimer.activePlayer)'s turn")
            .accessibilityValue(timeRemainingDescription(roundTimer.secondsRemainingForTurn))
            .accessibilityHint("Tap to end turn and move to next player")
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
            .navigationTitle(roundTimer.activePlayer)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Pause Round") {
                        onPause?()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("End Round") {
                        onEnd?()
                    }
                    .accessibilityIdentifier("End Round")
                }
            }
        }
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
