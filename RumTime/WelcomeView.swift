//
//  WelcomeView.swift
//  RumTime
//
//  Created by James Maguire on 20.11.25.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // App Icon or Logo
            Image(systemName: "timer.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor)

            // Welcome Title
            Text("Welcome to RumTime")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            // Description
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(icon: "timer", title: "Track Game Time", description: "Use the built-in timer to keep rounds moving smoothly")

                FeatureRow(icon: "person.3.fill", title: "Manage Players", description: "Add players, track scores, and see who's winning")

                FeatureRow(icon: "trophy.fill", title: "Record Winners", description: "Save round results and track game history")
            }
            .padding(.horizontal)

            Spacer()

            // Get Started Button
            Button {
                isPresented = false
            } label: {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    WelcomeView(isPresented: .constant(true))
}
