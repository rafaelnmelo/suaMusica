import SwiftUI

struct PlayerView: View {
    @ObservedObject var manager: PlayerManager
    let isExpanded: Bool

    var body: some View {
        VStack(spacing: 12) {
            if isExpanded {
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

                HStack {
                    Text(manager.progress.formattedAsTime)
                    Spacer()
                    Text(manager.duration.formattedAsTime)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            } else {
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

            PlayerControlsView(manager: manager)
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
