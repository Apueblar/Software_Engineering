//
//  AuthViewModel.swift
//  Pinglish
//

import Foundation
import Combine

struct AppUser: Codable, Identifiable {
    let id: UUID
    let username: String
    let points: Int
}

enum AuthError: Error {
    case userAlreadyExists
    case invalidCredentials
    case keychainSaveFailed
}

final class AuthViewModel: ObservableObject {

    // MARK: - Published state

    @Published var currentUser: AppUser?

    // 🔑 Usado por SwiftUI (LoginView, RootView, etc.)
    var isAuthenticated: Bool {
        currentUser != nil
    }

    // MARK: - Storage keys

    private let usersKey = "pinglish_users_v1"
    private let currentUserKey = "pinglish_current_username_v1"

    init() {
        loadCurrentUser()
    }

    // MARK: - Sign Up

    func signUp(username: String, password: String) throws {
        let cleanUser = username.lowercased()

        var users = loadUsers()

        if users.contains(where: { $0.username == cleanUser }) {
            throw AuthError.userAlreadyExists
        }

        let user = AppUser(id: UUID(), username: cleanUser, points: 0)
        users.append(user)

        // Try to save password first; if it fails, revert and throw.
        let savedToKeychain = KeychainService.savePassword(password, for: cleanUser)
        guard savedToKeychain else {
            // revert the in-memory users array change
            users.removeAll { $0.username == cleanUser }
            throw AuthError.keychainSaveFailed
        }

        // Persist users only after keychain success
        saveUsers(users)

        currentUser = user
        UserDefaults.standard.set(cleanUser, forKey: currentUserKey)
    }

    // MARK: - Login

    func login(username: String, password: String) throws {
        let cleanUser = username.lowercased()

        let users = loadUsers()

        guard users.contains(where: { $0.username == cleanUser }) else {
            throw AuthError.invalidCredentials
        }

        guard
            let stored = KeychainService.loadPassword(for: cleanUser),
            stored == password
        else {
            throw AuthError.invalidCredentials
        }

        currentUser = users.first { $0.username == cleanUser }
        UserDefaults.standard.set(cleanUser, forKey: currentUserKey)
    }

    // 🔁 Alias para compatibilidad con Views que usan signIn
    func signIn(username: String, password: String) throws {
        try login(username: username, password: password)
    }

    // MARK: - Points (usado en LessonView)

    func addPoints(_ points: Int) {
        guard let user = currentUser else { return }

        let updatedUser = AppUser(
            id: user.id,
            username: user.username,
            points: user.points + points
        )

        // actualizar estado en memoria
        currentUser = updatedUser

        // actualizar persistencia
        let updatedUsers = loadUsers().map {
            $0.username == user.username ? updatedUser : $0
        }
        saveUsers(updatedUsers)
    }

    // MARK: - Logout

    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }

    // MARK: - Persistence

    private func loadUsers() -> [AppUser] {
        guard
            let data = UserDefaults.standard.data(forKey: usersKey),
            let decoded = try? JSONDecoder().decode([AppUser].self, from: data)
        else {
            return []
        }
        return decoded
    }

    private func saveUsers(_ users: [AppUser]) {
        guard let data = try? JSONEncoder().encode(users) else {
            return
        }
        UserDefaults.standard.set(data, forKey: usersKey)
    }

    private func loadCurrentUser() {
        guard
            let username = UserDefaults.standard.string(forKey: currentUserKey),
            let user = loadUsers().first(where: { $0.username == username })
        else {
            currentUser = nil
            return
        }

        currentUser = user
    }
}
