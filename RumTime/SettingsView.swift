//
//  SettingsView.swift
//  RumTime
//
//  Created by James Maguire on 25.11.25.
//

import SwiftUI

struct SettingsView: View {
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        HelpView()
                    } label: {
                        Label {
                            Text("Help")
                        } icon: {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundStyle(.saffron)
                        }
                    }

                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label {
                            Text("Privacy Policy")
                        } icon: {
                            Image(systemName: "hand.raised.fill")
                                .foregroundStyle(.saffron)
                        }
                    }
                } header: {
                    Text("Information")
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
