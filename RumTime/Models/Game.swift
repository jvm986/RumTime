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
    var starter: Int
    
    init(id: UUID = UUID(), name: String, startingTime: Int, turnBonus: Int, players: [Player], starter: Int = 0, rounds: [Round] = []) {
        self.id = id
        self.name = name
        self.startingTime = startingTime
        self.turnBonus = turnBonus
        self.players = players
        self.starter = starter
        self.rounds = rounds
    }
    
    var startingTimeString: String {
        String(format: "%02i:%02i", startingTime / 60 % 60, startingTime % 60)
    }
}

extension Game {
    struct Player: Identifiable, Codable {
        let id: UUID
        let name: String
        var theme: Theme
        var isPaused: Bool
        
        init(id: UUID = UUID(), name: String, theme: Theme, isPaused: Bool = false) {
            self.id = id
            self.name = name
            self.theme = theme
            self.isPaused = isPaused
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
        var startingTime: Double = 0
        var turnBonus: Double = 0
        var players: [Player] = []
        var theme: Theme = .saffron
        var starter = 0
        
        var randomTheme: Theme {
            var cases = Theme.allCases
            for p in players {
                for (idx, _) in cases.enumerated() {
                    if p.theme == cases[idx] {
                        cases.remove(at: idx)
                        break
                    }
                }
            }
            return cases.randomElement() ?? Theme.chive
        }
    }
    
    var data: Data {
        Data(name: name, startingTime: Double(startingTime), turnBonus: Double(turnBonus), players: players, starter: starter)
    }
    
    mutating func update(from data: Data) {
        name =  data.name
        startingTime = Int(data.startingTime)
        turnBonus = Int(data.turnBonus)
        players = data.players
        starter = data.starter
    }
    
    mutating func addRound(from round: Round.Data) {
        var total = 0
        var newScores: [Round.Score] = []
        for score in round.scores {
            total += score.score
            newScores.append(Round.Score(player: score.player, score: score.score * (-1), isWinner: score.isWinner))
        }
        
        for (idx, score) in newScores.enumerated() {
            if score.score == 0 {
                newScores[idx].score = total
            }
        }
        
        rounds.insert(Round(date: round.date, scores: newScores), at: 0)
        
        if starter + 1 >= players.count {
            starter = 0
        } else {
            starter += 1
        }
        
    }
    
    init(data: Data) {
        id = UUID()
        name = data.name
        startingTime = Int(data.startingTime)
        turnBonus = Int(data.turnBonus)
        players = data.players
        starter = data.starter
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
                Player(name: "Luke", theme: .saffron),
                Player(name: "Ludo", theme: .orangepeel),
                Player(name:"Marcelo", theme: .chive),
                Player(name: "James", theme: .navyblazer)
            ],
            rounds: [
                Round(scores: [Round.Score(player: Player(name: "Luke", theme: .saffron), score: 10, isWinner: true)])
            ]
        ),
        Game(
            name: "Short",
            startingTime: 6 ,
            turnBonus: 2,
            players: [
                Player(name: "Ludo", theme: .grapecompote),
                Player(name: "Luke", theme: .coralpink),
                Player(name:"Marcelo", theme: .classicblue),
                Player(name: "James", theme: .saffron)
            ],
            rounds: [
                Round(scores: [Round.Score(player: Player(name: "Luke", theme: .saffron), score: 10, isWinner: true)])
            ]
        )
    ]
}
