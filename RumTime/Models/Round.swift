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
        var isWinner: Bool
        
        init(id: UUID = UUID(), player: Game.Player, score: Int, isWinner: Bool = false) {
            self.id = id
            self.player = player
            self.score = score
            self.isWinner = isWinner
        }
    }
    
    struct Data {
        var date: Date = Date()
        var scores: [Score] = []
                
        mutating func setWinner(id: UUID) {
            for (i, s) in scores.enumerated() {
                if id == s.player.id {
                    scores[i].isWinner = true
                    scores[i].score = 0
                } else {
                    scores[i].isWinner = false
                    scores[i].score = 1
                }
            }
        }
        
        var winner: Score {
            if let i = scores.firstIndex(where: { $0.isWinner }) {
                return scores[i]
            }
            return scores[0]
        }
    }
    
    var data: Data {
        Data(date: date, scores: scores)
    }
    
    init(data: Data) {
        id = UUID()
        date = data.date
        scores = data.scores
    }
    
    var winner: Score {
        if let i = scores.firstIndex(where: { $0.isWinner }) {
            return scores[i]
        }
        return scores[0]
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
        Round(scores: [Score(player: Game.Player(name: "James", theme: .grapecompote), score: 10), Score(player: Game.Player(name: "Mark", theme: .grapecompote), score: 10, isWinner: true)])
    ]
}
