//
//  MainTabView.swift
//  Pinglish
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            CourseListView()
                .tabItem {
                    Label("Courses", systemImage: "book.fill")
                }

            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: "list.number")
                }

            ProfileView()
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.accentColor) // asegura AccentColor activo
        .background(Color.white.ignoresSafeArea())
    }
}
