//
//  RoundTimerTests.swift
//  RumTimeTests
//
//  Created by James Maguire on 18/11/2025.
//

import XCTest
@testable import RumTime

@MainActor
final class RoundTimerTests: XCTestCase {

    var timer: RoundTimer!
    var testPlayers: [Player]!

    override func setUp() async throws {
        try await super.setUp()
        testPlayers = [
            Player(name: "Alice", theme: .saffron),
            Player(name: "Bob", theme: .chive),
            Player(name: "Charlie", theme: .navyblazer)
        ]
        timer = RoundTimer(startingTime: 60, turnBonus: 10, players: testPlayers)
    }

    override func tearDown() async throws {
        timer.stopRound()
        timer = nil
        testPlayers = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testTimerInitialization() {
        XCTAssertEqual(timer.startingTime, 60)
        XCTAssertEqual(timer.turnBonus, 10)
        XCTAssertEqual(timer.players.count, 3)
        XCTAssertTrue(timer.isPaused)
        XCTAssertFalse(timer.isActive)
        XCTAssertEqual(timer.turn, 1)
    }

    // MARK: - Reset Tests

    func testReset() {
        timer.reset(startingTime: 120, turnBonus: 15, players: testPlayers, starter: 1)

        XCTAssertEqual(timer.startingTime, 120)
        XCTAssertEqual(timer.turnBonus, 15)
        XCTAssertEqual(timer.activePlayer, "Bob")
        XCTAssertEqual(timer.nextPlayer, "Charlie")
        XCTAssertTrue(timer.isPaused)
        XCTAssertFalse(timer.isActive)

        // Check all players have starting time
        for player in timer.players {
            XCTAssertEqual(player.secondsRemaining, 120.0)
        }
    }

    func testResetWithLastPlayerAsStarter() {
        timer.reset(startingTime: 60, turnBonus: 10, players: testPlayers, starter: 2)

        XCTAssertEqual(timer.activePlayer, "Charlie")
        XCTAssertEqual(timer.nextPlayer, "Alice", "Should wrap to first player")
    }

    // MARK: - Round Lifecycle Tests

    func testStartRound() async {
        timer.reset(startingTime: 60, turnBonus: 10, players: testPlayers, starter: 0)
        timer.startRound()

        // Give a moment for the Task in runTimer to execute
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds

        XCTAssertFalse(timer.isPaused)
        XCTAssertTrue(timer.isActive)
    }

    func testPauseRound() async {
        timer.reset(startingTime: 60, turnBonus: 10, players: testPlayers, starter: 0)
        timer.startRound()

        // Let timer run briefly
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        timer.pauseRound()

        XCTAssertTrue(timer.isPaused)
        XCTAssertTrue(timer.isActive, "Should remain active even when paused")

        // Time should have been deducted
        XCTAssertLessThan(timer.players[0].secondsRemaining, 60.0)
    }

    func testUnpauseGame() async {
        timer.reset(startingTime: 60, turnBonus: 10, players: testPlayers, starter: 0)
        timer.startRound()
        timer.pauseRound()

        XCTAssertTrue(timer.isPaused)

        timer.unpauseGame()

        XCTAssertFalse(timer.isPaused)
    }

    func testStopRound() {
        timer.reset(startingTime: 60, turnBonus: 10, players: testPlayers, starter: 0)
        timer.startRound()

        timer.stopRound()

        XCTAssertTrue(timer.isPaused)
        XCTAssertFalse(timer.isActive)
    }

    // MARK: - Turn Management Tests

    func testEndTurnAdvancesPlayer() async {
        timer.reset(startingTime: 60, turnBonus: 10, players: testPlayers, starter: 0)
        timer.startRound()

        // Let some time elapse
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        let initialPlayer = timer.activePlayer
        timer.endTurn()

        // Small delay for turn change to process
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNotEqual(timer.activePlayer, initialPlayer)
        XCTAssertEqual(timer.activePlayer, "Bob")
    }

    func testEndTurnAppliesBonusTime() async {
        timer.reset(startingTime: 60, turnBonus: 10, players: testPlayers, starter: 0)
        timer.startRound()

        // Let 5 seconds elapse
        try? await Task.sleep(nanoseconds: 5_000_000_000)

        timer.endTurn()

        // Alice should have approximately 60 - 5 + 10 = 65 seconds
        // (allowing for timing variance)
        XCTAssertGreaterThan(timer.players[0].secondsRemaining, 60.0, "Should have gained bonus time")
        XCTAssertLessThan(timer.players[0].secondsRemaining, 70.0, "Should not have more than starting + bonus")
    }

    func testEndTurnWrapsToFirstPlayer() async {
        timer.reset(startingTime: 60, turnBonus: 10, players: testPlayers, starter: 2)
        timer.startRound()

        try? await Task.sleep(nanoseconds: 100_000_000)

        timer.endTurn()

        // Small delay for turn change
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(timer.activePlayer, "Alice", "Should wrap to first player")
        XCTAssertEqual(timer.turn, 1, "Turn counter increments when completing full cycle")
    }

    func testTurnCounterIncrement() async {
        timer.reset(startingTime: 60, turnBonus: 10, players: testPlayers, starter: 0)
        timer.startRound()

        XCTAssertEqual(timer.turn, 1)

        // Complete a full round
        for _ in 0..<3 {
            try? await Task.sleep(nanoseconds: 100_000_000)
            timer.endTurn()
            try? await Task.sleep(nanoseconds: 100_000_000)
        }

        XCTAssertEqual(timer.turn, 2, "Turn should increment after returning to first player")
    }

    // MARK: - Time Tracking Tests

    func testSecondsRemainingUpdates() async {
        timer.reset(startingTime: 60, turnBonus: 10, players: testPlayers, starter: 0)
        timer.startRound()

        // Wait a moment for timer to start and update
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        let initialTime = timer.secondsRemainingForTurn

        // Wait for time to pass
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        XCTAssertGreaterThan(initialTime, 0, "Initial time should be set")
        XCTAssertLessThan(timer.secondsRemainingForTurn, initialTime, "Time should decrease")
    }

    func testPlayerOutOfTime() async {
        // Start with very little time
        timer.reset(startingTime: 1, turnBonus: 0, players: testPlayers, starter: 0)
        timer.startRound()

        // Wait for time to expire
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        XCTAssertTrue(timer.isShowingAlert, "Should show alert when time expires")
        XCTAssertEqual(timer.players[0].secondsRemaining, 0, "Player time should be 0")
    }

    // MARK: - Theme and Player Info Tests

    func testActiveThemeUpdates() async {
        timer.reset(startingTime: 60, turnBonus: 10, players: testPlayers, starter: 0)
        XCTAssertEqual(timer.activeTheme, .saffron)

        timer.startRound()
        try? await Task.sleep(nanoseconds: 100_000_000)
        timer.endTurn()
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(timer.activeTheme, .chive, "Theme should update with active player")
    }

    func testNextPlayerDisplay() {
        timer.reset(startingTime: 60, turnBonus: 10, players: testPlayers, starter: 0)

        XCTAssertEqual(timer.activePlayer, "Alice")
        XCTAssertEqual(timer.nextPlayer, "Bob")
    }

    // MARK: - Edge Cases

    func testZeroStartingTime() {
        timer.reset(startingTime: 0, turnBonus: 10, players: testPlayers, starter: 0)

        XCTAssertEqual(timer.players[0].secondsRemaining, 0)
    }

    func testSinglePlayer() {
        let singlePlayer = [Player(name: "Solo", theme: .saffron)]
        timer.reset(startingTime: 60, turnBonus: 10, players: singlePlayer, starter: 0)

        XCTAssertEqual(timer.activePlayer, "Solo")
        XCTAssertEqual(timer.nextPlayer, "Solo", "Next player should be same player")
    }
}
