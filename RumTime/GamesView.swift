//
//  GamesView.swift
//  RumTime
//
//  Created by James Maguire on 14/10/2022.
//

import SwiftData
import SwiftUI

struct GamesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Game.name) private var games: [Game]
    @Environment(\.scenePhase) private var scenePhase
    @State private var isPresentingNewGameView = false
    @State private var newGameData = Game.Data()

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if games.isEmpty {
                    VStack(spacing: 0) {
                        Spacer()
                        Image("EmptyStateIcon")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                            .foregroundColor(.secondary)
                            .accessibilityHidden(true)
                            .opacity(0.3)
                        Spacer()
                        Spacer()
                            .frame(height: 60)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    .safeAreaInset(edge: .top) {
                        Color.clear.frame(height: 20)
                    }
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 60)
                    }
                }
            }

            Button(action: {
                // Set a random theme that's not already used by existing games
                var availableThemes = Theme.allCases
                for game in games {
                    availableThemes.removeAll { $0 == game.theme }
                }
                newGameData.theme =
                    availableThemes.randomElement() ?? Theme.allCases.randomElement()
                    ?? .saffron
                isPresentingNewGameView = true
            }) {
                Text("Create Game")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .background(
                        Capsule()
                            .fill(Color.saffron)
                    )
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .navigationTitle("Games")
        .navigationDestination(for: UUID.self) { gameID in
            if let game = games.first(where: { $0.id == gameID }) {
                DetailView(game: game)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                }
                .accessibilityLabel("Settings")
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

#Preview {
    let container = try! ModelContainer(
        for: Game.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let game1 = Game.sampleData[0]
    let game2 = Game.sampleData[1]
    container.mainContext.insert(game1)
    container.mainContext.insert(game2)

    return NavigationView {
        GamesView()
    }
    .modelContainer(container)
}
