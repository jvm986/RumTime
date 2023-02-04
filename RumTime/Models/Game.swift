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
        get {
            players.sorted(by: { $0.totalScore(rounds: rounds) > $1.totalScore(rounds: rounds) })
        }
        set {
            players = newValue
        }
    }
    
    var unpausedPlayers: [Player] {
        get {
            players.filter({ !$0.isPaused })
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
            if score.isWinner {
                newScores[idx].score = total
            }
        }
        
        rounds.insert(Round(date: round.date, scores: newScores), at: 0)
        starter = nextUnpausedPlayer(players: players, current: starter)
    }
    
    mutating func togglePausedPlayer(id: UUID) {
        // We don't want to pause a player if it means there will be less
        // than 2 players left
        if players.filter({ !$0.isPaused }).count < 3 {
            for (idx, p) in players.enumerated() {
                if p.id == id {
                    players[idx].isPaused = false
                    return
                }
            }
        }
        for (idx, p) in players.enumerated() {
            if p.id == id {
                players[idx].isPaused.toggle()
                if idx == starter {
                    starter = nextUnpausedPlayer(players: players, current: starter)
                }
            }
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

func nextUnpausedPlayer(players: [Game.Player], current: Int) -> Int {
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
