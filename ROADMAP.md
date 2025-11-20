# RumTime - Portfolio & App Store Roadmap

## Project Status

**Current Version:** 1.0 (Build 3)
**Target:** App Store Release + Portfolio Showcase
**Started:** 2025-11-18
**Major Migration:** Migrated to SwiftData (November 2025)

### Overall Progress
- [x] Phase 1: Code Quality & Polish (5/5) - Complete
- [ ] Phase 2: User Experience (0/4)
- [ ] Phase 3: Legal & App Store Prep (0/3)
- [ ] Phase 4: Portfolio Presentation (0/3)

---

## Phase 1: Code Quality & Polish (Foundation)

### 1.1 Fix Bugs and Inconsistencies
- [x] Fix accessibility label in `GamesView.swift:37` ("New Scrum" → "New Game")
- [x] Audit all user-facing strings for consistency
- [ ] Review and fix any hardcoded values
- [x] Add comprehensive code documentation/comments
- [ ] Ensure consistent naming conventions throughout

### 1.2 Add Testing Infrastructure
- [x] Set up XCTest framework
- [x] Consolidate test targets into single `RumTimeTests` target
- [x] Unit tests for `Game` model (9 tests)
  - [x] Player scoring logic
  - [x] Round management
  - [x] Paused player handling
- [x] Unit tests for `RoundTimer` (17 tests)
  - [x] Timer countdown logic
  - [x] Turn switching
  - [x] Bonus time application
- [x] Unit tests for `GameStore` (6 tests)
  - [x] Save functionality
  - [x] Load functionality
  - [x] Error handling
- [x] UI tests for critical flows
  - [x] Comprehensive flow test (covers game creation, validation, round management, score recording, winner selection, deletion)
  - [x] Consolidated from 7 separate tests into single flow test for faster execution
  - [x] Removed performance/launch tests (unnecessary for lightweight app)
- [x] Aim for >80% code coverage (32 unit tests + 1 comprehensive UI test passing, 79% coverage achieved)

### 1.3 Improve Error Handling
- [x] Replace sample data fallback with proper empty state
- [x] Add user-friendly error messages
- [x] Implement retry mechanisms for failed saves
- [x] Add loading states for async operations
- [x] Handle edge cases (0 players, negative scores, etc.)

### 1.4 Enhance Accessibility
- [x] Complete VoiceOver support for all views
- [x] Add accessibility labels to all interactive elements
- [x] Add accessibility hints where helpful
- [x] Test with VoiceOver enabled (build verified)
- [x] Support Dynamic Type (text sizing)
- [x] Verify color contrast meets WCAG AA standards
- [x] Add reduce motion support for animations

### 1.5 Migrate to SwiftData
- [x] Convert Game model from struct to @Model class
- [x] Convert Player from nested struct to top-level @Model class
- [x] Convert Round from struct to @Model class
- [x] Convert Score from nested struct to top-level @Model class
- [x] Update RoundTimer to use @Observable macro (non-persisted)
- [x] Replace GameStore with ModelContainer/ModelContext
- [x] Configure cascade delete rules for data integrity
- [x] Update all views to use @Query and @Environment(\.modelContext)
- [x] Migrate all 32 unit tests to work with SwiftData
- [x] Create PersistenceTests to replace GameStoreTests
- [x] Update UI test for SwiftData compatibility
- [x] Fix deletion logic to use modelContext.delete() instead of array manipulation
- [x] Add centralized logging with AppLogger
- [x] Update iOS deployment target to 26.1

---

## Phase 2: User Experience (App Store Requirements)

### 2.1 Onboarding Flow
- [ ] Design first-launch welcome screen
- [ ] Create interactive tutorial
- [ ] Add quick tips overlay for game setup
- [ ] Include example game walkthrough
- [ ] Add "What's New" screen for updates
- [ ] Store onboarding completion flag

### 2.2 Help & Documentation
- [ ] Create in-app help section
- [ ] Add rule explanations for Rummy/Rummikub
- [ ] Document timer mechanics
- [ ] Create FAQ for common issues
- [ ] Add contextual help buttons
- [ ] Include video tutorials or animated guides

### 2.3 User Feedback Improvements
- [ ] Add haptic feedback for:
  - [ ] Timer start/end
  - [ ] Turn switches
  - [ ] Button presses
  - [ ] Time running out warning
- [ ] Improve visual feedback for timer states
- [ ] Add confirmation dialogs for:
  - [ ] Deleting games
  - [ ] Deleting rounds
  - [ ] Ending rounds prematurely
- [ ] Add undo functionality for accidental deletions
- [ ] Improve loading indicators

### 2.4 Feature Refinements
- [x] Improve winner selection in ScoreView
  - [x] Make winner selection more discoverable (currently tap-on-name is unclear)
  - [x] Add visual affordance (picker, radio buttons, or selection indicator)
  - [x] Consider Button style with clear interaction pattern
- [x] Enhance player addition UX in DetailEditView
  - [x] Add keyboard shortcut (Return/Enter) to add player
  - [x] Keep plus button as backup for discoverability
  - [x] Consider auto-focus after adding player
- [x] Polish UI with rounded card styling
  - [x] Applied consistent rounded corners to game cards, player cards, and rounds
  - [x] Improved empty state with custom icon
  - [x] Added floating action button for starting rounds
- [ ] Multi-step game creation flow
  - [ ] Step 1: Game name and optional description
  - [ ] Step 2: Timer settings (starting time + turn bonus)
  - [ ] Step 3: Add players
  - [ ] Show progress indicator across steps
  - [ ] Improve first-time user experience
- [x] Add game duplication feature
  - [x] Swipe action or context menu with "Duplicate" option
  - [x] Copies game settings and player list
  - [x] Useful for tournaments and repeat games
- [ ] Add ability to edit existing rounds
- [ ] Export game history (CSV, PDF, or share)
- [ ] Customizable sound alerts
  - [ ] Multiple alert sounds
  - [ ] Volume control
  - [ ] Option to disable
- [ ] iPad-specific optimizations
  - [ ] Multi-column layouts
  - [ ] Split view support
  - [ ] Keyboard shortcuts
- [ ] Dark mode optimization
- [ ] Landscape mode improvements
- [ ] Add game statistics/analytics view

---

## Phase 3: Legal & App Store Prep

### 3.1 Legal Requirements
- [ ] Create privacy policy
  - [ ] Detail data collection (local storage only)
  - [ ] Explain data usage
  - [ ] User rights and data deletion
- [ ] Add privacy policy link to app
- [ ] Create terms of service (if needed)
- [ ] Review App Store Review Guidelines compliance
- [ ] Add required export compliance info
- [ ] Age rating assessment

### 3.2 App Store Assets
- [ ] Professional app icon (all sizes)
- [ ] Screenshots for all device sizes:
  - [ ] iPhone 6.7" (Pro Max)
  - [ ] iPhone 6.5" (Plus)
  - [ ] iPhone 5.5" (older devices)
  - [ ] iPad Pro 12.9" (6th gen)
  - [ ] iPad Pro 12.9" (2nd gen)
- [ ] App preview video (optional but recommended)
  - [ ] 15-30 second demo
  - [ ] Show key features
- [ ] Compelling app description
  - [ ] Clear value proposition
  - [ ] Feature list
  - [ ] Target audience
- [ ] Keywords research and optimization
- [ ] Promotional text (170 chars)
- [ ] Support URL
- [ ] Marketing URL (optional)

### 3.3 Technical Preparation
- [ ] Test on multiple device sizes
- [ ] Test on different iOS versions (minimum supported)
- [ ] Performance testing
- [ ] Memory leak detection
- [ ] Battery usage optimization
- [ ] App size optimization
- [ ] Create TestFlight beta program
- [ ] Beta test with friends/family

---

## Phase 4: Portfolio Presentation

### 4.1 Documentation
- [ ] Enhance README.md
  - [ ] Add hero image/banner
  - [ ] Feature highlights with screenshots
  - [ ] Technology stack
  - [ ] Installation instructions
- [ ] Create ARCHITECTURE.md
  - [ ] App architecture overview
  - [ ] SwiftUI patterns used
  - [ ] State management approach
  - [ ] Data persistence strategy
- [ ] Document development journey
  - [ ] Technical decisions made
  - [ ] Challenges overcome
  - [ ] Performance optimizations
  - [ ] Lessons learned
- [ ] Add code comments for complex logic
- [ ] Create API documentation (if applicable)

### 4.2 Code Showcase
- [ ] Highlight interesting technical solutions
  - [ ] Custom timer implementation
  - [ ] Turn-based state management
  - [ ] Theme system
- [ ] Document SwiftUI best practices
- [ ] Explain architecture decisions
- [ ] Show testing strategy
- [ ] Add code examples to README
- [ ] Create technical blog post (optional)

### 4.3 CI/CD Setup
- [ ] Set up GitHub Actions
  - [ ] Run tests on push
  - [ ] Build verification
  - [ ] Code coverage reporting
- [ ] Add code quality checks
  - [ ] SwiftLint configuration
  - [ ] Static analysis
- [ ] Add status badges to README
- [ ] Automated deployment to TestFlight (optional)
- [ ] Automated release notes generation

---

## Marketing & Launch Preparation

### Optional Enhancements
- [ ] Create landing page/website
- [ ] Demo video for portfolio
- [ ] Social media presence setup
- [ ] Press kit preparation
- [ ] App Store Optimization (ASO) research
- [ ] Launch strategy planning
- [ ] Community building (Discord, Reddit, etc.)

---

## Notes & Ideas

### Feature Ideas for Future Versions
- iCloud sync across devices
- Multiplayer sync (turn notifications)
- Apple Watch companion app
- Widgets for active games
- Game templates (Quick, Tournament, Custom)
- Player profiles with avatars
- Achievements/badges
- Tournament mode with brackets
- Custom themes creator
- Sound pack marketplace

### Technical Debt
- [ ] Review force unwrapping in codebase
- [ ] Optimize asset sizes
- [ ] Review and update dependencies
- ~~[ ] Modernize deprecated APIs~~ ✅ Updated to iOS 26.1 with latest SwiftData patterns

### Migration History
**SwiftData Migration (November 2025)**
- Migrated from JSON file-based persistence to SwiftData
- Converted nested structs to top-level @Model classes for SwiftData compatibility
- Replaced ObservableObject with @Observable macro
- Eliminated manual save calls (SwiftData auto-saves)
- Updated all tests for SwiftData compatibility
- Benefits:
  - Automatic persistence with ModelContext
  - Cascade delete rules prevent orphaned data
  - Better performance with optimized queries
  - Type-safe relationships between models
  - Eliminated save/load error handling complexity

---

## Timeline Estimates

- **Phase 1:** 1-2 weeks
- **Phase 2:** 2-3 weeks
- **Phase 3:** 1-2 weeks
- **Phase 4:** 1 week
- **Total Estimated Time:** 5-8 weeks (part-time)

## Success Criteria

✅ **Portfolio Ready:**
- Clean, well-documented code
- Comprehensive test coverage
- Professional README
- Demonstrates best practices

✅ **App Store Ready:**
- Passes all review guidelines
- Professional assets complete
- Legal requirements met
- Beta tested and polished

✅ **User Ready:**
- Intuitive onboarding
- Accessible to all users
- Stable and performant
- Delightful user experience
