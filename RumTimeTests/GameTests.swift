//
//  GameTests.swift
//  RumTimeTests
//
//  Created by James Maguire on 18/11/2025.
//

import XCTest
import SwiftData
@testable import RumTime

@MainActor
final class GameTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var game: Game!

    override func setUp() {
        super.setUp()

        // Create in-memory container for testing
        let schema = Schema([Game.self, Player.self, Round.self, Score.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: schema, configurations: [config])
        modelContext = modelContainer.mainContext

        // Create a test game with sample players
        let player1 = Player(name: "Alice", theme: .saffron)
        let player2 = Player(name: "Bob", theme: .chive)
        let player3 = Player(name: "Charlie", theme: .navyblazer)

        game = Game(name: "Test Game", startingTime: 60, turnBonus: 10, players: [player1, player2, player3])
        modelContext.insert(game)
    }

    override func tearDown() {
        game = nil
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testGameInitialization() {
        XCTAssertEqual(game.name, "Test Game")
        XCTAssertEqual(game.startingTime, 60)
        XCTAssertEqual(game.turnBonus, 10)
        XCTAssertEqual(game.players.count, 3)
        XCTAssertEqual(game.rounds.count, 0)
        XCTAssertEqual(game.starter, 0)
    }

    func testGameFromData() {
        var data = Game.Data()
        data.name = "Data Game"
        data.startingTime = 120
        data.turnBonus = 15
        data.players = [
            Game.Data.PlayerData(name: "Player 1", theme: .coralpink)
        ]

        let newGame = Game(data: data)
        XCTAssertEqual(newGame.name, "Data Game")
        XCTAssertEqual(newGame.startingTime, 120)
        XCTAssertEqual(newGame.turnBonus, 15)
        XCTAssertEqual(newGame.players.count, 1)
    }

    // MARK: - Player Management Tests

    func testUnpausedPlayers() {
        XCTAssertEqual(game.unpausedPlayers.count, 3)

        // Pause one player
        game.players[0].isPaused = true
        XCTAssertEqual(game.unpausedPlayers.count, 2)
        XCTAssertFalse(game.unpausedPlayers.contains(where: { $0.name == "Alice" }))
    }

    func testTogglePausedPlayer() {
        let playerId = game.players[0].id

        // Initially not paused
        XCTAssertFalse(game.players[0].isPaused)

        // Toggle to paused
        game.togglePausedPlayer(id: playerId)
        XCTAssertTrue(game.players[0].isPaused)

        // Toggle back to active
        game.togglePausedPlayer(id: playerId)
        XCTAssertFalse(game.players[0].isPaused)
    }

    func testCannotPauseBelowTwoPlayers() {
        // Pause first player - leaves 2 active
        game.togglePausedPlayer(id: game.players[0].id)
        XCTAssertTrue(game.players[0].isPaused)
        XCTAssertEqual(game.unpausedPlayers.count, 2, "Should have 2 active players")

        // Try to pause second player - should fail (would leave only 1 active)
        game.togglePausedPlayer(id: game.players[1].id)
        XCTAssertFalse(game.players[1].isPaused, "Should not allow pausing when it would leave fewer than 2 active players")
        XCTAssertEqual(game.unpausedPlayers.count, 2, "Should still have 2 active players")
    }

    // MARK: - Round Management Tests

    func testAddRound() {
        var roundData = Round.Data()
        roundData.scores = [
            Round.Data.ScoreData(player: game.players[0], score: 10, isWinner: false),
            Round.Data.ScoreData(player: game.players[1], score: 20, isWinner: false),
            Round.Data.ScoreData(player: game.players[2], score: 0, isWinner: true)
        ]

        game.addRound(from: roundData)

        XCTAssertEqual(game.rounds.count, 1)

        // Winner should have total of losers' scores
        let winnerScore = game.rounds[0].scores.first(where: { $0.isWinner })
        XCTAssertEqual(winnerScore?.score, 30) // 10 + 20

        // Losers should have negative scores
        let loserScores = game.rounds[0].scores.filter { !$0.isWinner }
        XCTAssertTrue(loserScores.allSatisfy { $0.score < 0 })
    }

    func testSortedPlayers() {
        // Add some rounds with scores
        var round1 = Round.Data()
        round1.scores = [
            Round.Data.ScoreData(player: game.players[0], score: 10, isWinner: false),
            Round.Data.ScoreData(player: game.players[1], score: 20, isWinner: false),
            Round.Data.ScoreData(player: game.players[2], score: 0, isWinner: true)
        ]
        game.addRound(from: round1)

        let sorted = game.sortedPlayers

        // Charlie (winner) should be first with 30 points
        XCTAssertEqual(sorted[0].name, "Charlie")
        XCTAssertEqual(sorted[0].totalScore(), 30)

        // Bob should be last with -20 points
        XCTAssertEqual(sorted[2].name, "Bob")
        XCTAssertEqual(sorted[2].totalScore(), -20)
    }

    // MARK: - Update Tests

    func testUpdateFromData() {
        var data = game.data
        data.name = "Updated Name"
        data.startingTime = 90
        data.turnBonus = 20

        game.update(from: data)

        XCTAssertEqual(game.name, "Updated Name")
        XCTAssertEqual(game.startingTime, 90)
        XCTAssertEqual(game.turnBonus, 20)
    }

    // MARK: - SwiftData Persistence Tests

    func testGamePersistence() throws {
        // Save context
        try modelContext.save()

        // Create new context to verify persistence
        let newContext = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<Game>()
        let fetchedGames = try newContext.fetch(descriptor)

        XCTAssertEqual(fetchedGames.count, 1)
        XCTAssertEqual(fetchedGames[0].name, "Test Game")
        XCTAssertEqual(fetchedGames[0].players.count, 3)
    }
}
