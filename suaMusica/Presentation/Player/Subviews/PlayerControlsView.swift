import SwiftUI

struct PlayerControlsView: View {
    @ObservedObject var manager: PlayerManager

    var body: some View {
        HStack(spacing: 48) {
            Button(action: { manager.previous() }) {
                Image(systemName: "backward.fill")
                    .font(.title2)
            }

            Button(action: {
                manager.isPlaying ? manager.pause() : manager.playCurrent()
            }) {
                Image(systemName: manager.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 44))
            }

            Button(action: { manager.next() }) {
                Image(systemName: "forward.fill")
                    .font(.title2)
            }
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    PlayerControlsView(manager: PlayerManager.shared)
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
}
