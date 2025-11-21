//
//  HelpView.swift
//  RumTime
//
//  Created by James Maguire on 20.11.25.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("About RumTime")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("RumTime helps you manage timed Rummy games with ease. Track players, manage rounds, and keep score all in one place.")
                            .font(.body)
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text("How to Use")) {
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

                Section(header: Text("Basic Rummy Rules")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("**Objective**")
                            .font(.headline)
                        Text("Be the first to arrange all your cards into valid sets and runs.")
                            .font(.body)

                        Divider()
                            .padding(.vertical, 4)

                        Text("**Sets**")
                            .font(.headline)
                        Text("3 or 4 cards of the same rank (e.g., 7♠ 7♥ 7♦)")
                            .font(.body)

                        Divider()
                            .padding(.vertical, 4)

                        Text("**Runs**")
                            .font(.headline)
                        Text("3+ cards of the same suit in sequence (e.g., 4♠ 5♠ 6♠)")
                            .font(.body)

                        Divider()
                            .padding(.vertical, 4)

                        Text("**Winning**")
                            .font(.headline)
                        Text("Arrange all cards into valid sets/runs and discard your final card to win the round.")
                            .font(.body)
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text("Support")) {
                    Link(destination: URL(string: "https://github.com/jvm986/RumTime")!) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("Visit Support Page")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
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
                .foregroundColor(.accentColor)
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
