//
//  GameDetailView.swift
//  RumTime
//
//  Created by James Maguire on 14/10/2022.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    let game: Game
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var gameData = Game.Data()
    @State private var roundData = Round.Data()
    @State private var isPresentingEditView = false
    @State private var isPresentingScoreView = false
    @State private var editPlayerName = ""
    @State var roundTimer = RoundTimer()

    private var canSaveGame: Bool {
        let hasEnoughPlayers = gameData.players.count >= 2 ||
                               (gameData.players.count == 1 && !editPlayerName.isEmpty)
        return hasEnoughPlayers && !gameData.name.isEmpty && gameData.startingTime > 0
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                Section(header: Text("Game Settings")) {
                    HStack {
                        Label("Starting Time", systemImage: "clock")
                        Spacer()
                        Text("\(game.startingTimeString)")
                    }
                    HStack {
                        Label("Turn Bonus", systemImage: "goforward.plus")
                        Spacer()
                        Text("\(game.turnBonus) seconds")
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            Section(header: Text("Players")) {
                ForEach(game.sortedPlayers) { player in
                    HStack {
                        Label(player.name, systemImage: player.isPaused ? "person.slash" : "person")
                        Spacer()
                        if player.isPaused {
                            Text("Sitting Out")
                                .font(.caption)
                                .italic()
                        } else {
                            Text("\(player.totalScore()) points")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(player.theme.mainColor)
                    .foregroundColor(player.theme.accentColor)
                    .cornerRadius(10)
                    .opacity(player.isPaused ? 0.6 : 1.0)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !roundTimer.isActive {
                            game.togglePausedPlayer(id: player.id)
                            roundTimer.reset(startingTime: game.startingTime, turnBonus: game.turnBonus, players: game.unpausedPlayers, starter: game.unpausedStarter)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(player.isPaused ? "\(player.name), sitting out, \(player.totalScore()) points. Tap to rejoin game" : "\(player.name), \(player.totalScore()) points. Tap to sit out")
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
            }
            Section(header: Text("Rounds")) {
                if game.rounds.isEmpty {
                    Label("No rounds yet", systemImage: "calendar.badge.exclamationmark")
                        .listRowBackground(Color.clear)
                }
                ForEach(game.rounds) { round in
                    HStack {
                        Image(systemName: "calendar")
                        Text(round.date.formatted())
                        Spacer()
                        Label(round.winner.playerName, systemImage: "trophy.fill")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(10)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
                .onDelete { indices in
                    for index in indices {
                        modelContext.delete(game.rounds[index])
                    }
                }
            }
            }
            .navigationTitle(game.name)
            .toolbar {
                Button("Edit") {
                    isPresentingEditView = true
                    gameData = game.data
                }
            }

            // Floating action button
            if roundTimer.isActive {
                Button {
                    roundTimer.unpauseGame()
                } label: {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                        Text("Resume Round")
                            .fontWeight(.semibold)
                        Text("(\(roundTimer.activePlayer))")
                            .fontWeight(.regular)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(15)
                    .shadow(radius: 4)
                }
                .padding()
            } else {
                Button {
                    roundTimer.reset(startingTime: game.startingTime, turnBonus: game.turnBonus, players: game.unpausedPlayers, starter: game.unpausedStarter)
                    roundTimer.startRound()
                } label: {
                    HStack {
                        Image(systemName: "timer")
                            .font(.title2)
                        Text("Start Round")
                            .fontWeight(.semibold)
                        Text("(\(game.unpausedPlayers[game.unpausedStarter].name) starts)")
                            .fontWeight(.regular)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(15)
                    .shadow(radius: 4)
                }
                .padding()
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationView {
                DetailEditView(data: $gameData, roundTimer: roundTimer, newPlayerName: $editPlayerName)
                    .navigationTitle(game.name)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingEditView = false
                                editPlayerName = ""
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                // Add the unsaved player if there's one in the text field
                                if !editPlayerName.isEmpty {
                                    let playerData = Game.Data.PlayerData(name: editPlayerName, theme: gameData.randomTheme)
                                    gameData.players.append(playerData)
                                }

                                isPresentingEditView = false
                                game.update(from: gameData)
                                editPlayerName = ""
                            }
                            .disabled(!canSaveGame)
                        }
                    }
            }
        }
        .sheet(isPresented: $roundTimer.isPaused.not) {
            NavigationView {
                RoundTimerView(game: game, roundTimer: roundTimer)
                    .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
                    .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
                    .navigationTitle(roundTimer.activePlayer)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Pause") {
                                roundTimer.pauseRound()
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("End") {
                                roundData.scores = game.createScores()
                                roundData.setWinner(id: roundTimer.activePlayerObj.id)
                                roundTimer.pauseRound()
                                isPresentingScoreView = true
                            }
                            .accessibilityIdentifier("End Round")
                        }
                    }
            }
        }
        .sheet(isPresented: $isPresentingScoreView) {
            NavigationView {
                ScoreView(round: $roundData)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingScoreView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Record") {
                                roundTimer.reset(startingTime: game.startingTime, turnBonus: game.turnBonus, players: game.unpausedPlayers, starter: game.unpausedStarter)
                                game.addRound(from: roundData)
                                isPresentingScoreView = false
                            }
                        }
                    }
            }
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            if newValue == .inactive {
                roundTimer.pauseRound()
            }
        }
    }
}

#Preview {
    do {
        let container = try ModelContainer(for: Game.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let game = Game.sampleData[1]
        container.mainContext.insert(game)

        return NavigationView {
            DetailView(game: game)
        }
        .modelContainer(container)
    } catch {
        return Text("Failed to create preview")
    }
}
