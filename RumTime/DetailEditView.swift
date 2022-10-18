//
//  GameDetailEditView.swift
//  RumTime
//
//  Created by James Maguire on 14/10/2022.
//

import SwiftUI

struct DetailEditView: View {
    @Binding var data: Game.Data
    @StateObject var roundTimer: RoundTimer
    @State private var newPlayerName = ""
    
    func move(from source: IndexSet, to destination: Int) {
        data.players.move(fromOffsets: source, toOffset: destination)
        data.starter = 0
        roundTimer.reset(startingTime: Int(data.startingTime), turnBonus: Int(data.turnBonus), players: data.players, starter: 0)
    }

    
    var body: some View {
        Form {
            Section(header: Text("Players")) {
                ForEach($data.players) { $player in
                    Text(player.name)
                }
                .onDelete { indices in
                    data.players.remove(atOffsets: indices)
                }
                .onMove(perform: move)
                HStack {
                    TextField("New Player", text: $newPlayerName)
                    Button(action: {
                        withAnimation {
                            let player = Game.Player(name: newPlayerName, theme: data.randomTheme)
                            data.players.append(player)
                            newPlayerName = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .accessibilityLabel("Add player")
                    }
                    .disabled(newPlayerName.isEmpty)
                }
            }
            Section(header: Text("Game Info")) {
                TextField("Title", text: $data.name)
                HStack {
                    Text("Start")
                    Slider(value: $data.startingTime, in: 15...300, step: 15) {
                        Text("Starting Time")
                    }
                    Spacer()
                    Text(String(format: "%02i:%02i", Int(data.startingTime) / 60 % 60, Int(data.startingTime) % 60))
                        .accessibilityHidden(true)
                }
                HStack {
                    Text("Turn")
                    Slider(value: $data.turnBonus, in: 1...30, step: 1) {
                        Text("Turn Bonus")
                    }
                    .accessibilityValue("\(Int(data.turnBonus)) seconds")
                    Spacer()
                    Text("\(Int(data.turnBonus))s")
                        .accessibilityHidden(true)
                }
            }
        }
    }
}

struct DetailEditView_Previews: PreviewProvider {
    static var previews: some View {
        DetailEditView(data: .constant(Game.sampleData[1].data), roundTimer: RoundTimer())
    }
}
