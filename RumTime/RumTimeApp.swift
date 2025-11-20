//
//  RumTimeApp.swift
//  RumTime
//
//  Created by James Maguire on 19.11.25.
//

import SwiftUI
import SwiftData

@main
struct RumTimeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Game.self,
            Player.self,
            Round.self,
            Score.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                GamesView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
