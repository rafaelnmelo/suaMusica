import SwiftUI

struct HomeView: View {
    @StateObject private var manager = PlayerManager.shared
    @State private var isPlayerExpanded = true

    private let tracks = Track.previews

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Músicas")
                        .font(.largeTitle).bold()
                        .foregroundStyle(.white)
                    Spacer()
                    Toggle("Crossfade", isOn: $manager.crossfadeEnabled)
                        .fixedSize()
                        .tint(.blue)
                        .foregroundStyle(.white)
                }
                .padding()

                TrackListView(tracks: tracks, manager: manager)

                Color.clear.frame(height: isPlayerExpanded ? 220 : 120)
            }

            VStack(spacing: 0) {
                Button(action: { withAnimation(.spring) { isPlayerExpanded.toggle() } }) {
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 36, height: 4)
                        .padding(.top, 8)
                }

                PlayerView(manager: manager, isExpanded: isPlayerExpanded)
                    .padding()
            }
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            manager.setQueue(tracks)
        }
    }
}

#Preview {
    HomeView()
}
