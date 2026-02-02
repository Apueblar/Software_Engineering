//
//  VideoSplashView.swift
//  Pinglish
//

import SwiftUI
import AVKit

struct VideoSplashView: View {
    let resourceName: String
    let resourceExtension: String
    var pausesBackgroundMusic: Bool = true
    var onFinished: () -> Void

    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            if let player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .onAppear(perform: {
                        if pausesBackgroundMusic {
                            MusicManager.shared.stopMusic()
                        }
                        player.seek(to: .zero)
                        player.play()
                        observeEnd(for: player)
                    })
            } else {
                Color.black.ignoresSafeArea()
                    .onAppear(perform: preparePlayer)
            }

            // Botón opcional para omitir
            VStack {
                HStack {
                    Spacer()
                    Button("Skip") {
                        player?.pause()
                        finish()
                    }
                    .padding()
                    .background(Color.black.opacity(0.4))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .padding()
                }
                Spacer()
            }
        }
    }

    private func preparePlayer() {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension) else {
            // Si no encontramos el recurso, cerramos de inmediato
            finish()
            return
        }
        player = AVPlayer(url: url)
    }

    private func observeEnd(for player: AVPlayer) {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            finish()
        }
    }

    private func finish() {
        if pausesBackgroundMusic {
            // Reanudar si usas música de fondo
            MusicManager.shared.startBackgroundMusic()
        }
        onFinished()
    }
}
