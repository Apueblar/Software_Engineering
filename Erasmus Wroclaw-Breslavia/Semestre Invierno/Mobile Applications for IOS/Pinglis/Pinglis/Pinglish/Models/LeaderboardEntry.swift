//
//  LeaderboardEntry.swift
//  Pinglish
//

import Foundation

struct LeaderboardEntry: Identifiable, Codable {
    let id: UUID
    let username: String
    var points: Int
}
