//
//  Game.swift
//  RumTime
//
//  Created by James Maguire on 08/10/2022.
//

import Foundation
import SwiftData

/// Represents a game session with multiple players and round history.
///
/// A Game tracks all the configuration and state for a Rummy/Rummikub session,
/// including player roster, timing settings, and complete round history.
/// Games are persisted using SwiftData and can be resumed across app launches.
@Model
final class Game {
    var id: UUID
    var name: String
    var startingTime: Int
    var turnBonus: Int
    var starter: Int
    var themeRawValue: String

    @Relationship(deleteRule: .cascade) var players: [Player]
    @Relationship(deleteRule: .cascade) var rounds: [Round]

    var theme: Theme {
        get { Theme(rawValue: themeRawValue) ?? .chive }
        set { themeRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        name: String,
        startingTime: Int,
        turnBonus: Int,
        players: [Player] = [],
        starter: Int = 0,
        rounds: [Round] = [],
        theme: Theme = .chive
    ) {
        self.id = id
        self.name = name
        self.startingTime = startingTime
        self.turnBonus = turnBonus
        self.players = players
        self.starter = starter
        self.rounds = rounds
        self.themeRawValue = theme.rawValue
    }

    var startingTimeString: String {
        String(format: "%02i:%02i", startingTime / 60 % 60, startingTime % 60)
    }

    /// Returns the index in unpausedPlayers array corresponding to the starter.
    var unpausedStarter: Int {
        for (idx, p) in players.enumerated() {
            if idx == starter {
                for (idx, up) in unpausedPlayers.enumerated() {
                    if p.id == up.id {
                        return idx
                    }
                }
            }
        }
        return 0
    }

    /// Returns players sorted by their total score (highest first).
    var sortedPlayers: [Player] {
        players.sorted(by: { $0.totalScore() > $1.totalScore() })
    }

    /// Returns only players who are not paused.
    var unpausedPlayers: [Player] {
        players.filter { !$0.isPaused }
    }

    /// Records a completed round and updates game state.
    ///
    /// This method:
    /// 1. Inverts loser scores (positive input becomes negative)
    /// 2. Awards winner the sum of all loser scores
    /// 3. Inserts round at the beginning of history (newest first)
    /// 4. Advances starter to the next unpaused player
    ///
    /// - Parameter roundData: Round data containing scores and winner information
    func addRound(from roundData: Round.Data) {
        var total = 0
        var newScores: [Score] = []

        for scoreData in roundData.scores {
            total += scoreData.score
            newScores.append(
                Score(
                    playerID: scoreData.playerID,
                    playerName: scoreData.playerName,
                    playerTheme: scoreData.playerTheme,
                    score: scoreData.score * (-1),
                    isWinner: scoreData.isWinner
                )
            )
        }

        for idx in newScores.indices {
            if newScores[idx].isWinner {
                newScores[idx].score = total
            }
        }

        let round = Round(date: roundData.date, scores: newScores)
        rounds.insert(round, at: 0)
        starter = nextUnpausedPlayer(current: starter)
    }

    /// Toggles a player's paused state, if allowed.
    ///
    /// Players can sit out by being paused. However, at least 2 players
    /// must remain active (unpaused) for the game to function.
    /// If toggling would leave fewer than 2 active players, the operation
    /// is prevented by forcing isPaused to false.
    ///
    /// If the current starter is paused, the starter advances to the next
    /// unpaused player automatically.
    ///
    /// - Parameter id: UUID of the player whose pause state should toggle
    func togglePausedPlayer(id: UUID) {
        // We don't want to pause a player if it means there will be less
        // than 2 players left
        if players.filter({ !$0.isPaused }).count < 3 {
            for player in players where player.id == id {
                player.isPaused = false
                return
            }
        }

        for (idx, player) in players.enumerated() where player.id == id {
            player.isPaused.toggle()
            if idx == starter {
                starter = nextUnpausedPlayer(current: starter)
            }
        }
    }

    private func nextUnpausedPlayer(current: Int) -> Int {
        for (idx, player) in players.enumerated() {
            if !player.isPaused && idx > current {
                return idx
            }
            if !player.isPaused && idx + 1 > players.count {
                if let new = players.firstIndex(where: { !$0.isPaused }) {
                    return new
                }
            }
        }
        return 0
    }

    /// Data transfer object for game creation/editing.
    struct Data {
        var name: String = ""
        var startingTime: Double = 60
        var turnBonus: Double = 3
        var players: [PlayerData] = []
        var theme: Theme = .saffron
        var starter = 0

        var randomTheme: Theme {
            var cases = Theme.allCases
            for p in players {
                cases.removeAll { $0 == p.theme }
            }
            return cases.randomElement() ?? Theme.chive
        }

        /// Temporary data structure for players before persistence
        struct PlayerData: Identifiable {
            var id: UUID = UUID()
            var name: String
            var theme: Theme
            var isPaused: Bool = false

            /// Convert to persistent Player model
            func toPlayer() -> Player {
                Player(id: id, name: name, theme: theme, isPaused: isPaused)
            }
        }
    }

    /// Creates a Data object from this Game for editing.
    var data: Data {
        Data(
            name: name,
            startingTime: Double(startingTime),
            turnBonus: Double(turnBonus),
            players: players.map { Data.PlayerData(id: $0.id, name: $0.name, theme: $0.theme, isPaused: $0.isPaused) },
            theme: theme,
            starter: starter
        )
    }

    /// Updates this game from a Data object.
    func update(from data: Data) {
        name = data.name
        startingTime = Int(data.startingTime)
        turnBonus = Int(data.turnBonus)
        theme = data.theme

        // Update existing players or create new ones
        var updatedPlayers: [Player] = []
        for playerData in data.players {
            if let existingPlayer = players.first(where: { $0.id == playerData.id }) {
                existingPlayer.name = playerData.name
                existingPlayer.theme = playerData.theme
                existingPlayer.isPaused = playerData.isPaused
                updatedPlayers.append(existingPlayer)
            } else {
                updatedPlayers.append(playerData.toPlayer())
            }
        }
        players = updatedPlayers
        starter = data.starter
    }

    /// Convenience initializer from Data object.
    convenience init(data: Data) {
        self.init(
            id: UUID(),
            name: data.name,
            startingTime: Int(data.startingTime),
            turnBonus: Int(data.turnBonus),
            players: data.players.map { $0.toPlayer() },
            starter: data.starter,
            theme: data.theme
        )
    }
}

// Helper extensions
extension Game {
    /// Creates score entries for all unpaused players.
    func createScores() -> [Round.Data.ScoreData] {
        unpausedPlayers.map { Round.Data.ScoreData(player: $0, score: 0) }
    }
}

extension Array where Element == Player {
    /// Creates score entries from an array of players.
    var scores: [Round.Data.ScoreData] {
        if isEmpty {
            return []
        }
        return map { Round.Data.ScoreData(id: UUID(), player: $0, score: 0) }
    }
}

// Sample data for previews and testing
extension Game {
    static let sampleData: [Game] = [
        Game(
            name: "Long",
            startingTime: 300,
            turnBonus: 15,
            players: [
                Player(name: "Luke", theme: .saffron),
                Player(name: "Ludo", theme: .orangepeel),
                Player(name: "Marcelo", theme: .chive),
                Player(name: "James", theme: .navyblazer)
            ],
            rounds: [
                Round(scores: [
                    Score(playerID: UUID(), playerName: "Luke", playerTheme: .saffron, score: 10, isWinner: true)
                ])
            ],
            theme: .coralpink
        ),
        Game(
            name: "Short",
            startingTime: 6,
            turnBonus: 2,
            players: [
                Player(name: "Ludo", theme: .grapecompote),
                Player(name: "Luke", theme: .coralpink),
                Player(name: "Marcelo", theme: .classicblue),
                Player(name: "James", theme: .saffron)
            ],
            rounds: [
                Round(scores: [
                    Score(playerID: UUID(), playerName: "Luke", playerTheme: .saffron, score: 10, isWinner: true)
                ])
            ],
            theme: .ash
        )
    ]
}
