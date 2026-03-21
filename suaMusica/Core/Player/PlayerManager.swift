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
    @Published var duration: Double = 0
    @Published var crossfadeEnabled = true
    
    private var queue: [Track] = []
    private var index: Int = 0
    private var timeObserver: Any?
    private weak var timeObserverPlayer: AVPlayer?
    
    private init() {
        setupRemoteControls()
        observeEndOfTrack()
    }
    
    /// Define a fila de reprodução e a faixa inicial, sem iniciar a reprodução.
    func setQueue(_ tracks: [Track], startIndex: Int = 0) {
        queue = tracks
        index = startIndex
        currentTrack = tracks[startIndex]
        observeDuration()
        preloadNext()
    }
    
    /// Inicia a reprodução da faixa atual na fila.
    func playCurrent() {
        guard queue.indices.contains(index) else { return }
        let track = queue[index]
        currentTrack = track
        playUseCase.execute(track: track)
        isPlaying = true
        observeProgress()
        observeDuration()
        updateNowPlaying()
    }
    
    /// Avança para a próxima faixa. Se `crossfade` for `true` e o crossfade estiver habilitado, realiza a transição suave.
    func next(crossfade: Bool = false) {
        guard index + 1 < queue.count else { return }
        index += 1
        if crossfade && crossfadeEnabled {
            crossfadeUseCase.execute(next: queue[index])
            currentTrack = queue[index]
            isPlaying = true
            preloadNext()
            updateNowPlaying()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.observeProgress()
                self?.observeDuration()
            }
        } else {
            playCurrent()
        }
    }
    
    /// Volta para a faixa anterior na fila.
    func previous() {
        guard index > 0 else { return }
        index -= 1
        playCurrent()
    }
    
    /// Pausa a reprodução atual.
    func pause() {
        repository.pause()
        isPlaying = false
    }
    
    /// Move a reprodução para o tempo especificado em segundos.
    func seek(to seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        repository.activePlayer.seek(to: time)
    }
    
    /// Pré-carrega a próxima faixa da fila para reduzir latência na transição.
    private func preloadNext() {
        let nextIndex = index + 1
        guard queue.indices.contains(nextIndex) else { return }
        repository.preload(track: queue[nextIndex])
    }
    
    /// Registra observador para avançar automaticamente ao fim de cada faixa.
    private func observeEndOfTrack() {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.next(crossfade: true)
        }
    }
    
    /// Inicia observação periódica do progresso de reprodução, atualizando `progress` a cada segundo.
    private func observeProgress() {
        if let observer = timeObserver {
            timeObserverPlayer?.removeTimeObserver(observer)
            timeObserver = nil
            timeObserverPlayer = nil
        }
        progress = 0
        let player = repository.activePlayer
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.progress = time.seconds
        }
        timeObserverPlayer = player
    }

    /// Carrega assincronamente a duração da faixa atual e atualiza `duration`.
    private func observeDuration() {
        duration = 0
        guard let asset = repository.activePlayer.currentItem?.asset else { return }
        Task { [weak self] in
            guard let self else { return }
            let seconds = try? await asset.load(.duration).seconds
            if let seconds, seconds.isFinite && seconds > 0 {
                await MainActor.run { self.duration = seconds }
            }
        }
    }
    
    /// Configura os controles remotos do sistema (Control Center e tela de bloqueio).
    private func setupRemoteControls() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in
            self?.playCurrent(); return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            self?.pause(); return .success
        }
        center.nextTrackCommand.addTarget { [weak self] _ in
            self?.next(); return .success
        }
    }
    
    /// Atualiza as informações exibidas no Now Playing do sistema com a faixa atual.
    private func updateNowPlaying() {
        guard let track = currentTrack else { return }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artist
        ]
    }
}
