import AVFoundation

@Observable
class AudioPlayerService {
    private var player: AVAudioPlayer?
    
    func play() {
        guard let url = Bundle.main.url(
            forResource: "song",
            withExtension: "mp3"
        ) else {
            print("Song not found")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Playback error: \(error)")
        }
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.stop()
    }
}
