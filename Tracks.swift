import Foundation

struct Track: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let artist: String
    let streamURL: URL
}

protocol PlayerRepository {
    func play(track: Track)
    func pause()
    func seek(to: Double)
}
