//
//  SettingsViewModel.swift
//  Pinglish
//

import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var darkMode: Bool = false
    @Published var notificationsEnabled: Bool = true
    @Published var musicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(musicEnabled, forKey: "music_enabled")
        }
    }

    init() {
        self.musicEnabled = UserDefaults.standard.object(forKey: "music_enabled") as? Bool ?? true
    }
}
