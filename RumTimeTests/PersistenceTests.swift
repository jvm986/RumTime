//
//  PersistenceTests.swift
//  RumTimeTests
//
//  Created by James Maguire on 20/11/2025.
//

import XCTest
import SwiftData
@testable import RumTime

@MainActor
final class PersistenceTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() {
        super.setUp()

        // Create in-memory container for testing
        let schema = Schema([Game.self, Player.self, Round.self, Score.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: schema, configurations: [config])
        modelContext = modelContainer.mainContext
    }

    override func tearDown() {
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }

    // MARK: - Basic Persistence Tests

    func testInsertGame() throws {
        let player1 = Player(name: "Alice", theme: .saffron)
        let player2 = Player(name: "Bob", theme: .chive)

        let game = Game(
            name: "Test Game",
            startingTime: 60,
            turnBonus: 10,
            players: [player1, player2]
        )

        modelContext.insert(game)
        try modelContext.save()

        let descriptor = FetchDescriptor<Game>()
        let games = try modelContext.fetch(descriptor)

        XCTAssertEqual(games.count, 1)
        XCTAssertEqual(games[0].name, "Test Game")
        XCTAssertEqual(games[0].players.count, 2)
    }

    func testDeleteGame() throws {
        let game = Game(
            name: "To Delete",
            startingTime: 60,
            turnBonus: 10,
            players: [Player(name: "Player", theme: .saffron)]
        )

        modelContext.insert(game)
        try modelContext.save()

        // Verify it exists
        var descriptor = FetchDescriptor<Game>()
        var games = try modelContext.fetch(descriptor)
        XCTAssertEqual(games.count, 1)

        // Delete it
        modelContext.delete(game)
        try modelContext.save()

        // Verify it's gone
        descriptor = FetchDescriptor<Game>()
        games = try modelContext.fetch(descriptor)
        XCTAssertEqual(games.count, 0)
    }

    func testCascadeDeletePlayers() throws {
        let player = Player(name: "Player", theme: .saffron)
        let game = Game(
            name: "Cascade Test",
            startingTime: 60,
            turnBonus: 10,
            players: [player]
        )

        modelContext.insert(game)
        try modelContext.save()

        // Verify player exists
        var playerDescriptor = FetchDescriptor<Player>()
        var players = try modelContext.fetch(playerDescriptor)
        XCTAssertEqual(players.count, 1)

        // Delete game
        modelContext.delete(game)
        try modelContext.save()

        // Verify player is also deleted (cascade)
        playerDescriptor = FetchDescriptor<Player>()
        players = try modelContext.fetch(playerDescriptor)
        XCTAssertEqual(players.count, 0, "Players should be deleted when game is deleted")
    }

    // MARK: - Round Persistence Tests

    func testAddRoundPersistence() throws {
        let player1 = Player(name: "Alice", theme: .saffron)
        let player2 = Player(name: "Bob", theme: .chive)

        let game = Game(
            name: "Round Test",
            startingTime: 60,
            turnBonus: 10,
            players: [player1, player2]
        )

        modelContext.insert(game)
        try modelContext.save()

        // Add a round
        var roundData = Round.Data()
        roundData.scores = [
            Round.Data.ScoreData(player: player1, score: 10, isWinner: false),
            Round.Data.ScoreData(player: player2, score: 0, isWinner: true)
        ]
        game.addRound(from: roundData)
        try modelContext.save()

        // Fetch and verify
        let descriptor = FetchDescriptor<Game>()
        let games = try modelContext.fetch(descriptor)

        XCTAssertEqual(games[0].rounds.count, 1)
        XCTAssertEqual(games[0].rounds[0].scores.count, 2)
    }

    // MARK: - Query Tests

    func testFetchWithPredicate() throws {
        let game1 = Game(name: "Alpha", startingTime: 60, turnBonus: 10, players: [Player(name: "P1", theme: .saffron)])
        let game2 = Game(name: "Beta", startingTime: 120, turnBonus: 15, players: [Player(name: "P2", theme: .chive)])

        modelContext.insert(game1)
        modelContext.insert(game2)
        try modelContext.save()

        // Fetch games with starting time = 60
        let descriptor = FetchDescriptor<Game>(predicate: #Predicate { $0.startingTime == 60 })
        let games = try modelContext.fetch(descriptor)

        XCTAssertEqual(games.count, 1)
        XCTAssertEqual(games[0].name, "Alpha")
    }

    func testFetchSorted() throws {
        let game1 = Game(name: "Zebra", startingTime: 60, turnBonus: 10, players: [Player(name: "P1", theme: .saffron)])
        let game2 = Game(name: "Alpha", startingTime: 60, turnBonus: 10, players: [Player(name: "P2", theme: .chive)])

        modelContext.insert(game1)
        modelContext.insert(game2)
        try modelContext.save()

        // Fetch sorted by name
        let descriptor = FetchDescriptor<Game>(sortBy: [SortDescriptor(\.name)])
        let games = try modelContext.fetch(descriptor)

        XCTAssertEqual(games.count, 2)
        XCTAssertEqual(games[0].name, "Alpha")
        XCTAssertEqual(games[1].name, "Zebra")
    }

    // MARK: - Concurrent Access Tests

    func testMultipleContexts() throws {
        // Insert in first context
        let game = Game(
            name: "Multi Context",
            startingTime: 60,
            turnBonus: 10,
            players: [Player(name: "Player", theme: .saffron)]
        )

        modelContext.insert(game)
        try modelContext.save()

        // Fetch from second context
        let secondContext = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<Game>()
        let games = try secondContext.fetch(descriptor)

        XCTAssertEqual(games.count, 1)
        XCTAssertEqual(games[0].name, "Multi Context")
    }
}
