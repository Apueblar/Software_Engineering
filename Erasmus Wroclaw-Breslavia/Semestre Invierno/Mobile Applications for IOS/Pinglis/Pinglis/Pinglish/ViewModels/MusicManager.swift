//
//  MusicManager.swift
//  Pinglish
//


import Foundation
import AVFoundation
import Combine

final class MusicManager: ObservableObject {

    static let shared = MusicManager()

    private var player: AVAudioPlayer?

    private init() {}

    private var isRunningUnderTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    func startBackgroundMusic() {
        // Evitar inicializar audio en entorno de tests para prevenir crashes del simulador/CoreAudio
        guard !isRunningUnderTests else {
            return
        }

        guard let url = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else {
            print("❌ Music file not found")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1   // infinito
            player?.volume = 0.3         // suave
            player?.play()
        } catch {
            print("❌ Error playing music:", error)
        }
    }

    func stopMusic() {
        guard !isRunningUnderTests else {
            return
        }
        player?.stop()
    }
}
