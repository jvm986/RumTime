//
//  Round.swift
//  RumTime
//
//  Created by James Maguire on 14/10/2022.
//

import Foundation

struct Round: Identifiable, Codable {
    let id: UUID
    let date: Date
    var scores: [Score]
    
    init(id: UUID = UUID(), date: Date = Date(), scores: [Score]) {
        self.id = id
        self.date = date
        self.scores = scores
    }
}

extension Round {
    struct Score: Identifiable, Codable {
        let id: UUID
        let player: Game.Player
        var score: Int

        init(id: UUID = UUID(), player: Game.Player, score: Int) {
            self.id = id
            self.player = player
            self.score = score
        }
    }
    
    struct Data {
        var date: Date = Date()
        var scores: [Score] = []
    }
    
    var data: Data {
        Data(date: date, scores: scores)
    }
    
    init(data: Data) {
        id = UUID()
        date = data.date
        scores = data.scores
    }
}

extension Game {
    var scores: [Round.Score] {
        var newScores: [Round.Score] = []
        players.forEach { newScores.insert(Round.Score(player: $0, score: 0), at: 0) }
        return newScores
    }
}

extension Array where Element == Game.Player {
    var scores: [Round.Score] {
        if isEmpty {
            return []
        }
        return map { Round.Score(id: UUID(), player: $0, score: 0)}
    }
}

extension Round {
    static let sampleData: [Round] =
    [
        Round(scores: [Score(player: Game.Player(name: "James", theme: .seafoam), score: 10)])
    ]
}
