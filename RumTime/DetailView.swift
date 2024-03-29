//
//  GameDetailView.swift
//  RumTime
//
//  Created by James Maguire on 14/10/2022.
//

import SwiftUI

struct DetailView: View {
    @Binding var game: Game
    @Environment(\.scenePhase) private var scenePhase
    @State private var gameData = Game.Data()
    @State private var roundData = Round.Data()
    @State private var isPresentingEditView = false
    @State private var isPresentingScoreView = false
    @StateObject var roundTimer = RoundTimer()
    let saveAction: ()->Void
    
    
    var body: some View {
        List {
            Section(header: Text("Game Settings")) {
                if roundTimer.isActive {
                    Button {
                        roundTimer.unpauseGame()
                    } label: {
                        Label("Resume Round (\(roundTimer.activePlayer))", systemImage: "timer")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    }
                } else {
                    Button {
                        roundTimer.reset(startingTime: game.startingTime, turnBonus: game.turnBonus, players: game.unpausedPlayers, starter: game.unpausedStarter)
                        roundTimer.startRound()
                    } label: {
                        Label("Start Round (\(game.unpausedPlayers[game.unpausedStarter].name))", systemImage: "timer")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    }
                }
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
            Section(header: Text("Players")) {
                ForEach($game.sortedPlayers) { $player in
                    HStack {
                        Label(player.name, systemImage: player.isPaused ? "person.badge.clock" : "person")
                            .onTapGesture {
                                if !roundTimer.isActive {
                                    game.togglePausedPlayer(id: player.id)
                                    roundTimer.reset(startingTime: game.startingTime, turnBonus: game.turnBonus, players: game.unpausedPlayers, starter: game.unpausedStarter)
                                }
                            }
                        Spacer()
                        Text("\(player.totalScore(rounds: game.rounds)) points")
                    }
                    .listRowBackground(player.theme.mainColor)
                    .foregroundColor(player.theme.accentColor)
                    .accessibilityElement(children: .combine)
                }
            }
            Section(header: Text("Rounds")) {
                if game.rounds.isEmpty {
                    Label("No rounds yet", systemImage: "calendar.badge.exclamationmark")
                }
                ForEach(game.rounds) { round in
                    HStack {
                        Image(systemName: "calendar")
                        Text(round.date.formatted())
                        Spacer()
                        Label(round.winner.player.name, systemImage: "rosette")
                    }
                }
                .onDelete { indices in
                    game.rounds.remove(atOffsets: indices)
                    saveAction()
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
        .sheet(isPresented: $isPresentingEditView) {
            NavigationView {
                DetailEditView(data: $gameData, roundTimer: roundTimer)
                    .navigationTitle(game.name)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isPresentingEditView = false
                                game.update(from: gameData)
                                saveAction()
                            }
                            .disabled(gameData.players.count < 2 || gameData.name == "" || gameData.startingTime <= 0)
                        }
                    }
            }
        }
        .sheet(isPresented: $roundTimer.isPaused.not) {
            NavigationView {
                RoundTimerView(game: $game, roundTimer: roundTimer)
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
                                roundData.scores = game.scores
                                roundData.setWinner(id: roundTimer.activePlayerObj.id)
                                roundTimer.pauseRound()
                                isPresentingScoreView = true
                            }
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
                                saveAction()
                            }
                        }
                    }
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .inactive {
                roundTimer.pauseRound()
            }
        }
    }
}

struct GameDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(game: .constant(Game.sampleData[1]), saveAction: {})
    }
}
