//
//  GameModel.swift
//  RumTime
//
//  Created by James Maguire on 08/10/2022.
//

import Foundation

struct Game: Identifiable, Codable {
    let id: UUID
    var name: String
    var startingTime: Int
    var turnBonus: Int
    var players: [Player]
    var rounds: [Round] = []
    
    init(id: UUID = UUID(), name: String, startingTime: Int, turnBonus: Int, players: [Player]) {
        self.id = id
        self.name = name
        self.startingTime = startingTime
        self.turnBonus = turnBonus
        self.players = players
    }
    
    var startingTimeMinutes: Int {
        startingTime / 60
    }
}

extension Game {
    struct Player: Identifiable, Codable {
        let id: UUID
        let name: String
        var theme: Theme
        
        init(id: UUID = UUID(), name: String, theme: Theme) {
            self.id = id
            self.name = name
            self.theme = theme
        }
        
        func totalScore(rounds: [Round]) -> Int {
            var total = 0
            for round in rounds {
                for score in round.scores {
                    if score.player.id == self.id {
                        total += score.score
                    }
                }
            }
            return total
        }
    }
    
    var sortedPlayers: [Player] {
        players.sorted {
            $0.totalScore(rounds: rounds) > $1.totalScore(rounds: rounds)
        }
    }
    
    struct Data {
        var name: String = ""
        var startingTimeMinutes: Double = 0
        var turnBonus: Double = 0
        var players: [Player] = []
        var theme: Theme = .seafoam
    }
    
    var data: Data {
        Data(name: name, startingTimeMinutes: Double(startingTime / 60), turnBonus: Double(turnBonus), players: players)
    }
    
    mutating func update(from data: Data) {
        name =  data.name
        startingTime = Int(data.startingTimeMinutes * 60)
        turnBonus = Int(data.turnBonus)
        players = data.players
    }
    
    mutating func addRound(from round: Round.Data) {
        var total = 0
        var newScores: [Round.Score] = []
        for score in round.scores {
            total += score.score
            newScores.append(Round.Score(player: score.player, score: score.score * (-1)))
        }
        
        for (idx, score) in newScores.enumerated() {
            if score.score == 0 {
                newScores[idx].score = total
            }
        }
        
        rounds.append(Round(date: round.date, scores: newScores))
    }
    
    init(data: Data) {
        id = UUID()
        name = data.name
        startingTime = Int(data.startingTimeMinutes * 60)
        turnBonus = Int(data.turnBonus)
        players = data.players
    }
    
}

extension Game {
    static let sampleData: [Game] =
    [
        Game(
            name: "Long",
            startingTime: 300 ,
            turnBonus: 15,
            players: [
                Player(name: "Luke", theme: .yellow),
                Player(name: "Ludo", theme: .indigo),
                Player(name:"Marcelo", theme: .magenta),
                Player(name: "James", theme: .seafoam)
            ]
        ),
        Game(
            name: "Short",
            startingTime: 6 ,
            turnBonus: 2,
            players: [
                Player(name: "Ludo", theme: .orange),
                Player(name: "Luke", theme: .buttercup),
                Player(name:"Marcelo", theme: .magenta),
                Player(name: "James", theme: .seafoam)
            ]
        )
    ]
}