//
//  GameDetailEditView.swift
//  RumTime
//
//  Created by James Maguire on 14/10/2022.
//

import SwiftUI

struct DetailEditView: View {
    @Binding var data: Game.Data
    var roundTimer: RoundTimer
    @Binding var newPlayerName: String
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isTitleFieldFocused: Bool

    func move(from source: IndexSet, to destination: Int) {
        data.players.move(fromOffsets: source, toOffset: destination)
        data.starter = 0
        let players = data.players.map { $0.toPlayer() }
        roundTimer.reset(startingTime: Int(data.startingTime), turnBonus: Int(data.turnBonus), players: players, starter: 0)
    }

    func addPlayer() {
        guard !newPlayerName.isEmpty else { return }

        let player = Game.Data.PlayerData(name: newPlayerName, theme: data.randomTheme)

        if reduceMotion {
            data.players.append(player)
            newPlayerName = ""
        } else {
            withAnimation {
                data.players.append(player)
                newPlayerName = ""
            }
        }

        // Keep focus on text field for adding next player
        isTextFieldFocused = true
    }

    var body: some View {
        Form {
            Section(header: Text("Game Info")) {
                TextField("Title", text: $data.name)
                    .accessibilityIdentifier("Game Name")
                    .focused($isTitleFieldFocused)
                HStack {
                    Text("Start")
                    Slider(value: $data.startingTime, in: 15...300, step: 15) {
                        Text("Starting Time")
                    }
                    .accessibilityIdentifier("Starting Time Slider")
                    Spacer()
                    Text(String(format: "%02i:%02i", Int(data.startingTime) / 60 % 60, Int(data.startingTime) % 60))
                        .accessibilityHidden(true)
                }
                HStack {
                    Text("Turn")
                    Slider(value: $data.turnBonus, in: 1...15, step: 1) {
                        Text("Turn Bonus")
                    }
                    .accessibilityValue("\(Int(data.turnBonus)) seconds")
                    .accessibilityIdentifier("Turn Bonus Slider")
                    Spacer()
                    Text("\(Int(data.turnBonus))s")
                        .accessibilityHidden(true)
                }
            }
            Section(header: Text("Players")) {
                ForEach($data.players) { $player in
                    HStack {
                        Circle()
                            .fill(player.theme.mainColor)
                            .frame(width: 12, height: 12)
                        Text(player.name)
                    }
                }
                .onDelete { indices in
                    data.players.remove(atOffsets: indices)
                }
                .onMove(perform: move)
                HStack {
                    TextField("New Player", text: $newPlayerName)
                        .accessibilityIdentifier("New Player")
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            addPlayer()
                        }
                        .submitLabel(.done)
                    Button(action: addPlayer) {
                        Image(systemName: "plus.circle.fill")
                            .accessibilityLabel("Add player")
                    }
                    .disabled(newPlayerName.isEmpty)
                }
            }
        }
        .onAppear {
            // Auto-focus title field when creating a new game
            if data.name.isEmpty {
                isTitleFieldFocused = true
            }
        }
    }
}

#Preview {
    @Previewable @State var data = Game.sampleData[1].data
    @Previewable @State var playerName = ""

    DetailEditView(data: $data, roundTimer: RoundTimer(), newPlayerName: $playerName)
}
