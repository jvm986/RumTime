//
//  GameTimer.swift
//  RumTime
//
//  Created by James Maguire on 08/10/2022.
//

import Foundation
import AVFoundation

class RoundTimer: ObservableObject {
    struct Player: Identifiable {
        let id = UUID()
        let name: String
        let theme: Theme
        var secondsRemaining: Double
    }
    
    @Published var turn = 1
    @Published var isPaused = true
    @Published var isActive = false
    @Published var isShowingAlert = false
    @Published var nextPlayer: String
    @Published var activePlayer: String
    @Published var activeTheme: Theme
    @Published var secondsRemainingForTurn: Double = 0
    
    private(set) var startingTime: Int
    private(set) var turnBonus: Int
    private(set) var players: [Player] = []
    
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
    
    private var avPlayer: AVPlayer { AVPlayer.sharedAlarmPlayer }
    
    private var startDate: Date?
    
    init(startingTime: Int = 0, turnBonus: Int = 0, players: [Game.Player] = []) {
        self.startingTime = startingTime
        self.turnBonus = turnBonus
        self.players = players.players
        self.activePlayer = "Active Player"
        self.nextPlayer = "Next Player"
        self.activeTheme = Theme.seafoam
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
        startDate = Date()
        isPaused = false
        isActive = true
        timer = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { [weak self] timer in
            if let self = self, let startDate = self.startDate {
                let secondsElapsed = Date().timeIntervalSince1970 - startDate.timeIntervalSince1970
                self.update(secondsElapsed: Double(secondsElapsed))
            }
        }
    }
    
    private func changeToNextPlayer() {
        if activePlayerIndex == 0 {
            self.turn += 1
        }

        activePlayerIndex = nextPlayerIndex
        activePlayer = players[activePlayerIndex].name
        activeTheme = players[activePlayerIndex].theme
        
        nextPlayer = players[nextPlayerIndex].name
        runTimer()
    }
    
    func update(secondsElapsed: Double) {
        secondsElapsedForTurn = secondsElapsed
        secondsRemainingForTurn = players[activePlayerIndex].secondsRemaining - secondsElapsed
        if players[activePlayerIndex].secondsRemaining - secondsElapsedForTurn <= 0 {
            avPlayer.pause()
            players[activePlayerIndex].secondsRemaining = 0
            secondsElapsedForTurn = 0
            pauseRound()
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
    
    func reset(startingTime: Int, turnBonus: Int, players: [Game.Player], starter: Int) {
        isPaused = true
        isActive = false
        activePlayer = players[starter].name
        activeTheme = players[starter].theme
        if starter + 1 >= players.count {
            nextPlayer = players[0].name
        } else {
            nextPlayer = players[starter + 1].name
        }
        self.startingTime = startingTime
        self.turnBonus = turnBonus
        self.players = players.players
        for idx in 0...self.players.count - 1 {
            self.players[idx].secondsRemaining = Double(startingTime)
        }
    }
}

extension Game {
    var timer: RoundTimer {
        RoundTimer(startingTime: startingTime, turnBonus: turnBonus, players: players)
    }
}

extension Array where Element == Game.Player {
    var players: [RoundTimer.Player] {
        if isEmpty {
            return [RoundTimer.Player(name: "Player 1", theme: .seafoam, secondsRemaining: 0)]
        }
        return map { RoundTimer.Player(name: $0.name, theme: $0.theme, secondsRemaining: 0)}
    }
}
