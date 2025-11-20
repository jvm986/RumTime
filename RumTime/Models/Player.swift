//
//  Player.swift
//  RumTime
//
//  Created by James Maguire on 08/10/2022.
//

import Foundation
import SwiftData

/// Represents a player in a game session.
///
/// Player tracks individual information and can calculate their cumulative
/// score across all rounds in a game.
@Model
final class Player {
    var id: UUID
    var name: String
    var themeRawValue: String
    var isPaused: Bool

    /// Parent relationship to the game this player belongs to
    @Relationship(inverse: \Game.players) var game: Game?

    /// Computed property for theme enum
    var theme: Theme {
        get { Theme(rawValue: themeRawValue) ?? .chive }
        set { themeRawValue = newValue.rawValue }
    }

    init(id: UUID = UUID(), name: String, theme: Theme, isPaused: Bool = false) {
        self.id = id
        self.name = name
        self.themeRawValue = theme.rawValue
        self.isPaused = isPaused
    }

    /// Calculates the player's total score across all rounds in their game.
    func totalScore() -> Int {
        guard let game = game else { return 0 }
        var total = 0
        for round in game.rounds {
            for score in round.scores {
                if score.playerID == self.id {
                    total += score.score
                }
            }
        }
        return total
    }
}
