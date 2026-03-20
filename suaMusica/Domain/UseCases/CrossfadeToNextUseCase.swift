import Foundation

final class CrossfadeToNextUseCase {
    private let repo: AVPlayerRepository
    
    init(repo: AVPlayerRepository) {
        self.repo = repo
    }
    
    func execute(next: Track) {
        repo.crossfade(to: next)
    }
}
