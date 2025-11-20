//
//  Round.swift
//  RumTime
//
//  Created by James Maguire on 14/10/2022.
//

import Foundation
import SwiftData

/// Represents a completed round in a game session.
@Model
final class Round {
    var id: UUID
    var date: Date

    /// Relationship to scores in this round
    @Relationship(deleteRule: .cascade) var scores: [Score]

    /// Parent relationship to the game this round belongs to
    @Relationship(inverse: \Game.rounds) var game: Game?

    init(id: UUID = UUID(), date: Date = Date(), scores: [Score] = []) {
        self.id = id
        self.date = date
        self.scores = scores
    }

    /// Returns the winning score entry for this round.
    var winner: Score {
        scores.first(where: { $0.isWinner }) ?? scores[0]
    }

    /// Data transfer object for round creation/editing.
    struct Data {
        var date: Date = Date()
        var scores: [ScoreData] = []

        /// Sets the winner and adjusts scores accordingly.
        mutating func setWinner(id: UUID) {
            for i in scores.indices {
                if id == scores[i].playerID {
                    scores[i].isWinner = true
                    scores[i].score = 0
                } else {
                    scores[i].isWinner = false
                    scores[i].score = 1
                }
            }
        }

        var winner: ScoreData {
            scores.first(where: { $0.isWinner }) ?? scores[0]
        }

        /// Temporary data structure for scores before persistence
        struct ScoreData: Identifiable {
            var id: UUID = UUID()
            var playerID: UUID
            var playerName: String
            var playerTheme: Theme
            var score: Int
            var isWinner: Bool

            init(id: UUID = UUID(), player: Player, score: Int, isWinner: Bool = false) {
                self.id = id
                self.playerID = player.id
                self.playerName = player.name
                self.playerTheme = player.theme
                self.score = score
                self.isWinner = isWinner
            }

            /// Convert to persistent Score model
            func toScore() -> Score {
                Score(
                    id: id,
                    playerID: playerID,
                    playerName: playerName,
                    playerTheme: playerTheme,
                    score: score,
                    isWinner: isWinner
                )
            }
        }
    }

    /// Creates a Data object from this Round for editing.
    var data: Data {
        Data(
            date: date,
            scores: scores.map { score in
                Data.ScoreData(
                    id: score.id,
                    player: Player(
                        id: score.playerID,
                        name: score.playerName,
                        theme: score.playerTheme
                    ),
                    score: score.score,
                    isWinner: score.isWinner
                )
            }
        )
    }
}

// Sample data for previews and testing
extension Round {
    static let sampleData: [Round] = [
        Round(
            scores: [
                Score(playerID: UUID(), playerName: "James", playerTheme: .grapecompote, score: 10),
                Score(playerID: UUID(), playerName: "Mark", playerTheme: .saffron, score: 10, isWinner: true)
            ]
        )
    ]
}
