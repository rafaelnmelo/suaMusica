import AVFoundation
import MediaPlayer

final class PlayerManager: ObservableObject {
    static let shared = PlayerManager()
    
    private let repository = AVPlayerRepository()
    private lazy var playUseCase = PlayTrackUseCase(repo: repository)
    private lazy var crossfadeUseCase = CrossfadeToNextUseCase(repo: repository)
    
    @Published var currentTrack: Track?
    @Published var isPlaying = false
    @Published var progress: Double = 0
    
    private var queue: [Track] = []
    private var index: Int = 0
    private var timeObserver: Any?
    
    private init() {
        setupRemoteControls()
        observeEndOfTrack()
    }
    
    func setQueue(_ tracks: [Track], startIndex: Int = 0) {
        queue = tracks
        index = startIndex
        playCurrent()
        preloadNext()
    }
    
    func playCurrent() {
        guard queue.indices.contains(index) else { return }
        let track = queue[index]
        currentTrack = track
        playUseCase.execute(track: track)
        observeProgress()
        updateNowPlaying()
    }
    
    func next() {
        guard index + 1 < queue.count else { return }
        index += 1
        crossfadeUseCase.execute(next: queue[index])
        currentTrack = queue[index]
        preloadNext()
        updateNowPlaying()
    }
    
    func previous() {
        guard index > 0 else { return }
        index -= 1
        playCurrent()
    }
    
    func pause() {
        repository.pause()
        isPlaying = false
    }
    
    private func preloadNext() {
        let nextIndex = index + 1
        guard queue.indices.contains(nextIndex) else { return }
        repository.preload(track: queue[nextIndex])
    }
    
    private func observeEndOfTrack() {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.next()
        }
    }
    
    private func observeProgress() {
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        timeObserver = repository.activePlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.progress = time.seconds
        }
    }
    
    private func setupRemoteControls() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { _ in
            self.playCurrent(); return .success
        }
        center.pauseCommand.addTarget { _ in
            self.pause(); return .success
        }
        center.nextTrackCommand.addTarget { _ in
            self.next(); return .success
        }
    }
    
    private func updateNowPlaying() {
        guard let track = currentTrack else { return }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artist
        ]
    }
}
