//
//  SettingsView.swift
//  Pinglish
//

import SwiftUI

extension Bundle {
    var appLocalizations: [String] {
        (self.localizations.filter { $0 != "Base" })
    }

    func displayName(for languageCode: String) -> String {
        let locale = Locale(identifier: languageCode)
        return locale.localizedString(forLanguageCode: languageCode)?.capitalized(with: locale) ?? languageCode
    }
}

struct SettingsView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @State var showPreferences = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Audio")) {
                    Toggle("Background Music", isOn: $settingsVM.musicEnabled)
                }

                Toggle(NSLocalizedString("Dark mode", comment: ""), isOn: $settingsVM.darkMode)
                Toggle(NSLocalizedString("Notifications", comment: ""), isOn: $settingsVM.notificationsEnabled)
                Toggle(NSLocalizedString("Music", comment: ""), isOn: $settingsVM.musicEnabled)
            }
            .navigationTitle(NSLocalizedString("Settings", comment: ""))
            .tint(.accentColor)
        }
        .background(Color.white.ignoresSafeArea())
    }
}
