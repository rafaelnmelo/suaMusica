import Foundation

struct Track: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let artist: String
    let streamURL: URL
}
