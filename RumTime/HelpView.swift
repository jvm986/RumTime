//
//  HelpView.swift
//  RumTime
//
//  Created by James Maguire on 20.11.25.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // App Icon
                Image("LaunchLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                // Title
                Text("Rum Time")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                // Description
                Text("A chess-style timer for Rummy. Players start with a time bank and receive incremental time each turn, allowing them to save time for complex moves rather than being locked to fixed turn durations.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                // Features
                VStack(alignment: .leading, spacing: 20) {
                    HelpItem(
                        icon: "plus.circle.fill",
                        title: "Create a Game",
                        description: "Tap the + button to create a new game. Add at least 2 players, set the starting time and turn bonus."
                    )

                    HelpItem(
                        icon: "timer",
                        title: "Start a Round",
                        description: "Tap 'Start Round' to begin. The timer will count down for each player's turn automatically."
                    )

                    HelpItem(
                        icon: "goforward.plus",
                        title: "Turn Bonus",
                        description: "When a player completes their turn, bonus time is added to help keep the game moving."
                    )

                    HelpItem(
                        icon: "person.slash",
                        title: "Pause Players",
                        description: "Tap a player's name to have them sit out for a round. They won't be included in the timer rotation."
                    )

                    HelpItem(
                        icon: "trophy.fill",
                        title: "End Round",
                        description: "When the round ends, select the winner and enter scores. The round will be saved to your game history."
                    )
                }
                .padding(.horizontal)

                // Support Link
                Link(destination: URL(string: "https://github.com/jvm986/RumTime")!) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Text("Visit Support Page")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()
                    .frame(height: 40)
            }
            .padding()
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpItem: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Theme.saffron.mainColor)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HelpView()
}
