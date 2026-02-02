//
//  User.swift
//  Pinglish
//

import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var username: String
    var displayName: String?
    var points: Int

    init(id: UUID = UUID(), username: String, displayName: String? = nil, points: Int = 0) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.points = points
    }
}
