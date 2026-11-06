import AVFoundation

@Observable
final class AudioPlayerService: NSObject, AVAudioPlayerDelegate {
    // What the view can read
    private(set) var isPlaying = false
    private(set) var currentTitle = "Cassette"

    // Catalog and queue
    private let tracks = Library.loadTracks()
    private var queue: [Int] = []      // track ids in shuffled order
    private var position = 0           // index into queue
    private var player: AVAudioPlayer?

    private let queueKey = "cassette.queue"
    private let positionKey = "cassette.position"

    override init() {
        super.init()
        setupAudioSession()
        loadQueue()
        loadCurrent(autoPlay: false)   // ready to play, but silent at launch
    }

    // MARK: - Buttons

    func togglePlayPause() {
        guard let player else {
            loadCurrent(autoPlay: true)
            return
        }
        if player.isPlaying { player.pause() } else { player.play() }
        isPlaying = player.isPlaying
    }

    func next() {
        guard !queue.isEmpty else { return }
        position += 1
        if position >= queue.count {
            newShuffle()               // finished all songs: reshuffle, start again
        }
        saveQueue()
        loadCurrent(autoPlay: true)
    }

    func previous() {
        guard !queue.isEmpty else { return }
        // At the first song, or more than 3 seconds in: restart this song
        if position == 0 || (player?.currentTime ?? 0) > 3 {
            player?.currentTime = 0
            return
        }
        position -= 1
        saveQueue()
        loadCurrent(autoPlay: true)
    }

    // MARK: - Queue

    private func loadQueue() {
        let ids = tracks.map(\.id)
        let saved = UserDefaults.standard.array(forKey: queueKey) as? [Int] ?? []

        // Use the saved queue only if it matches the current songs exactly
        if !ids.isEmpty, saved.count == ids.count, Set(saved) == Set(ids) {
            queue = saved
            let savedPosition = UserDefaults.standard.integer(forKey: positionKey)
            position = min(max(savedPosition, 0), queue.count - 1)
        } else {
            newShuffle()
        }
    }

    private func newShuffle() {
        queue = tracks.map(\.id).shuffled()
        position = 0
        saveQueue()
    }

    private func saveQueue() {
        UserDefaults.standard.set(queue, forKey: queueKey)
        UserDefaults.standard.set(position, forKey: positionKey)
    }

    private var currentTrack: Track? {
        guard queue.indices.contains(position) else { return nil }
        let id = queue[position]
        return tracks.first { $0.id == id }
    }

    // MARK: - Playback

    private func loadCurrent(autoPlay: Bool) {
        guard let track = currentTrack else {
            print("Queue is empty (check songs.json)")
            return
        }
        currentTitle = track.title

        guard let url = Library.fileURL(for: track) else {
            print("File missing:", track.file)
            isPlaying = false
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            if autoPlay { player?.play() }
            isPlaying = player?.isPlaying ?? false
        } catch {
            print("Playback error:", error)
            isPlaying = false
        }
    }

    // Called when a song ends by itself
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag { next() } else { isPlaying = false }
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
}
