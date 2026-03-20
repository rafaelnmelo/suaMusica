import SwiftUI

struct TrackRowView: View {
    let track: Track
    let isPlaying: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .font(.headline)
                    .foregroundStyle(isPlaying ? Color.accentColor : Color.primary)
                Text(track.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isPlaying {
                Image(systemName: "waveform")
                    .foregroundStyle(.tint)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack {
        TrackRowView(track: Track.previews[0], isPlaying: true)
        TrackRowView(track: Track.previews[1], isPlaying: false)
    }
    .padding()
    .preferredColorScheme(.dark)
}
