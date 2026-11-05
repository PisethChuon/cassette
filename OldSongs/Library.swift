import Foundation

// One entry in songs.json
struct Track: Codable, Identifiable {
    let id: Int          // permanent number, never change after you start saving the queue
    let title: String    // what the listener sees
    let file: String     // "song_1.m4a"
}

enum Library {
    // Name of the blue folder in Xcode that holds the audio files
    static let folderName = "SinSisamuth"

    // Read songs.json from the app bundle
    static func loadTracks() -> [Track] {
        do {
            guard let url = Bundle.main.url(forResource: "songs", withExtension: "json") else {
                print("songs.json not found in bundle (check Target Membership)")
                return []
            }
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Track].self, from: data)
        } catch {
            print("songs.json error:", error)
            return []
        }
    }

    // The ONLY place that knows where the audio files live.
    // Later, if songs move to downloaded packs, change only this function.
    static func fileURL(for track: Track) -> URL? {
        let name = track.file as NSString
        return Bundle.main.url(forResource: name.deletingPathExtension,
                               withExtension: name.pathExtension,
                               subdirectory: folderName)
    }

    // Debug helper: prints which songs are found or missing
    static func printReport() {
        let tracks = loadTracks()
        print("Tracks in songs.json:", tracks.count)
        for t in tracks {
            let found = fileURL(for: t) != nil
            print(" \(t.id) \(t.title) -> \(found ? "found" : "MISSING")")
        }
    }
}
