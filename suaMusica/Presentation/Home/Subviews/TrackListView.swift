import SwiftUI

struct TrackListView: View {
    let tracks: [Track]
    @ObservedObject var manager: PlayerManager

    var body: some View {
        List(tracks) { track in
            TrackRowView(track: track, isPlaying: track == manager.currentTrack)
                .listRowBackground(Color.clear)
                .contentShape(Rectangle())
                .onTapGesture {
                    if let index = tracks.firstIndex(of: track) {
                        manager.setQueue(tracks, startIndex: index)
                    }
                }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    TrackListView(tracks: Track.previews, manager: PlayerManager.shared)
        .background(Color.black)
        .preferredColorScheme(.dark)
}
