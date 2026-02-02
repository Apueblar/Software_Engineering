//
//  RootView.swift
//  Pinglish
//

import SwiftUI
import AVKit

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel
    @EnvironmentObject var coursesVM: CoursesViewModel

    // Estado para presentar el video de éxito
    @State private var showAuthSuccessVideo = false

    var body: some View {
        Group {
            if authVM.currentUser != nil {
                MainTabView()
            } else {
                NavigationView {
                    LoginView()
                }
            }
        }
        // 🔑 CLAVE: cargar progreso cuando cambia el usuario
        .onAppear {
            coursesVM.setActiveUser(username: authVM.currentUser?.username)
        }
        .onChange(of: authVM.currentUser?.username) { _, newUsername in
            coursesVM.setActiveUser(username: newUsername)

            // Si hay nuevo usuario autenticado, mostramos el video
            if newUsername != nil {
                showAuthSuccessVideo = true
            }
        }
        .fullScreenCover(isPresented: $showAuthSuccessVideo) {
            VideoSplashView(
                resourceName: "video",
                resourceExtension: "mp4",
                pausesBackgroundMusic: true
            ) {
                // Cierre automático al terminar
                showAuthSuccessVideo = false
            }
        }
        .preferredColorScheme(settingsVM.darkMode ? .dark : .light)
    }
}

