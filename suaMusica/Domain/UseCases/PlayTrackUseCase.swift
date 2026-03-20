import Foundation

final class PlayTrackUseCase {
    private let repo: AVPlayerRepository
    
    init(repo: AVPlayerRepository) {
        self.repo = repo
    }
    
    func execute(track: Track) {
        repo.play(track: track)
    }
}
