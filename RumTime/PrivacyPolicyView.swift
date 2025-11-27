//
//  PrivacyPolicyView.swift
//  RumTime
//
//  Created by James Maguire on 20.11.25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Group {
                        Text("Privacy Policy")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Last Updated: November 2025")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Divider()
                    }

                    Group {
                        SectionHeader(title: "Data Collection")
                        Text(
                            "RumTime does not collect, store, or transmit any personal data to external servers. All game data, including player names, scores, and game history, is stored locally on your device only."
                        )
                    }

                    Group {
                        SectionHeader(title: "Local Storage")
                        Text("The following information is stored locally on your device:")
                        BulletPoint(text: "Game names and settings")
                        BulletPoint(text: "Player names")
                        BulletPoint(text: "Round history and scores")
                        BulletPoint(text: "App preferences")
                        Text(
                            "This data remains on your device and is never shared with third parties or transmitted over the internet."
                        )
                        .italic()
                    }

                    Group {
                        SectionHeader(title: "No Third-Party Services")
                        Text(
                            "RumTime does not use any third-party analytics, advertising, or tracking services. Your gameplay remains completely private."
                        )
                    }

                    Group {
                        SectionHeader(title: "Data Deletion")
                        Text("You can delete any game data at any time by:")
                        BulletPoint(
                            text: "Deleting players, games or rounds individually within the app")
                        BulletPoint(text: "Uninstalling the app (removes all local data)")
                    }

                    Group {
                        SectionHeader(title: "Children's Privacy")
                        Text(
                            "RumTime does not knowingly collect any data from children or adults. The app is designed to work entirely offline with local storage only."
                        )
                    }

                    Group {
                        SectionHeader(title: "Changes to This Policy")
                        Text(
                            "We may update this privacy policy from time to time. Any changes will be reflected in the app and on our support page."
                        )
                    }

                    Group {
                        SectionHeader(title: "Contact")
                        Text(
                            "If you have any questions about this privacy policy, please visit our support page:"
                        )
                        Link(
                            "github.com/jvm986/RumTime",
                            destination: URL(string: "https://github.com/jvm986/RumTime")!
                        )
                        .font(.footnote)
                    }
                }
                .padding()
            }
            .navigationTitle("Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
    }
}

struct BulletPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
        }
        .padding(.leading, 8)
    }
}

#Preview {
    PrivacyPolicyView()
}
