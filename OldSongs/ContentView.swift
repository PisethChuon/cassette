import SwiftUI

struct ContentView: View {
    @State private var audioPlayer = AudioPlayerService()

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "recordingtape")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            Text(audioPlayer.currentTitle)
                .font(.title2)
                .bold()

            Button {
                audioPlayer.togglePlayPause()
            } label: {
                Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
            }
            .font(.largeTitle)
            .buttonStyle(.bordered)
        }
        .padding()
        .onAppear {
            Library.printReport()
            let root = Bundle.main.resourcePath!
            print(try? FileManager.default.contentsOfDirectory(atPath: root))
        }
    }
}

#Preview {
    ContentView()
}
