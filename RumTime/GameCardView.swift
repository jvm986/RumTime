//
//  GameCardView.swift
//  RumTime
//
//  Created by James Maguire on 14/10/2022.
//

import SwiftUI

struct GameCardView: View {
    let game: Game

    var body: some View {
        VStack(alignment: .leading) {
            Text(game.name)
                .accessibilityAddTraits(.isHeader)
                .font(.headline)
            Spacer()
            HStack {
                Label("\(game.players.count)", systemImage: "person.3")
                    .accessibilityLabel("\(game.players.count) players")
                Spacer()
                Label("\(game.startingTimeString)", systemImage: "clock")
                    .accessibilityLabel("\(game.startingTime) starting time")
            }
            .font(.caption)
        }
        .padding()
        .frame(minHeight: 80)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(game.theme.mainColor)
        .foregroundColor(game.theme.accentColor)
        .cornerRadius(10)
    }
}

struct CardView_Previews: PreviewProvider {
    static var game = Game.sampleData[0]
    static var previews: some View {
        GameCardView(game: game)
            .background(game.theme.mainColor)
            .frame(height: 100)
    }
}

