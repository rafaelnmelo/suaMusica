import AVFoundation
import Combine

final class AVPlayerRepository: PlayerRepository {
    private let playerA = AVPlayer()
    private let playerB = AVPlayer()
    private var usingA = true
    private var cancellables = Set<AnyCancellable>()
    
    /// Player atualmente em uso para reprodução.
    var activePlayer: AVPlayer {
        usingA ? playerA : playerB
    }
    
    /// Player em espera, usado para pré-carregamento e crossfade.
    var idlePlayer: AVPlayer {
        usingA ? playerB : playerA
    }
    
    init() {
        configureAudioSession()
    }
    
    /// Configura a sessão de áudio para reprodução em background.
    private func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    /// Carrega e inicia a reprodução da faixa no player ativo.
    func play(track: Track) {
        let item = AVPlayerItem(url: track.streamURL)
        activePlayer.replaceCurrentItem(with: item)
        activePlayer.play()
    }
    
    /// Pré-carrega a faixa no player ocioso sem iniciar a reprodução.
    func preload(track: Track) {
        let item = AVPlayerItem(url: track.streamURL)
        idlePlayer.replaceCurrentItem(with: item)
        idlePlayer.pause()
    }
    
    /// Realiza transição suave entre o player ativo e o ocioso ao longo de `duration` segundos.
    func crossfade(to track: Track, duration: Double = 3.0) {
        preload(track: track)
        idlePlayer.volume = 0
        idlePlayer.play()
        
        let steps = 30
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration * Double(i) / Double(steps)) {
                let progress = Float(i) / Float(steps)
                self.activePlayer.volume = 1 - progress
                self.idlePlayer.volume = progress
                
                if i == steps {
                    self.activePlayer.pause()
                    self.usingA.toggle()
                }
            }
        }
    }
    
    /// Pausa o player ativo.
    func pause() {
        activePlayer.pause()
    }
    
    /// Move a reprodução do player ativo para o tempo especificado em segundos.
    func seek(to seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: 1)
        activePlayer.seek(to: time)
    }
}
