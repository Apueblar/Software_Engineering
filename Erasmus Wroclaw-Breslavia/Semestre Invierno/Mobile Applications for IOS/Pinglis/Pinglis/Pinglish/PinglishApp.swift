//
//  PinglishApp.swift
//  Pinglish
//

import SwiftUI

@main
struct PinglishApp: App {

    @StateObject private var musicManager = MusicManager.shared
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var settingsVM = SettingsViewModel()
    @StateObject private var coursesVM = CoursesViewModel()
    @StateObject private var leaderboardVM = LeaderboardViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .onAppear {
                    if settingsVM.musicEnabled {
                        musicManager.startBackgroundMusic()
                    }
                }
                .onChange(of: settingsVM.musicEnabled) {
                    if settingsVM.musicEnabled {
                        musicManager.startBackgroundMusic()
                    } else {
                        musicManager.stopMusic()
                    }
                }
                .environmentObject(authVM)
                .environmentObject(settingsVM)
                .environmentObject(coursesVM)
                .environmentObject(leaderboardVM)
        }
    }
}
