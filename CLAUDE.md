# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a SwiftUI iOS application called "study-timer" - a study time tracking application that allows users to monitor their study sessions across different categories (Maths, Info, Stats) with timer functionality and visual reporting through pie charts.

## Development Commands

### Building and Running
```bash
# Open project in Xcode
open study-timer.xcodeproj

# Build from command line
xcodebuild -project study-timer.xcodeproj -scheme study-timer -configuration Debug build

# Build for release
xcodebuild -project study-timer.xcodeproj -scheme study-timer -configuration Release build
```

### Testing
The project currently does not have a dedicated test suite configured. Tests would typically be run via:
```bash
xcodebuild test -project study-timer.xcodeproj -scheme study-timer -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Architecture

### Application Structure
- **Entry Point**: `study_timerApp.swift` - Main app file that launches `MainTabView`
- **Navigation**: `MainTabView.swift` - TabView with three tabs: Statistics (Accueil), Create, and Settings
- **Core Views**:
  - `Accueil.swift` - Main dashboard showing study time statistics with pie charts for daily, weekly, and monthly data
  - `TimerView.swift` - Timer functionality for tracking study sessions
- **Data Models**: `Categories.swift` - Simple struct for study categories with name and time spent

### Key Technologies
- **SwiftUI** for UI framework
- **Charts** framework for pie chart visualizations
- **SwiftData** imported but not yet implemented for data persistence
- **Timer** for countdown/countup functionality

### Project Configuration
- **Target**: iOS app with universal device family support (iPhone and iPad)
- **Deployment Target**: iOS 26.0
- **Bundle ID**: com.jeune-sim.study-timer
- **Development Team**: M23F32HG62
- **Swift Version**: 5.0 with modern concurrency features enabled

### Current Implementation Status
- Basic timer functionality with start/stop/reset/save capabilities
- Static data visualization (hardcoded category data)
- UI structure in place but Create and Settings tabs not implemented
- No data persistence implemented yet (SwiftData imported but unused)

### File Organization
```
study-timer/
├── study_timerApp.swift          # App entry point
├── Views/
│   ├── MainTabView.swift         # Main tab navigation
│   ├── Accueil.swift            # Dashboard with charts
│   └── TimerView.swift          # Timer functionality
├── Categories.swift              # Data model
└── Assets.xcassets/             # App icons and colors
```

## Notes for Development
- The app is currently in French (UI text in French)
- Timer functionality is basic but functional
- Charts display static data - needs integration with actual timer data
- SwiftData integration is planned but not implemented
- Two tabs (Create and Settings) show placeholder text and need implementation