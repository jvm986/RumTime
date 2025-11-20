//
//  Score.swift
//  RumTime
//
//  Created by James Maguire on 14/10/2022.
//

import Foundation
import SwiftData

/// Represents a single player's score in a specific round.
@Model
final class Score {
    var id: UUID
    var playerID: UUID
    var playerName: String
    var playerThemeRawValue: String
    var score: Int
    var isWinner: Bool

    /// Parent relationship to the round this score belongs to
    @Relationship(inverse: \Round.scores) var round: Round?

    /// Computed property for theme enum
    var playerTheme: Theme {
        get { Theme(rawValue: playerThemeRawValue) ?? .chive }
        set { playerThemeRawValue = newValue.rawValue }
    }

    init(id: UUID = UUID(), playerID: UUID, playerName: String, playerTheme: Theme, score: Int, isWinner: Bool = false) {
        self.id = id
        self.playerID = playerID
        self.playerName = playerName
        self.playerThemeRawValue = playerTheme.rawValue
        self.score = score
        self.isWinner = isWinner
    }

    /// Convenience initializer from Player
    convenience init(id: UUID = UUID(), player: Player, score: Int, isWinner: Bool = false) {
        self.init(
            id: id,
            playerID: player.id,
            playerName: player.name,
            playerTheme: player.theme,
            score: score,
            isWinner: isWinner
        )
    }
}
