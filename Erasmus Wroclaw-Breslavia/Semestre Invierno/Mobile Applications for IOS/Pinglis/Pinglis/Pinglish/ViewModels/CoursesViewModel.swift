//
//  CoursesViewModel.swift
//  Pinglish
//

import Foundation
import Combine

final class CoursesViewModel: ObservableObject {


    // MARK: - Published
    @Published var courses: [Course] = []

    // MARK: - User-based persistence
    private let storageKeyBase = "pinglish_courses_user_"
    private var activeUsername: String?

    // MARK: - Init
    init() {
        // No cargamos nada hasta saber qué usuario está activo
    }

    // MARK: - User handling (CLAVE)
    func setActiveUser(username: String?) {
        activeUsername = username?.lowercased()
        loadCoursesForActiveUser()
    }

    // MARK: - Access helpers
    func course(by id: UUID) -> Course? {
        courses.first { $0.id == id }
    }

    func lesson(courseID: UUID, levelID: UUID, lessonID: UUID) -> Lesson? {
        guard
            let course = course(by: courseID),
            let level = course.levels.first(where: { $0.id == levelID })
        else { return nil }

        return level.lessons.first(where: { $0.id == lessonID })
    }

    // MARK: - Game logic
    func completeLesson(courseID: UUID, levelID: UUID, lessonID: UUID) {
        guard
            let cIndex = courses.firstIndex(where: { $0.id == courseID }),
            let lIndex = courses[cIndex].levels.firstIndex(where: { $0.id == levelID }),
            let lesIndex = courses[cIndex].levels[lIndex].lessons.firstIndex(where: { $0.id == lessonID })
        else { return }

        courses[cIndex].levels[lIndex].lessons[lesIndex].isCompleted = true
        saveCoursesForActiveUser()
    }

    // MARK: - Persistence (PER USER)
    private func storageKey() -> String? {
        guard let username = activeUsername, !username.isEmpty else { return nil }
        return storageKeyBase + username
    }

    private func saveCoursesForActiveUser() {
        guard let key = storageKey() else { return }
        if let data = try? JSONEncoder().encode(courses) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func loadCoursesForActiveUser() {
        guard let key = storageKey() else {
            loadSampleCourses()
            return
        }

        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Course].self, from: data) {
            courses = decoded
        } else {
            loadSampleCourses()
            saveCoursesForActiveUser()
        }
    }

    // MARK: - Sample data (IDIOMAS → CATEGORÍAS → LECCIONES)
    private func loadSampleCourses() {
        courses = [

            // 🇪🇸 SPANISH
            Course(
                id: UUID(),
                title: "Spanish",
                subtitle: "Learn Spanish",
                levels: [

                    Level(
                        id: UUID(),
                        title: "Fruits",
                        lessons: [
                            Lesson(id: UUID(), referenceEN: "Apple", sentence: "Esto es una _.", answer: "manzana", imageName: "apple", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Banana", sentence: "Esto es un _.", answer: "plátano", imageName: "banana", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Lemon", sentence: "Esto es un _.", answer: "limón", imageName: "lemon", isCompleted: false)
                        ],
                        isLocked: false
                    ),

                    Level(
                        id: UUID(),
                        title: "Vegetables",
                        lessons: [
                            Lesson(id: UUID(), referenceEN: "Mushroom", sentence: "Esto es un _.", answer: "champiñón", imageName: "mushroom", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Leaf", sentence: "Esto es una _.", answer: "hoja", imageName: "leaf", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Beans", sentence: "Esto son _.", answer: "judías", imageName: "beans", isCompleted: false)
                        ],
                        isLocked: false
                    ),

                    Level(
                        id: UUID(),
                        title: "Drinks",
                        lessons: [
                            Lesson(id: UUID(), referenceEN: "Drink", sentence: "Esto es una _.", answer: "bebida", imageName: "drink", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Bottle", sentence: "Esto es una _.", answer: "botella", imageName: "bottle", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Coffee", sentence: "Esto es un _.", answer: "café", imageName: "coffe", isCompleted: false)
                        ],
                        isLocked: false
                    ),

                    Level(
                        id: UUID(),
                        title: "Food",
                        lessons: [
                            Lesson(id: UUID(), referenceEN: "Pizza", sentence: "Esto es una _.", answer: "pizza", imageName: "pizza", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Ice Cream", sentence: "Esto es un _.", answer: "helado", imageName: "icecream", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "French Fries", sentence: "Esto son _.", answer: "patatas fritas", imageName: "potatofries", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Egg", sentence: "Esto es un _.", answer: "huevo", imageName: "egg", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Meat", sentence: "Esto es _.", answer: "carne", imageName: "meat", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Peanut", sentence: "Esto es un _.", answer: "cacahuete", imageName: "peanut", isCompleted: false)
                        ],
                        isLocked: false
                    )
                ]
            ),

            // 🇮🇹 ITALIAN
            Course(
                id: UUID(),
                title: "Italian",
                subtitle: "Learn Italian",
                levels: [

                    Level(
                        id: UUID(),
                        title: "Fruits",
                        lessons: [
                            Lesson(id: UUID(), referenceEN: "Apple", sentence: "Questa è una _.", answer: "mela", imageName: "apple", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Banana", sentence: "Questa è una _.", answer: "banana", imageName: "banana", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Lemon", sentence: "Questo è un _.", answer: "limone", imageName: "lemon", isCompleted: false)
                        ],
                        isLocked: false
                    ),

                    Level(
                        id: UUID(),
                        title: "Vegetables",
                        lessons: [
                            Lesson(id: UUID(), referenceEN: "Mushroom", sentence: "Questo è un _.", answer: "fungo", imageName: "mushroom", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Leaf", sentence: "Questa è una _.", answer: "foglia", imageName: "leaf", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Beans", sentence: "Questi sono _.", answer: "fagioli", imageName: "beans", isCompleted: false)
                        ],
                        isLocked: false
                    ),

                    Level(
                        id: UUID(),
                        title: "Drinks",
                        lessons: [
                            Lesson(id: UUID(), referenceEN: "Drink", sentence: "Questa è una _.", answer: "bevanda", imageName: "drink", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Bottle", sentence: "Questa è una _.", answer: "bottiglia", imageName: "bottle", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Coffee", sentence: "Questo è un _.", answer: "caffè", imageName: "coffe", isCompleted: false)
                        ],
                        isLocked: false
                    ),

                    Level(
                        id: UUID(),
                        title: "Food",
                        lessons: [
                            Lesson(id: UUID(), referenceEN: "Pizza", sentence: "Questa è una _.", answer: "pizza", imageName: "pizza", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Ice Cream", sentence: "Questo è un _.", answer: "gelato", imageName: "icecream", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "French Fries", sentence: "Queste sono _.", answer: "patatine fritte", imageName: "potatofries", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Egg", sentence: "Questo è un _.", answer: "uovo", imageName: "egg", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Meat", sentence: "Questo è _.", answer: "carne", imageName: "meat", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Peanut", sentence: "Questo è un _.", answer: "arachide", imageName: "peanut", isCompleted: false)
                        ],
                        isLocked: false
                    )
                ]
            ),

            // 🇩🇪 GERMAN
            Course(
                id: UUID(),
                title: "German",
                subtitle: "Learn German",
                levels: [

                    Level(
                        id: UUID(),
                        title: "Fruits",
                        lessons: [
                            Lesson(id: UUID(), referenceEN: "Apple", sentence: "Das ist ein _.", answer: "Apfel", imageName: "apple", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Banana", sentence: "Das ist eine _.", answer: "Banane", imageName: "banana", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Lemon", sentence: "Das ist eine _.", answer: "Zitrone", imageName: "lemon", isCompleted: false)
                        ],
                        isLocked: false
                    ),

                    Level(
                        id: UUID(),
                        title: "Vegetables",
                        lessons: [
                            Lesson(id: UUID(), referenceEN: "Mushroom", sentence: "Das ist ein _.", answer: "Pilz", imageName: "mushroom", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Leaf", sentence: "Das ist ein _.", answer: "Blatt", imageName: "leaf", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Beans", sentence: "Das sind _.", answer: "Bohnen", imageName: "beans", isCompleted: false)
                        ],
                        isLocked: false
                    ),

                    Level(
                        id: UUID(),
                        title: "Drinks",
                        lessons: [
                            Lesson(id: UUID(), referenceEN: "Drink", sentence: "Das ist ein _.", answer: "Getränk", imageName: "drink", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Bottle", sentence: "Das ist eine _.", answer: "Flasche", imageName: "bottle", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Coffee", sentence: "Das ist ein _.", answer: "Kaffee", imageName: "coffe", isCompleted: false)
                        ],
                        isLocked: false
                    ),

                    Level(
                        id: UUID(),
                        title: "Food",
                        lessons: [
                            Lesson(id: UUID(), referenceEN: "Pizza", sentence: "Das ist eine _.", answer: "Pizza", imageName: "pizza", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Ice Cream", sentence: "Das ist ein _.", answer: "Eis", imageName: "icecream", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "French Fries", sentence: "Das sind _.", answer: "Pommes frites", imageName: "potatofries", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Egg", sentence: "Das ist ein _.", answer: "Ei", imageName: "egg", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Meat", sentence: "Das ist _.", answer: "Fleisch", imageName: "meat", isCompleted: false),
                            Lesson(id: UUID(), referenceEN: "Peanut", sentence: "Das ist eine _.", answer: "Erdnuss", imageName: "peanut", isCompleted: false)
                        ],
                        isLocked: false
                    )
                ]
            )
        ]
    }
}

