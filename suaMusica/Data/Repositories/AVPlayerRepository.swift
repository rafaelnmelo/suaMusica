import AVFoundation
import Combine

final class AVPlayerRepository: PlayerRepository {
    private let playerA = AVPlayer()
    private let playerB = AVPlayer()
    private var usingA = true
    private var cancellables = Set<AnyCancellable>()
    
    var activePlayer: AVPlayer {
        usingA ? playerA : playerB
    }
    
    var idlePlayer: AVPlayer {
        usingA ? playerB : playerA
    }
    
    init() {
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func play(track: Track) {
        let item = AVPlayerItem(url: track.streamURL)
        activePlayer.replaceCurrentItem(with: item)
        activePlayer.play()
    }
    
    func preload(track: Track) {
        let item = AVPlayerItem(url: track.streamURL)
        idlePlayer.replaceCurrentItem(with: item)
        idlePlayer.pause()
    }
    
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
    
    func pause() {
        activePlayer.pause()
    }
    
    func seek(to seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: 1)
        activePlayer.seek(to: time)
    }
}
