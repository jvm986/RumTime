//
//  RumTimeApp.swift
//  RumTime
//
//  Created by James Maguire on 03/10/2022.
//

import SwiftUI

@main
struct RumTimerApp: App {
    @StateObject private var store = GameStore()
    @State private var errorWrapper: ErrorWrapper?
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                GamesView(games: $store.games) {
                    Task {
                        do {
                            try await GameStore.save(games: store.games)
                        } catch {
                            errorWrapper = ErrorWrapper(error: error, guidance: "Try again later.")
                        }
                    }
                }
            }
            .task {
                do {
                    store.games = try await GameStore.load()
                } catch {
                    errorWrapper = ErrorWrapper(error: error, guidance: "Will load sample data and continue.")
                }
            }
            .sheet(item: $errorWrapper, onDismiss: {
                store.games = Game.sampleData
            }) { wrapper in
                ErrorView(errorWrapper: wrapper)
            }
        }
    }
}
