//
//  GameDetailView.swift
//  RumTime
//
//  Created by James Maguire on 14/10/2022.
//

import SwiftData
import SwiftUI

struct DetailView: View {
    let game: Game
    var isNewGame: Bool = false
    var onSave: (() -> Void)? = nil
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss
    @State private var gameData = Game.Data()
    @State private var roundData = Round.Data()
    @State private var isPresentingScoreView = false
    @State private var showingDeleteConfirmation = false
    @State private var showingRoundsList = false
    @State private var editingPlayerIndex: Int?
    @State private var editPlayerName = ""
    @State var roundTimer = RoundTimer()
    @FocusState private var isGameNameFocused: Bool
    @FocusState private var isNewPlayerFieldFocused: Bool
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var playerSortMode: PlayerSortMode = .byOrder
    @State private var showingBackConfirmation = false
    @State private var shouldDismiss = false
    @State private var showingThemePicker = false

    enum PlayerSortMode {
        case byScore
        case byOrder
    }

    private var canSaveGame: Bool {
        let hasEnoughPlayers =
            gameData.players.count >= 2 || (gameData.players.count == 1 && !editPlayerName.isEmpty)
        return hasEnoughPlayers && !gameData.name.isEmpty && gameData.startingTime > 0
    }

    private var sortedPlayers: [Game.Data.PlayerData] {
        switch playerSortMode {
        case .byScore:
            if isNewGame {
                return gameData.players
            }
            // Sort by total score from the game
            return gameData.players.sorted { player1, player2 in
                let score1 = game.players.first(where: { $0.id == player1.id })?.totalScore() ?? 0
                let score2 = game.players.first(where: { $0.id == player2.id })?.totalScore() ?? 0
                return score1 > score2
            }
        case .byOrder:
            return gameData.players
        }
    }

    func addPlayer() {
        guard !editPlayerName.isEmpty else { return }

        let player = Game.Data.PlayerData(name: editPlayerName, theme: gameData.randomTheme)

        if reduceMotion {
            gameData.players.append(player)
            editPlayerName = ""
        } else {
            withAnimation {
                gameData.players.append(player)
                editPlayerName = ""
            }
        }

        // Update the game if in edit mode
        if !isNewGame {
            game.update(from: gameData)
        }

        // Keep focus on text field for adding next player
        isNewPlayerFieldFocused = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                Section {
                    HStack(spacing: 12) {
                        Button {
                            if isNewGame || !roundTimer.isActive {
                                showingThemePicker = true
                            }
                        } label: {
                            Circle()
                                .fill(gameData.theme.mainColor)
                                .frame(width: 32, height: 32)
                        }
                        .disabled(!isNewGame && roundTimer.isActive)

                        TextField("Game Name", text: $gameData.name, prompt: Text("Enter game name"))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .focused($isGameNameFocused)
                            .disabled(!isNewGame && roundTimer.isActive)
                            .onChange(of: gameData.name) { oldValue, newValue in
                                if !isNewGame {
                                    game.name = newValue
                                }
                            }
                    }
                }
                .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))

                Section(header: Text("Settings")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Start")
                            Slider(value: $gameData.startingTime, in: 15...300, step: 15) {
                                Text("Starting Time")
                            }
                            .accessibilityIdentifier("Starting Time Slider")
                            .disabled(!isNewGame && roundTimer.isActive)
                            .onChange(of: gameData.startingTime) { oldValue, newValue in
                                if !isNewGame {
                                    game.startingTime = Int(newValue)
                                }
                            }
                            Spacer()
                            Text(
                                String(
                                    format: "%02i:%02i", Int(gameData.startingTime) / 60 % 60,
                                    Int(gameData.startingTime) % 60)
                            )
                            .accessibilityHidden(true)
                        }
                        if isNewGame {
                            Text("Time each player starts with")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.bottom, -4)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Turn")
                            Slider(value: $gameData.turnBonus, in: 1...15, step: 1) {
                                Text("Turn Bonus")
                            }
                            .accessibilityValue("\(Int(gameData.turnBonus)) seconds")
                            .accessibilityIdentifier("Turn Bonus Slider")
                            .disabled(!isNewGame && roundTimer.isActive)
                            .onChange(of: gameData.turnBonus) { oldValue, newValue in
                                if !isNewGame {
                                    game.turnBonus = Int(newValue)
                                }
                            }
                            Spacer()
                            Text("\(Int(gameData.turnBonus))s")
                                .accessibilityHidden(true)
                        }
                        if isNewGame {
                            Text("Seconds added after each turn")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.bottom, -4)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: $gameData.winnerGetsSumOfLosersScores) {
                            Text("Sum Scoring")
                        }
                        .accessibilityIdentifier("Winner Scoring Toggle")
                        .disabled(!isNewGame && roundTimer.isActive)
                        .onChange(of: gameData.winnerGetsSumOfLosersScores) { oldValue, newValue in
                            if !isNewGame {
                                game.winnerGetsSumOfLosersScores = newValue
                            }
                        }
                        if isNewGame {
                            Text("Winner scores sum of losers' points")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.bottom, -4)
                        }
                    }
                }

                Section(header: HStack {
                    Text("Players")
                    if !isNewGame {
                        Spacer()
                        Button {
                            playerSortMode = playerSortMode == .byScore ? .byOrder : .byScore
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: playerSortMode == .byScore ? "arrow.up.arrow.down" : "list.number")
                                Text(playerSortMode == .byScore ? "By Score" : "By Order")
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        .disabled(roundTimer.isActive)
                    }
                }) {
                    if playerSortMode == .byOrder {
                        ForEach(sortedPlayers) { playerData in
                            Button {
                                if isNewGame || !roundTimer.isActive {
                                    if let index = gameData.players.firstIndex(where: { $0.id == playerData.id }) {
                                        editingPlayerIndex = index
                                    }
                                }
                            } label: {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(playerData.theme.mainColor)
                                            .frame(width: 32, height: 32)

                                        if !isNewGame,
                                            let player = game.players.first(where: {
                                                $0.id == playerData.id
                                            })
                                        {
                                            Image(
                                                systemName: player.isPaused
                                                    ? "person.slash.fill" : "person.fill"
                                            )
                                            .foregroundColor(.white)
                                            .font(.system(size: 14))
                                        } else {
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 14))
                                        }
                                    }

                                    HStack(spacing: 6) {
                                        Text(playerData.name)
                                            .foregroundColor(.primary)

                                        if !isNewGame,
                                            let player = game.players.first(where: {
                                                $0.id == playerData.id
                                            }), player.isPaused
                                        {
                                            Text("(Sitting Out)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }

                                    Spacer()

                                    if !isNewGame,
                                        let player = game.players.first(where: {
                                            $0.id == playerData.id
                                        })
                                    {
                                        Text("\(player.totalScore()) points")
                                            .foregroundColor(.secondary)
                                    }

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .opacity(
                                    !isNewGame
                                        && game.players.first(where: { $0.id == playerData.id })?
                                            .isPaused == true
                                        ? 0.6
                                        : 1.0
                                )
                            }
                            .disabled(roundTimer.isActive)
                        }
                        .onDelete { indices in
                            if isNewGame || !roundTimer.isActive {
                                // Map sorted indices back to original array indices
                                let idsToRemove = indices.map { sortedPlayers[$0].id }
                                gameData.players.removeAll { player in
                                    idsToRemove.contains(player.id)
                                }
                                if !isNewGame {
                                    game.update(from: gameData)
                                }
                            }
                        }
                        .onMove { source, destination in
                            if isNewGame || !roundTimer.isActive {
                                gameData.players.move(fromOffsets: source, toOffset: destination)
                                if !isNewGame {
                                    game.update(from: gameData)
                                }
                            }
                        }
                    } else {
                        ForEach(sortedPlayers) { playerData in
                            Button {
                                if isNewGame || !roundTimer.isActive {
                                    if let index = gameData.players.firstIndex(where: { $0.id == playerData.id }) {
                                        editingPlayerIndex = index
                                    }
                                }
                            } label: {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(playerData.theme.mainColor)
                                            .frame(width: 32, height: 32)

                                        if !isNewGame,
                                            let player = game.players.first(where: {
                                                $0.id == playerData.id
                                            })
                                        {
                                            Image(
                                                systemName: player.isPaused
                                                    ? "person.slash.fill" : "person.fill"
                                            )
                                            .foregroundColor(.white)
                                            .font(.system(size: 14))
                                        } else {
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 14))
                                        }
                                    }

                                    HStack(spacing: 6) {
                                        Text(playerData.name)
                                            .foregroundColor(.primary)

                                        if !isNewGame,
                                            let player = game.players.first(where: {
                                                $0.id == playerData.id
                                            }), player.isPaused
                                        {
                                            Text("(Sitting Out)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }

                                    Spacer()

                                    if !isNewGame,
                                        let player = game.players.first(where: {
                                            $0.id == playerData.id
                                        })
                                    {
                                        Text("\(player.totalScore()) points")
                                            .foregroundColor(.secondary)
                                    }

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .opacity(
                                    !isNewGame
                                        && game.players.first(where: { $0.id == playerData.id })?
                                            .isPaused == true
                                        ? 0.6
                                        : 1.0
                                )
                            }
                            .disabled(roundTimer.isActive)
                        }
                        .onDelete { indices in
                            if isNewGame || !roundTimer.isActive {
                                // Map sorted indices back to original array indices
                                let idsToRemove = indices.map { sortedPlayers[$0].id }
                                gameData.players.removeAll { player in
                                    idsToRemove.contains(player.id)
                                }
                                if !isNewGame {
                                    game.update(from: gameData)
                                }
                            }
                        }
                    }

                    // Add player field
                    HStack {
                        TextField("New Player", text: $editPlayerName)
                            .focused($isNewPlayerFieldFocused)
                            .disabled(!isNewGame && roundTimer.isActive)
                            .onSubmit {
                                addPlayer()
                            }
                            .submitLabel(.done)
                        Button(action: addPlayer) {
                            Image(systemName: "plus.circle.fill")
                                .accessibilityLabel("Add player")
                        }
                        .disabled(editPlayerName.isEmpty || (!isNewGame && roundTimer.isActive))
                    }
                }
            }
            .navigationTitle(isNewGame ? "New Game" : "")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(roundTimer.isActive && !isNewGame)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                if !isNewGame && roundTimer.isActive {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showingBackConfirmation = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                            }
                        }
                    }
                }

                if isNewGame {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Create") {
                            // Add the unsaved player if there's one in the text field
                            if !editPlayerName.isEmpty {
                                let playerData = Game.Data.PlayerData(
                                    name: editPlayerName, theme: gameData.randomTheme)
                                gameData.players.append(playerData)
                            }

                            game.update(from: gameData)
                            modelContext.insert(game)
                            onSave?()
                            dismiss()
                        }
                        .disabled(!canSaveGame)
                    }
                } else {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button {
                                showingRoundsList = true
                            } label: {
                                Label("Round History", systemImage: "list.bullet")
                            }

                            Divider()

                            Button(role: .destructive) {
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Delete Game", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                        }
                        .accessibilityLabel("More options")
                    }
                }
            }
            .interactiveDismissDisabled(roundTimer.isActive && !isNewGame)
            .onChange(of: shouldDismiss) { oldValue, newValue in
                if newValue {
                    dismiss()
                }
            }
            .alert("Delete Game?", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(game)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(
                    "Are you sure you want to delete \"\(game.name)\"? This action cannot be undone."
                )
            }
            .alert("Leave Round?", isPresented: $showingBackConfirmation) {
                Button("Leave", role: .destructive) {
                    shouldDismiss = true
                }
                Button("Stay", role: .cancel) {}
            } message: {
                Text("The current round is in progress and will be lost if you leave. Are you sure?")
            }
            .fullScreenCover(isPresented: isNewGame ? .constant(false) : $roundTimer.isPaused.not) {
                if !isNewGame {
                    RoundTimerView(
                        game: game,
                        roundTimer: roundTimer,
                        onPause: {
                            roundTimer.pauseRound()
                        },
                        onEnd: {
                            roundData.scores = game.createScores()
                            roundData.setWinner(id: roundTimer.activePlayerObj.id)
                            roundTimer.pauseRound()
                            isPresentingScoreView = true
                        }
                    )
                    .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
                    .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
                }
            }
            .sheet(isPresented: isNewGame ? .constant(false) : $isPresentingScoreView) {
                if !isNewGame {
                    ScoreView(
                        round: $roundData,
                        onDelete: {
                            isPresentingScoreView = false
                            roundTimer.stopRound()
                        },
                        onResume: {
                            isPresentingScoreView = false
                            roundTimer.unpauseGame()
                        },
                        onRecord: {
                            roundTimer.reset(
                                startingTime: game.startingTime, turnBonus: game.turnBonus,
                                players: game.unpausedPlayers, starter: game.unpausedStarter)
                            game.addRound(from: roundData)
                            isPresentingScoreView = false
                        }
                    )
                }
            }
            .sheet(isPresented: isNewGame ? .constant(false) : $showingRoundsList) {
                if !isNewGame {
                    RoundListView(game: game)
                }
            }
            .sheet(isPresented: $showingThemePicker) {
                ThemePickerSheet(selectedTheme: $gameData.theme)
                    .onChange(of: gameData.theme) { oldValue, newValue in
                        if !isNewGame {
                            game.theme = newValue
                        }
                    }
            }
            .sheet(
                isPresented: Binding(
                    get: { editingPlayerIndex != nil },
                    set: {
                        if !$0 {
                            // Save changes when sheet dismisses
                            if let index = editingPlayerIndex,
                                let player = game.players.first(where: {
                                    $0.id == gameData.players[index].id
                                })
                            {
                                player.name = gameData.players[index].name
                                player.theme = gameData.players[index].theme
                                player.isPaused = gameData.players[index].isPaused
                                // Reset round timer if pause state changed
                                if !isNewGame {
                                    roundTimer.reset(
                                        startingTime: game.startingTime, turnBonus: game.turnBonus,
                                        players: game.unpausedPlayers, starter: game.unpausedStarter
                                    )
                                }
                            }
                            editingPlayerIndex = nil
                        }
                    }
                )
            ) {
                if let index = editingPlayerIndex {
                    ColorPickerSheet(
                        playerName: $gameData.players[index].name,
                        selectedColor: $gameData.players[index].theme,
                        isPaused: $gameData.players[index].isPaused,
                        showPauseToggle: !isNewGame,
                        allPlayers: gameData.players,
                        currentPlayerId: gameData.players[index].id
                    )
                }
            }
            .onAppear {
                gameData = game.data
                if isNewGame && gameData.name.isEmpty {
                    isGameNameFocused = true
                }
            }
            .onChange(of: scenePhase) { oldValue, newValue in
                if newValue == .inactive && !isNewGame {
                    roundTimer.pauseRound()
                }
            }

            // Floating Start Round Button
            if !isNewGame {
                if roundTimer.isActive {
                    Button {
                        roundTimer.unpauseGame()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Resume Round")
                                .font(.callout)
                                .fontWeight(.semibold)
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(roundTimer.activePlayerObj.name)
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                        .background(
                            ZStack {
                                Capsule()
                                    .fill(roundTimer.activeTheme.mainColor)
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            }
                        )
                        .foregroundColor(.primary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                } else if !game.unpausedPlayers.isEmpty
                    && game.unpausedStarter < game.unpausedPlayers.count
                {
                    Button {
                        roundTimer.reset(
                            startingTime: game.startingTime,
                            turnBonus: game.turnBonus,
                            players: game.unpausedPlayers,
                            starter: game.unpausedStarter
                        )
                        roundTimer.unpauseGame()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Start Round")
                                .font(.callout)
                                .fontWeight(.semibold)
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(game.unpausedPlayers[game.unpausedStarter].name)
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                        .background(
                            ZStack {
                                Capsule()
                                    .fill(
                                        game.unpausedPlayers[game.unpausedStarter].theme.mainColor)
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            }
                        )
                        .foregroundColor(.primary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
        }
    }
}

struct ColorPickerSheet: View {
    @Binding var playerName: String
    @Binding var selectedColor: Theme
    @Binding var isPaused: Bool
    var showPauseToggle: Bool = false
    var allPlayers: [Game.Data.PlayerData] = []
    var currentPlayerId: UUID = UUID()
    @Environment(\.dismiss) private var dismiss

    let columns = Array(repeating: GridItem(.flexible()), count: 5)

    // Dynamically calculate if the toggle can be changed
    private var canTogglePause: Bool {
        // If player is currently paused, they can always be unpaused
        if isPaused {
            return true
        }
        // If player is active, count how many other players are also active
        let activeCount = allPlayers.filter { player in
            player.id != currentPlayerId && !player.isPaused
        }.count
        // Can only pause if there will be at least 2 active players remaining
        return activeCount >= 2
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Player Name
                    TextField("Enter name", text: $playerName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.plain)
                        .padding(.top, 8)

                    // Color Selection
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(Theme.allCases) { theme in
                            Button {
                                selectedColor = theme
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(theme.mainColor)
                                        .frame(width: 60, height: 60)

                                    if selectedColor == theme {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(theme.accentColor)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    // Pause Toggle
                    if showPauseToggle {
                        VStack(spacing: 8) {
                            Toggle(isOn: $isPaused) {
                                HStack {
                                    Image(
                                        systemName: isPaused ? "person.slash.fill" : "person.fill"
                                    )
                                    .foregroundColor(.secondary)
                                    Text("Sitting Out")
                                        .font(.body)
                                }
                            }
                            .disabled(!canTogglePause)

                            if !canTogglePause {
                                Text("At least 2 players must be active")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

struct ThemePickerSheet: View {
    @Binding var selectedTheme: Theme
    @Environment(\.dismiss) private var dismiss

    let columns = Array(repeating: GridItem(.flexible()), count: 5)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Title
                    Text("Game Color")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 8)

                    // Color Selection
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(Theme.allCases) { theme in
                            Button {
                                selectedTheme = theme
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(theme.mainColor)
                                        .frame(width: 60, height: 60)

                                    if selectedTheme == theme {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(theme.accentColor)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    do {
        let container = try ModelContainer(
            for: Game.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let game = Game.sampleData[1]
        container.mainContext.insert(game)

        return NavigationView {
            DetailView(game: game)
        }
        .modelContainer(container)
    } catch {
        return Text("Failed to create preview")
    }
}
