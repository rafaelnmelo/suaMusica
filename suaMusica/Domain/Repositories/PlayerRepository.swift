import Foundation

protocol PlayerRepository {
    func play(track: Track)
    func pause()
    func seek(to: Double)
}

