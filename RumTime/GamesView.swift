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
    @State private var newPlayerName = ""

    func duplicateGame(_ game: Game) {
        var gameData = game.data

        // Assign a new random theme to the game (avoiding the original game's theme)
        let availableThemes = Theme.allCases.filter { $0 != game.theme }
        if let newTheme = availableThemes.randomElement() {
            gameData.theme = newTheme
        }

        let duplicatedGame = Game(data: gameData)
        duplicatedGame.name = "\(game.name) (Copy)"
        modelContext.insert(duplicatedGame)
    }

    private var canCreateGame: Bool {
        let hasEnoughPlayers = newGameData.players.count >= 2 ||
                               (newGameData.players.count == 1 && !newPlayerName.isEmpty)
        return hasEnoughPlayers && !newGameData.name.isEmpty && newGameData.startingTime > 0
    }

    var body: some View {
        Group {
            if games.isEmpty {
                EmptyStateView()
            } else {
                List {
                    ForEach(games) { game in
                        ZStack {
                            NavigationLink(destination: DetailView(game: game)) {
                                EmptyView()
                            }
                            .opacity(0)

                            GameCardView(game: game)
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                duplicateGame(game)
                            } label: {
                                Label("Duplicate", systemImage: "doc.on.doc")
                            }
                            .tint(.blue)
                        }
                    }
                    .onDelete { indices in
                        for index in indices {
                            modelContext.delete(games[index])
                        }
                    }
                }
            }
        }
        .navigationTitle("Games")
        .toolbar {
            Button(action: {
                isPresentingNewGameView = true
            }) {
                Image(systemName: "plus")
            }
            .accessibilityLabel("New Game")
        }
        .sheet(isPresented: $isPresentingNewGameView) {
            NavigationView {
                DetailEditView(data: $newGameData, roundTimer: RoundTimer(), newPlayerName: $newPlayerName)
                    .navigationTitle("New Game")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") {
                                isPresentingNewGameView = false
                                newGameData = Game.Data()
                                newPlayerName = ""
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Create Game") {
                                // Add the unsaved player if there's one in the text field
                                if !newPlayerName.isEmpty {
                                    let playerData = Game.Data.PlayerData(name: newPlayerName, theme: newGameData.randomTheme)
                                    newGameData.players.append(playerData)
                                }

                                let newGame = Game(data: newGameData)
                                modelContext.insert(newGame)
                                isPresentingNewGameView = false
                                newGameData = Game.Data()
                                newPlayerName = ""
                            }
                            .disabled(!canCreateGame)
                        }
                    }
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
