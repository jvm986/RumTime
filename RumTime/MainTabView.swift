//
//  MainTabView.swift
//  RumTime
//
//  Created by James Maguire on 25.11.25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                GamesView()
            }
            .tabItem {
                Label("Games", systemImage: "timer")
            }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MainTabView()
}
