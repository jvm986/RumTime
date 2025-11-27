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
        app.launchArguments = ["--uitesting", "--screenshots"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Unified Test Flow with Screenshots

    @MainActor
    func testCompleteGameFlowWithScreenshots() throws {
        dismissWelcomeScreenIfPresent()
        
        cleanupTestGames()

        createGame(
            name: "Family Night",
            players: ["Alice", "Bob", "Charlie"],
            gameTheme: "Classicblue",
            playerThemes: ["Saffron", "Coralpink", "Ash"]
        )
        createGame(
            name: "Tournament",
            players: ["Diana", "Eve", "Frank", "Grace"],
            gameTheme: "Chive",
            playerThemes: ["Sunlight", "Saffron", "Coralpink", "Ash"]
        )
        createGame(
            name: "Quick Game",
            players: ["Henry", "Iris"],
            gameTheme: "Grapecompote",
            playerThemes: ["Saffron", "Coralpink"]
        )

        let firstGame = app.staticTexts["Family Night"]
        XCTAssertTrue(firstGame.waitForExistence(timeout: 10), "First game should appear in list")
        takeScreenshot(named: "01-games-list")
        firstGame.tap()

        let startButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Start Round'")).firstMatch
        XCTAssertTrue(startButton.waitForExistence(timeout: 10), "Start Round button should exist")
        startButton.tap()
        XCTAssertTrue(app.staticTexts["Alice"].waitForExistence(timeout: 10), "Timer should show first player")

        let endButton = app.buttons["End Round"]
        XCTAssertTrue(endButton.waitForExistence(timeout: 5), "End Round button should exist")
        takeScreenshot(named: "02-timer-active")
        endButton.tap()
        XCTAssertTrue(app.navigationBars["Record Scores"].waitForExistence(timeout: 10), "Score screen should appear")
        takeScreenshot(named: "03-score-entry")

        let recordButton = app.buttons["Record Round"]
        XCTAssertTrue(recordButton.waitForExistence(timeout: 3), "Record button should exist")
        recordButton.tap()

        let gameBackButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(gameBackButton.exists, "Back button should exist")
        takeScreenshot(named: "04-game-detail")
        gameBackButton.tap()
        XCTAssertTrue(app.staticTexts["Family Night"].waitForExistence(timeout: 10), "Should return to games list")

        let menuButton = app.buttons["Menu"].firstMatch
        XCTAssertTrue(menuButton.waitForExistence(timeout: 2), "Menu button should exist")
        menuButton.tap()

        let helpButton = app.buttons["Help"]
        XCTAssertTrue(helpButton.waitForExistence(timeout: 2), "Help button should exist")
        helpButton.tap()
        XCTAssertTrue(app.navigationBars["Help"].waitForExistence(timeout: 2), "Help screen should appear")
        takeScreenshot(named: "05-help-screen")

        // Dismiss help sheet by tapping back button
        let helpBackButton = app.buttons["Help Back Button"]
        XCTAssertTrue(helpBackButton.waitForExistence(timeout: 2), "Help back button should exist")
        helpBackButton.tap()

        // Wait for sheet to dismiss and games list to be visible again
        XCTAssertTrue(app.buttons["Menu"].waitForExistence(timeout: 3), "Should return to games list")
        
        cleanupTestGames()

        XCTAssertFalse(app.staticTexts["Family Night"].exists, "Family Night should be deleted")
        XCTAssertFalse(app.staticTexts["Tournament"].exists, "Tournament should be deleted")
        XCTAssertFalse(app.staticTexts["Quick Game"].exists, "Quick Game should be deleted")
    }

    // MARK: - Helper Methods

    private func takeScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func dismissWelcomeScreenIfPresent() {
        let getStartedButton = app.buttons["Get Started"]
        if getStartedButton.waitForExistence(timeout: 3) {
            getStartedButton.tap()
        }
    }

    private func createGame(name: String, players: [String], gameTheme: String? = nil, playerThemes: [String] = []) {
        // Find and tap New Game button
        let newGameButton = app.buttons["Create Game"]
        XCTAssertTrue(newGameButton.waitForExistence(timeout: 5), "New Game button should exist")
        newGameButton.tap()

        // Wait for New Game screen
        XCTAssertTrue(app.navigationBars["New Game"].waitForExistence(timeout: 10), "New Game screen should appear")

        let nameField = app.textFields["Enter game name"]

        // Select game theme if specified
        if let gameTheme = gameTheme {
            let gameColorButton = app.buttons["Game color"]
            XCTAssertTrue(gameColorButton.waitForExistence(timeout: 2), "Game color button should exist")
            gameColorButton.tap()

            let themeButton = app.buttons[gameTheme]
            XCTAssertTrue(themeButton.waitForExistence(timeout: 2), "Theme button \(gameTheme) should exist")
            themeButton.tap()

            // Dismiss sheet by tapping on the navigation bar
            let navBar = app.navigationBars["New Game"]
            navBar.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

            // Wait for sheet to dismiss
            sleep(1)
        }

        XCTAssertTrue(nameField.waitForExistence(timeout: 2), "Name field should exist")
        nameField.typeText(name)


        // Add players
        let playerField = app.textFields["New Player"]
        let addButton = app.buttons["Add player"]

        for (index, player) in players.enumerated() {
            XCTAssertTrue(playerField.waitForExistence(timeout: 5), "Player field should exist for \(player)")
            playerField.tap()
            playerField.typeText(player)

            XCTAssertTrue(addButton.waitForExistence(timeout: 3), "Add button should exist")
            addButton.tap()

            // Select player theme if specified
            if index < playerThemes.count {
                // Tap on the player name text to open color picker
                let playerNameText = app.staticTexts[player]
                XCTAssertTrue(playerNameText.waitForExistence(timeout: 3), "Player name \(player) should exist")
                playerNameText.tap()

                let themeButton = app.buttons[playerThemes[index]]
                XCTAssertTrue(themeButton.waitForExistence(timeout: 2), "Theme button \(playerThemes[index]) should exist")
                themeButton.tap()

                // Dismiss sheet by tapping on the navigation bar
                let navBar = app.navigationBars["New Game"]
                navBar.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            }
        }

        // Create game
        let createButton = app.buttons["Create"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 5), "Create button should exist")
        XCTAssertTrue(createButton.isEnabled, "Create button should be enabled")
        createButton.tap()
    }

    private func cleanupTestGames() {
        let testGames = ["Test Game", "Family Night", "Tournament", "Quick Game"]

        for gameName in testGames {
            let game = app.staticTexts[gameName]
            if game.waitForExistence(timeout: 2) {
                // Tap game to open detail view
                game.tap()

                // Tap menu button
                let menuButton = app.buttons["More options"]
                if menuButton.waitForExistence(timeout: 5) {
                    menuButton.tap()

                    // Tap Delete Game in menu
                    let deleteMenuItem = app.buttons["Delete Game"]
                    if deleteMenuItem.waitForExistence(timeout: 3) {
                        deleteMenuItem.tap()

                        // Confirm in alert
                        let confirmButton = app.buttons["Delete"]
                        if confirmButton.waitForExistence(timeout: 3) {
                            confirmButton.tap()
                        }
                    }
                }
            }
        }
    }
}
