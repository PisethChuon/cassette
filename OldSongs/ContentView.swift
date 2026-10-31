import SwiftUI
import AVFoundation

struct Song: Identifiable {
    let url: URL
    var id: URL { url }
    var title: String { url.deletingPathExtension().lastPathComponent }
}

@Observable
final class PlayerViewModel {
    var songs: [Song] = []
    var current: Song?
    var isPlaying = false
    var errorMessage: String?

    private var player: AVAudioPlayer?

    private var docs: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    init() {
        do {
            // .playback = keep playing when screen locks or silent switch is on
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            errorMessage = "Audio session error: \(error.localizedDescription)"
        }
        loadSongs()
    }

    func importSongs(_ urls: [URL]) {
        for url in urls {
            // Files outside the app need this permission
            let hasAccess = url.startAccessingSecurityScopedResource()
            defer { if hasAccess { url.stopAccessingSecurityScopedResource() } }

            let dest = docs.appendingPathComponent(url.lastPathComponent)
            do {
                if FileManager.default.fileExists(atPath: dest.path) {
                    try FileManager.default.removeItem(at: dest)
                }
                try FileManager.default.copyItem(at: url, to: dest)
            } catch {
                errorMessage = "Import failed: \(error.localizedDescription)"
            }
        }
        loadSongs()
    }

    func loadSongs() {
        let files = (try? FileManager.default.contentsOfDirectory(
            at: docs, includingPropertiesForKeys: nil)) ?? []
        let supported = ["mp3", "m4a", "aac", "wav", "flac"]
        songs = files
            .filter { supported.contains($0.pathExtension.lowercased()) }
            .map { Song(url: $0) }
            .sorted { $0.title < $1.title }
    }

    func play(_ song: Song) {
        do {
            player = try AVAudioPlayer(contentsOf: song.url)
            player?.play()
            current = song
            isPlaying = true
        } catch {
            errorMessage = "Can't play this file: \(error.localizedDescription)"
        }
    }

    func togglePause() {
        guard let player else { return }
        if player.isPlaying { player.pause() } else { player.play() }
        isPlaying = player.isPlaying
    }
}

// MARK: - View
struct ContentView: View {
    @State private var vm = PlayerViewModel()
    @State private var showPicker = false

    var body: some View {
        NavigationStack {
            List(vm.songs) { song in
                Button(song.title) { vm.play(song) }
            }
            .overlay {
                if vm.songs.isEmpty {
                    ContentUnavailableView("No songs yet",
                        systemImage: "music.note",
                        description: Text("Tap + to add songs"))
                }
            }
            .navigationTitle("Songs")
            .toolbar {
                Button("Add", systemImage: "plus") { showPicker = true }
            }
            .safeAreaInset(edge: .bottom) {
                if let current = vm.current {
                    HStack {
                        Text(current.title).lineLimit(1)
                        Spacer()
                        Button(vm.isPlaying ? "Pause" : "Play") { vm.togglePause() }
                    }
                    .padding()
                    .background(.bar)
                }
            }
            .fileImporter(isPresented: $showPicker,
                          allowedContentTypes: [.audio],
                          allowsMultipleSelection: true) { result in
                if case .success(let urls) = result { vm.importSongs(urls) }
            }
            .alert("Error",
                   isPresented: Binding(get: { vm.errorMessage != nil },
                                        set: { _ in vm.errorMessage = nil })) {
                Button("OK") {}
            } message: {
                Text(vm.errorMessage ?? "")
            }
        }
    }
}

#Preview { ContentView() }
