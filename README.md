# RumTime

A chess-style timer for Rummy. Players start with a time bank and receive incremental time each turn, allowing them to save time for complex moves rather than being locked to fixed turn durations.

## Technical Stack

- **Language**: Swift 6.0
- **Framework**: SwiftUI
- **Minimum iOS**: 26.1
- **Persistence**: SwiftData
- **Architecture**: MVVM with SwiftData models
- **Testing**: XCTest unit and UI tests

## Testing

```bash
# All tests
xcodebuild test -project RumTime.xcodeproj -scheme RumTime -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1'

# Unit tests only
xcodebuild test -project RumTime.xcodeproj -scheme RumTime -only-testing:RumTimeTests -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1'

# UI tests only
xcodebuild test -project RumTime.xcodeproj -scheme RumTime -only-testing:RumTimeUITests -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.1'
```

## Development

See [ROADMAP.md](ROADMAP.md)

## Requirements

- Xcode 16.0+
- iOS 26.1+
- Swift 6.0+

## Architecture

The app uses SwiftData for persistence with the following model structure:

- **Game**: Top-level model with cascade delete rules, independent theme color
- **Player**: Individual player with theme color, name, and pause state
- **Round**: Completed round with date and scores
- **Score**: Individual player score within a round
- **RoundTimer**: Observable class managing active timer state (not persisted)

## Author

James Maguire
