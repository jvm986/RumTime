//
//  GameDetailEditView.swift
//  RumTime
//
//  Created by James Maguire on 14/10/2022.
//

import SwiftUI

struct DetailEditView: View {
    @Binding var data: Game.Data
    @State private var newPlayerName = ""
    @State private var newPlayerTheme = Theme.seafoam
    
    func move(from source: IndexSet, to destination: Int) {
        data.players.move(fromOffsets: source, toOffset: destination)
    }
    
    var minutes: Int {
        Int(data.startingTime) / 60 % 60
    }

    var seconds: Int {
        Int(data.startingTime) % 60
    }

    
    var body: some View {
        Form {
            Section(header: Text("Game Info")) {
                TextField("Title", text: $data.name)
                HStack {
                    Text("Start")
                    Slider(value: $data.startingTime, in: 15...300, step: 15) {
                        Text("Starting Time")
                    }
                    Spacer()
                    Text(String(format: "%02i:%02i", minutes, seconds))
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
            Section(header: Text("Players")) {
                ForEach($data.players) { $player in
                    ThemePicker(title: player.name, selection: $player.theme)
                }
                .onDelete { indices in
                    data.players.remove(atOffsets: indices)
                }
                .onMove(perform: move)
                HStack {
                    TextField("New Player", text: $newPlayerName)
                    Button(action: {
                        withAnimation {
                            let player = Game.Player(name: newPlayerName, theme: newPlayerTheme)
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
        }
    }
}

struct DetailEditView_Previews: PreviewProvider {
    static var previews: some View {
        DetailEditView(data: .constant(Game.sampleData[1].data))
    }
}
