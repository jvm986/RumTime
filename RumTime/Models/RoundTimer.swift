//
//  RoundTimer.swift
//  RumTime
//
//  Created by James Maguire on 08/10/2022.
//

import Foundation
import AVFoundation

/// Manages turn-based timing for a game round.
///
/// RoundTimer handles the complex logic of tracking each player's remaining time,
/// rotating turns, applying bonus time, and triggering audio/visual alerts.
/// The timer updates at 100Hz for smooth countdown display and precise timing.
///
/// Key behaviors:
/// - Each player starts with equal time (startingTime)
/// - Players receive bonus time after completing their turn
/// - Audio alert plays when player has 5 seconds remaining
/// - Alert shown when player's time expires
/// - Timer can be paused and resumed mid-round
@MainActor
@Observable
class RoundTimer {
    /// Represents a player in the context of the round timer.
    /// Maintains individual time tracking separate from the Game.Player model.
    struct TimerPlayer: Identifiable {
        let id: UUID
        let name: String
        let theme: Theme
        /// The number of seconds this player has remaining in the round
        var secondsRemaining: Double
    }

    /// Current turn number (increments when returning to first player)
    var turn = 1
    /// Whether the timer is currently paused
    var isPaused = true
    /// Whether a round has been started (even if currently paused)
    var isActive = false
    /// Whether the time-expired alert is being shown to the user
    var isShowingAlert = false
    /// Name of the player who will play next
    var nextPlayer: String
    /// Name of the currently active player
    var activePlayer: String
    /// Full player object for the currently active player
    var activePlayerObj: TimerPlayer
    /// Theme color for the currently active player
    var activeTheme: Theme
    /// Seconds remaining for the current player's turn (updates at 100Hz)
    var secondsRemainingForTurn: Double = 0

    private(set) var startingTime: Int
    private(set) var turnBonus: Int
    private(set) var players: [TimerPlayer] = []

    var playerChangedAction: (() -> Void)?

    private var timer: Timer?
    private var frequency: TimeInterval { 1.0 / 100.0 }
    private var secondsElapsedForTurn: Double = 0

    private var activePlayerIndex: Int = 0
    private var nextPlayerIndex: Int {
        if activePlayerIndex < players.count - 1 {
            return activePlayerIndex + 1
        }
        return 0
    }

    @MainActor
    private var avPlayer: AVPlayer { AVPlayer.sharedAlarmPlayer }

    private var startDate: Date?

    init(startingTime: Int = 0, turnBonus: Int = 0, players: [Player] = []) {
        self.startingTime = startingTime
        self.turnBonus = turnBonus
        self.players = players.timerPlayers
        self.activePlayer = "Active Player"
        self.activePlayerObj = TimerPlayer(id: UUID(), name: "Active Player", theme: .chive, secondsRemaining: 0)
        self.nextPlayer = "Next Player"
        self.activeTheme = Theme.chive
    }

    func startRound() {
        runTimer()
    }

    func stopRound() {
        timer?.invalidate()
        timer = nil
        avPlayer.pause()
        isActive = false
    }

    /// Ends the current player's turn and advances to the next player.
    ///
    /// This method:
    /// 1. Deducts elapsed time from the current player's remaining time
    /// 2. Applies the turn bonus (or resets to bonus time if player ran out)
    /// 3. Resets the elapsed time counter
    /// 4. Advances to the next player and restarts the timer
    func endTurn() {
        timer?.invalidate()
        timer = nil
        avPlayer.pause()
        players[activePlayerIndex].secondsRemaining -= secondsElapsedForTurn
        if players[activePlayerIndex].secondsRemaining > 0 {
            players[activePlayerIndex].secondsRemaining += Double(turnBonus)
        } else {
            players[activePlayerIndex].secondsRemaining = Double(turnBonus)
        }
        secondsElapsedForTurn = 0
        changeToNextPlayer()
    }

    private func runTimer() {
        Task { @MainActor in
            startDate = Date()
            isPaused = false
            isActive = true
        }
        timer = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            Task { @MainActor in
                if let startDate = self.startDate {
                    let secondsElapsed = Date().timeIntervalSince(startDate)
                    self.update(secondsElapsed: secondsElapsed)
                }
            }
        }
    }

    private func changeToNextPlayer() {
        if activePlayerIndex == 0 {
            self.turn += 1
        }

        activePlayerIndex = nextPlayerIndex
        activePlayer = players[activePlayerIndex].name
        activePlayerObj = players[activePlayerIndex]
        activeTheme = players[activePlayerIndex].theme

        nextPlayer = players[nextPlayerIndex].name
        runTimer()
    }

    /// Updates the timer display based on elapsed time.
    ///
    /// Called at 100Hz frequency to provide smooth countdown updates.
    /// Triggers audio alert at 5 seconds remaining and stops timer when time expires.
    ///
    /// - Parameter secondsElapsed: Time elapsed since the current turn started
    func update(secondsElapsed: Double) {
        secondsElapsedForTurn = secondsElapsed
        secondsRemainingForTurn = players[activePlayerIndex].secondsRemaining - secondsElapsed
        if players[activePlayerIndex].secondsRemaining - secondsElapsedForTurn <= 0 {
            avPlayer.pause()
            players[activePlayerIndex].secondsRemaining = 0
            secondsElapsedForTurn = 0
            timer?.invalidate()
            timer = nil
            isShowingAlert = true
        } else if players[activePlayerIndex].secondsRemaining - secondsElapsedForTurn <= 5 {
            if avPlayer.timeControlStatus != .playing {
                avPlayer.seek(to: .zero)
                avPlayer.play()
            }
        }
    }

    func pauseRound() {
        isPaused = true
        players[activePlayerIndex].secondsRemaining -= secondsElapsedForTurn
        secondsElapsedForTurn = 0
        timer?.invalidate()
        timer = nil
        avPlayer.pause()
    }

    func unpauseGame() {
        isPaused = false
        runTimer()
    }

    /// Resets the timer to prepare for a new round.
    ///
    /// Initializes all players with the starting time and sets the active player
    /// to the specified starter. This should be called before starting a new round
    /// or when game settings change (e.g., player pause status).
    ///
    /// - Parameters:
    ///   - startingTime: Initial time in seconds for each player
    ///   - turnBonus: Bonus seconds added after each player's turn
    ///   - players: Array of players participating in the round
    ///   - starter: Index of the player who will start the round
    func reset(startingTime: Int, turnBonus: Int, players: [Player], starter: Int) {
        isPaused = true
        isActive = false
        activePlayerIndex = starter
        activePlayer = players[starter].name
        activePlayerObj = TimerPlayer(id: players[starter].id, name: players[starter].name, theme: players[starter].theme, secondsRemaining: 0)
        activeTheme = players[starter].theme
        if starter + 1 >= players.count {
            nextPlayer = players[0].name
        } else {
            nextPlayer = players[starter + 1].name
        }
        self.startingTime = startingTime
        self.turnBonus = turnBonus
        self.players = players.timerPlayers
        for idx in 0...self.players.count - 1 {
            self.players[idx].secondsRemaining = Double(startingTime)
        }
    }
}

extension Game {
    @MainActor
    var timer: RoundTimer {
        RoundTimer(startingTime: startingTime, turnBonus: turnBonus, players: players)
    }
}

extension Array where Element == Player {
    var timerPlayers: [RoundTimer.TimerPlayer] {
        if isEmpty {
            return [RoundTimer.TimerPlayer(id: UUID(), name: "Player 1", theme: .chive, secondsRemaining: 0)]
        }
        return map { RoundTimer.TimerPlayer(id: $0.id, name: $0.name, theme: $0.theme, secondsRemaining: 0)}
    }
}
