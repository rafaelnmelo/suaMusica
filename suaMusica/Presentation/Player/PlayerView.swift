import SwiftUI

struct PlayerView: View {
    @ObservedObject var manager: PlayerManager
    let isExpanded: Bool

    var body: some View {
        VStack(spacing: 12) {
            if isExpanded { expandedInfo } else { collapsedInfo }
            PlayerControlsView(manager: manager)
        }
    }

    private var expandedInfo: some View {
        VStack(spacing: 12) {
            Text(manager.currentTrack?.title ?? "-")
                .font(.headline)
                .foregroundStyle(.white)
            Text(manager.currentTrack?.artist ?? "-")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Slider(value: $manager.progress, in: 0...max(manager.duration, 1)) { editing in
                if !editing { manager.seek(to: manager.progress) }
            }
            .tint(.white)
            progressLabels
        }
    }

    private var progressLabels: some View {
        HStack {
            Text(manager.progress.formattedAsTime)
            Spacer()
            Text(manager.duration.formattedAsTime)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private var collapsedInfo: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(manager.currentTrack?.title ?? "-")
                    .font(.subheadline).bold()
                    .foregroundStyle(.white)
                Text(manager.currentTrack?.artist ?? "-")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

#Preview("Colapsado") {
    PlayerView(manager: PlayerManager.shared, isExpanded: false)
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
}

#Preview("Expandido") {
    PlayerView(manager: PlayerManager.shared, isExpanded: true)
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
}
