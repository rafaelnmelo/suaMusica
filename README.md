# suaMusica

An iOS music player app built with SwiftUI and AVFoundation.

## Features

- Track list with album art
- Collapsible player sheet (mini and expanded views)
- Play, pause, previous, and next controls
- Seek bar with time labels
- Crossfade transition between tracks (toggleable)
- Background audio playback
- Lock screen / Control Center integration (Now Playing)

## Architecture

Clean Architecture with the following layers:

- **Presentation** — SwiftUI views (`HomeView`, `PlayerView`, `PlayerControlsView`, `TrackListView`)
- **Core** — `PlayerManager` (shared `ObservableObject` orchestrating playback)
- **Domain** — Use cases (`PlayTrackUseCase`, `CrossfadeToNextUseCase`) and repository protocol
- **Data** — `AVPlayerRepository` using dual `AVPlayer` instances for seamless crossfade

## Requirements

- iOS 17+
- Xcode 15+
