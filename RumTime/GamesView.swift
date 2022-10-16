//
//  GamesView.swift
//  RumTime
//
//  Created by James Maguire on 14/10/2022.
//

import SwiftUI

struct GamesView: View {
    @Binding var games: [Game]
    @Environment(\.scenePhase) private var scenePhase
    @State private var isPresentingNewGameView = false
    @State private var newGameData = Game.Data()
    let saveAction: ()->Void
    
    var body: some View {
        List {
            ForEach($games) { $game in
                NavigationLink(destination: DetailView(game: $game, saveAction: saveAction)) {
                    GameCardView(game: game)
                }
                .listRowBackground(game.players[0].theme.mainColor)
            }
            .onDelete { indices in
                games.remove(atOffsets: indices)
                saveAction()
            }
        }
        .navigationTitle("Games")
        .toolbar {
            Button(action: {
                isPresentingNewGameView = true
            }) {
                Image(systemName: "plus")
            }
            .accessibilityLabel("New Scrum")
        }
        .sheet(isPresented: $isPresentingNewGameView) {
            NavigationView {
                DetailEditView(data: $newGameData)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") {
                                isPresentingNewGameView = false
                                newGameData = Game.Data()
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                let newGame = Game(data: newGameData)
                                games.append(newGame)
                                isPresentingNewGameView = false
                                newGameData = Game.Data()
                                saveAction()
                            }
                        }
                    }
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .inactive { saveAction() }
        }
    }
}

struct GamesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GamesView(games: .constant(Game.sampleData), saveAction: {})
        }
    }
}
