import SwiftUI

struct ContentView: View {
    @State private var audioPlayer = AudioPlayerService()
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "music.note")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("My First Music Player")
                .font(.title2)
                .bold()
            
            HStack(spacing: 30) {
                Button {
                    audioPlayer.play()
                } label: {
                    Image(systemName: "play.fill")
                }

                Button {
                    audioPlayer.pause()
                } label: {
                    Image(systemName: "pause.fill")
                }
                
                Button {
                    audioPlayer.stop()
                } label: {
                    Image(systemName: "stop.fill")
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
