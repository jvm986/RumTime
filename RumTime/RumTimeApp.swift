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
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome: Bool = false

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
            NavigationStack {
                GamesView()
            }
            .sheet(isPresented: Binding(
                get: { !hasSeenWelcome },
                set: { if !$0 { hasSeenWelcome = true } }
            )) {
                NavigationStack {
                    HelpView()
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Get Started") {
                                    hasSeenWelcome = true
                                }
                            }
                        }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
