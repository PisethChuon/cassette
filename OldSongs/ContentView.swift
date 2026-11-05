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
                .multilineTextAlignment(.center)

            HStack(spacing: 30) {
                Button {
                    audioPlayer.previous()
                } label: {
                    Image(systemName: "backward.fill")
                }

                Button {
                    audioPlayer.togglePlayPause()
                } label: {
                    Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                }

                Button {
                    audioPlayer.next()
                } label: {
                    Image(systemName: "forward.fill")
                }
            }
            .font(.largeTitle)
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
