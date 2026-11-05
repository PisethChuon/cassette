import AVFoundation

@Observable
final class AudioPlayerService {
    private(set) var isPlaying = false
    private(set) var currentTitle = "Cassette"

    private let tracks = Library.loadTracks()
    private var player: AVAudioPlayer?

    init() {
        setupAudioSession()
    }

    // .playback = keeps playing with the silent switch on and the screen locked
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error:", error)
        }
    }

    func togglePlayPause() {
        if let player {
            // A player already exists: pause or resume, don't restart
            if player.isPlaying { player.pause() } else { player.play() }
            isPlaying = player.isPlaying
        } else {
            playTrack(at: 0)
        }
    }

    private func playTrack(at index: Int) {
        guard tracks.indices.contains(index) else {
            print("No track at index", index)
            return
        }
        let track = tracks[index]
        guard let url = Library.fileURL(for: track) else {
            print("File missing:", track.file)
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
            currentTitle = track.title
            isPlaying = true
        } catch {
            print("Playback error:", error)
        }
    }
}
