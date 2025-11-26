//
//  GamesView.swift
//  RumTime
//
//  Created by James Maguire on 14/10/2022.
//

import SwiftUI
import SwiftData

struct GamesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Game.name) private var games: [Game]
    @Environment(\.scenePhase) private var scenePhase
    @State private var isPresentingNewGameView = false
    @State private var newGameData = Game.Data()

    var body: some View {
        Group {
            if games.isEmpty {
                EmptyStateView()
            } else {
                List {
                    ForEach(games) { game in
                        NavigationLink(value: game.id) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(game.name)
                                    .font(.headline)
                                    .foregroundColor(game.theme.accentColor)
                                    .accessibilityAddTraits(.isHeader)

                                HStack(spacing: 12) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "person.3")
                                        Text("\(game.players.count)")
                                    }
                                    .accessibilityLabel("\(game.players.count) players")

                                    HStack(spacing: 4) {
                                        Image(systemName: "clock")
                                        Text("\(game.startingTimeString)")
                                    }
                                    .accessibilityLabel("\(game.startingTime) starting time")
                                }
                                .font(.caption)
                                .foregroundColor(game.theme.accentColor)
                            }
                            .padding(.vertical, 5)
                        }
                        .listRowBackground(game.theme.mainColor)
                    }
                }
            }
        }
        .navigationTitle("Games")
        .navigationSubtitle(games.isEmpty ? "" : "Tap the + button to create a new game")
        .navigationDestination(for: UUID.self) { gameID in
            if let game = games.first(where: { $0.id == gameID }) {
                DetailView(game: game)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Set a random theme that's not already used by existing games
                    var availableThemes = Theme.allCases
                    for game in games {
                        availableThemes.removeAll { $0 == game.theme }
                    }
                    newGameData.theme = availableThemes.randomElement() ?? Theme.allCases.randomElement() ?? .saffron
                    isPresentingNewGameView = true
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New Game")
            }
        }
        .sheet(isPresented: $isPresentingNewGameView) {
            NavigationView {
                DetailView(
                    game: Game(data: newGameData),
                    isNewGame: true,
                    onSave: {
                        newGameData = Game.Data()
                    }
                )
            }
            .onDisappear {
                newGameData = Game.Data()
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image("EmptyStateIcon")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)

            Text("No Games Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Tap the + button to create your first game")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
            Spacer()
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No games yet. Tap the plus button to create your first game")
    }
}

#Preview {
    let container = try! ModelContainer(for: Game.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let game1 = Game.sampleData[0]
    let game2 = Game.sampleData[1]
    container.mainContext.insert(game1)
    container.mainContext.insert(game2)

    return NavigationView {
        GamesView()
    }
    .modelContainer(container)
}
