//
//  LeaderboardViewModel.swift
//  Pinglish
//

import Foundation
import Combine

final class LeaderboardViewModel: ObservableObject {
    
    @Published var leaderboard: [LeaderboardEntry] = []
    
    // Alias para compatibilidad con tests
    var entries: [LeaderboardEntry] { leaderboard }
    
    private let storageKey = "pinglish_leaderboard_v1"
    
    init() {
        loadLeaderboard()
    }
    
    func updateLeaderboard(username: String, points: Int) {
        var updated = leaderboard
        
        if let index = updated.firstIndex(where: { $0.username == username }) {
            let current = updated[index]
            
            // 🔑 Reemplazamos el struct completo
            updated[index] = LeaderboardEntry(
                id: current.id,
                username: current.username,
                points: current.points + points
            )
        } else {
            updated.append(
                LeaderboardEntry(
                    id: UUID(),
                    username: username,
                    points: points
                )
            )
        }
        
        updated.sort { $0.points > $1.points }
        leaderboard = updated
        saveLeaderboard()
    }
    
    // MARK: - Persistence
    
    private func saveLeaderboard() {
        guard let data = try? JSONEncoder().encode(leaderboard) else {
            return
        }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    
    private func loadLeaderboard() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([LeaderboardEntry].self, from: data)
        else {
            leaderboard = []
            return
        }
        
        leaderboard = decoded
    }
    
}
