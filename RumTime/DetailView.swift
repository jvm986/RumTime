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
    @State private var isPresentingTimerView = false
    @State private var isPresentingScoreView = false
    @StateObject var gameTimer = RoundTimer()
    let saveAction: ()->Void
    
    
    var body: some View {
        List {
            Section(header: Text("Game Settings")) {
                if gameTimer.isPaused {
                    Button {
                        isPresentingTimerView = true
                        gameTimer.unpauseGame()
                    } label: {
                        Label("Resume Round", systemImage: "timer")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    }
                } else {
                    Button {
                        isPresentingTimerView = true
                        gameTimer.reset(startingTime: game.startingTime, turnBonus: game.turnBonus, players: game.players)
                        gameTimer.startGame()
                    } label: {
                        Label("Start Round", systemImage: "timer")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    }
                }
                HStack {
                    Label("Starting Time", systemImage: "clock")
                    Spacer()
                    Text("\(game.startingTimeMinutes) minutes")
                }
                HStack {
                    Label("Turn Bonus", systemImage: "goforward.plus")
                    Spacer()
                    Text("\(game.turnBonus) seconds")
                }
            }
            Section(header: Text("Players")) {
                ForEach(game.sortedPlayers) { player in
                    HStack {
                        Label(player.name, systemImage: "person")
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
                        Text(round.date, style: .time)
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
                DetailEditView(data: $gameData)
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
                        }
                    }
            }
        }
        .sheet(isPresented: $isPresentingTimerView) {
            NavigationView {
                RoundTimerView(game: $game, gameTimer: gameTimer)
                    .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
                    .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
                    .navigationTitle(gameTimer.activePlayer)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Pause") {
                                gameTimer.pauseGame()
                                isPresentingTimerView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("End") {
                                roundData.scores = game.scores
                                gameTimer.pauseGame()
                                isPresentingTimerView = false
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
                                gameTimer.reset(startingTime: game.startingTime, turnBonus: game.turnBonus, players: game.players)
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
                isPresentingTimerView = false
                gameTimer.pauseGame()
            }
        }
    }
}

struct GameDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(game: .constant(Game.sampleData[1]), saveAction: {})
    }
}
