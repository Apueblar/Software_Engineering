//
//  Lesson.swift
//  Pinglish
//

import Foundation

struct Lesson: Identifiable, Codable {
    let id: UUID
    let referenceEN: String     // Apple
    let sentence: String        // Frase en idioma del curso
    let answer: String          // Respuesta en idioma del curso
    let imageName: String?
    var isCompleted: Bool
}
