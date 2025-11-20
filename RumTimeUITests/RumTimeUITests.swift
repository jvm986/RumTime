//
//  RumTimeUITests.swift
//  RumTimeUITests
//
//  Created by James Maguire on 18.11.25.
//

import XCTest

final class RumTimeUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Comprehensive Flow Test

    @MainActor
    func testCompleteGameFlow() throws {
        // Clean up any existing "Flow Test Game" from previous failed runs
        let existingGame = app.staticTexts["Flow Test Game"]
        if existingGame.waitForExistence(timeout: 2) {
            existingGame.swipeLeft()
            let deleteButton = app.buttons["Delete"]
            if deleteButton.waitForExistence(timeout: 1) {
                deleteButton.tap()
            }
        }

        // ===== TEST 1: Create Game with Validation =====
        let newGameButton = app.buttons["New Game"]
        XCTAssertTrue(newGameButton.waitForExistence(timeout: 15), "New Game button should exist")
        newGameButton.tap()

        let gameNameField = app.textFields["Game Name"]
        XCTAssertTrue(gameNameField.waitForExistence(timeout: 5), "Game Name field should appear")
        gameNameField.tap()
        gameNameField.typeText("Flow Test Game")

        // Verify starting time slider exists
        let startingTimeSlider = app.sliders["Starting Time Slider"]
        XCTAssertTrue(startingTimeSlider.exists, "Starting time slider should exist")

        // Add first player
        let playerField = app.textFields["New Player"]
        XCTAssertTrue(playerField.waitForExistence(timeout: 5), "Player field should exist")
        playerField.tap()
        playerField.typeText("Alice")

        let addPlayerButton = app.buttons["Add player"]
        XCTAssertTrue(addPlayerButton.waitForExistence(timeout: 2), "Add player button should exist")
        addPlayerButton.tap()

        // Verify Create Game button is disabled with only one player
        let createButton = app.buttons["Create Game"]
        XCTAssertFalse(createButton.isEnabled, "Create button should be disabled with one player")

        // Add second player
        playerField.tap()
        playerField.typeText("Bob")
        addPlayerButton.tap()

        // Verify Create Game button is now enabled and create the game
        XCTAssertTrue(createButton.isEnabled, "Create button should be enabled with two players")
        createButton.tap()

        // Verify game appears in list
        let gameCell = app.staticTexts["Flow Test Game"].firstMatch
        XCTAssertTrue(gameCell.waitForExistence(timeout: 5), "Game should appear in list")

        // ===== TEST 2: Start and End Round =====
        gameCell.tap()

        let startRoundButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Start Round'")).element
        XCTAssertTrue(startRoundButton.waitForExistence(timeout: 5), "Start Round button should exist")
        startRoundButton.tap()

        // Verify timer view appears
        let aliceLabel = app.staticTexts["Alice"]
        XCTAssertTrue(aliceLabel.waitForExistence(timeout: 5), "Alice label should appear on timer")

        // Wait briefly for timer to run
        sleep(1)

        // End the round
        let endRoundButton = app.buttons["End Round"]
        XCTAssertTrue(endRoundButton.waitForExistence(timeout: 5), "End Round button should exist")
        endRoundButton.tap()

        // ===== TEST 3: Record Scores with Winner Selection =====
        // Wait for score view
        let winnerLabel = app.staticTexts["Winner"]
        XCTAssertTrue(winnerLabel.waitForExistence(timeout: 5), "Winner section should appear")

        // Verify score view title
        let scoreViewTitle = app.navigationBars["Record Scores"]
        XCTAssertTrue(scoreViewTitle.waitForExistence(timeout: 5), "Score view should be loaded")

        // Verify Alice is initially selected as winner
        let aliceWinnerButton = app.buttons.matching(NSPredicate(format: "label == 'Alice, winner'")).element
        XCTAssertTrue(aliceWinnerButton.waitForExistence(timeout: 5), "Alice should initially be winner")

        // Select Bob as winner instead
        let bobSelectButton = app.buttons.matching(NSPredicate(format: "label == 'Select Bob as winner'")).element
        XCTAssertTrue(bobSelectButton.waitForExistence(timeout: 5), "Bob select button should exist")
        bobSelectButton.tap()

        // Wait for UI to update
        sleep(1)

        // Verify Bob is now the winner
        let bobWinnerButton = app.buttons.matching(NSPredicate(format: "label == 'Bob, winner'")).element
        XCTAssertTrue(bobWinnerButton.exists, "Bob should now be marked as winner")

        // Verify Alice appears in Scores section (non-winners get score entry)
        let scoresSection = app.staticTexts["Scores"]
        XCTAssertTrue(scoresSection.exists, "Scores section should exist")

        // Record the scores
        let recordButton = app.buttons["Record"]
        XCTAssertTrue(recordButton.waitForExistence(timeout: 2), "Record button should exist")
        recordButton.tap()

        // Verify we're back on game detail view and round was recorded
        let roundsLabel = app.staticTexts["Rounds"]
        XCTAssertTrue(roundsLabel.waitForExistence(timeout: 5), "Rounds section should appear")

        // Navigate back to games list
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // ===== TEST 4: Delete Game =====
        // Swipe to delete
        let gameToDelete = app.staticTexts["Flow Test Game"]
        XCTAssertTrue(gameToDelete.waitForExistence(timeout: 5), "Game should exist")
        gameToDelete.swipeLeft()

        // Tap delete button
        let deleteButton = app.buttons["Delete"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2), "Delete button should appear")
        deleteButton.tap()

        // Verify game is deleted
        XCTAssertFalse(app.staticTexts["Flow Test Game"].exists, "Game should be deleted")
    }
}
