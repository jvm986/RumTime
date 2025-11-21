//
//  ScreenshotTests.swift
//  RumTimeUITests
//
//  Created by James Maguire on 20.11.25.
//

import XCTest

final class ScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--screenshots"]
        app.launch()

        // Dismiss welcome screen if it appears
        let getStartedButton = app.buttons["Get Started"]
        if getStartedButton.waitForExistence(timeout: 3) {
            getStartedButton.tap()
        }
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testCaptureScreenshots() throws {
        // Clean up any existing test data
        cleanupTestGames()

        // Screenshot 1: Create sample games
        createSampleGames()
        sleep(1)
        takeScreenshot(named: "01-games-list")

        // Screenshot 2: Open first game to show game detail
        let firstGame = app.staticTexts["Family Night"]
        XCTAssertTrue(firstGame.waitForExistence(timeout: 5))
        firstGame.tap()
        sleep(1)
        takeScreenshot(named: "02-game-detail")

        // Screenshot 3: Start round to show timer
        let startButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Start Round'")).element
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()
        sleep(2) // Let timer run a bit
        takeScreenshot(named: "03-timer-active")

        // Screenshot 4: End round and show score entry
        let endButton = app.buttons["End Round"]
        XCTAssertTrue(endButton.waitForExistence(timeout: 5))
        endButton.tap()
        sleep(1)
        takeScreenshot(named: "04-score-entry")

        // Cancel score entry
        let cancelButton = app.buttons["Resume"]
        cancelButton.tap()

        // Pause the round
        let pauseButton = app.buttons["Pause"]
        if pauseButton.waitForExistence(timeout: 2) {
            pauseButton.tap()
        }

        // Go back to games list
        app.navigationBars.buttons.element(boundBy: 0).tap()
        sleep(1)

        // Screenshot 5: Open help screen
        let menuButton = app.buttons["More options"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 5))
        menuButton.tap()

        let helpButton = app.buttons["Help"]
        XCTAssertTrue(helpButton.waitForExistence(timeout: 2))
        helpButton.tap()
        sleep(1)
        takeScreenshot(named: "05-help-screen")

        // Cleanup
        let doneButton = app.buttons["Done"]
        if doneButton.waitForExistence(timeout: 2) {
            doneButton.tap()
        }

        cleanupTestGames()
    }

    // MARK: - Helper Methods

    private func takeScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func createSampleGames() {
        // Game 1: Family Night
        createGame(name: "Family Night", players: ["Alice", "Bob", "Charlie"])

        // Game 2: Tournament
        createGame(name: "Tournament", players: ["Diana", "Eve", "Frank", "Grace"])

        // Game 3: Quick Game
        createGame(name: "Quick Game", players: ["Henry", "Iris"])
    }

    private func createGame(name: String, players: [String]) {
        let newGameButton = app.buttons["New Game"]
        XCTAssertTrue(newGameButton.waitForExistence(timeout: 5))
        newGameButton.tap()

        let gameNameField = app.textFields["Game Name"]
        XCTAssertTrue(gameNameField.waitForExistence(timeout: 3))
        gameNameField.tap()
        gameNameField.typeText(name)

        let playerField = app.textFields["New Player"]
        let addButton = app.buttons["Add player"]

        for player in players {
            playerField.tap()
            playerField.typeText(player)
            addButton.tap()
        }

        let createButton = app.buttons["Create Game"]
        createButton.tap()

        sleep(1) // Wait for game to be created
    }

    private func cleanupTestGames() {
        let testGames = ["Family Night", "Tournament", "Quick Game"]

        for gameName in testGames {
            let game = app.staticTexts[gameName]
            if game.waitForExistence(timeout: 2) {
                game.swipeLeft()
                let deleteButton = app.buttons["Delete"]
                if deleteButton.waitForExistence(timeout: 1) {
                    deleteButton.tap()
                    let confirmButton = app.buttons["Delete"]
                    if confirmButton.waitForExistence(timeout: 1) {
                        confirmButton.tap()
                    }
                }
            }
        }
    }
}
