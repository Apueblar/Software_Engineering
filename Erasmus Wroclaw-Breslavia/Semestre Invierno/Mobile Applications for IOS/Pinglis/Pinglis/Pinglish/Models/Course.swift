//
//  Course.swift
//  Pinglish
//
import Foundation

struct Level: Identifiable, Codable {
    let id: UUID
    let title: String
    var lessons: [Lesson]
    var isLocked: Bool
}

struct Course: Identifiable, Codable {
    let id: UUID
    let title: String           // Español, Italiano, Alemán
    let subtitle: String
    var levels: [Level]
}
