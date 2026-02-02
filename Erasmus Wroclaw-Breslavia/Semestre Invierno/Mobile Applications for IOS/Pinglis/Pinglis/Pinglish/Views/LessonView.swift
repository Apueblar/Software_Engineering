//
//  LessonView.swift
//  Pinglish
//

import SwiftUI

struct LessonView: View {
    @EnvironmentObject var coursesVM: CoursesViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var leaderboardVM: LeaderboardViewModel

    let courseID: UUID
    let levelID: UUID
    let lessonID: UUID

    @State private var answer: String = ""
    @State private var feedback: String?

    private var lesson: Lesson? {
        coursesVM.lesson(
            courseID: courseID,
            levelID: levelID,
            lessonID: lessonID
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let lesson {

                    Text(lesson.referenceEN.uppercased())
                        .font(.largeTitle.bold())
                        .foregroundStyle(.accent)

                    if let imageName = lesson.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cardStyle()
                            .padding(.horizontal)
                    }

                    Text(lesson.sentence)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    TextField("Your answer", text: $answer)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .roundedInput()
                        .padding(.horizontal)

                    Button("Check") {
                        check(lesson)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)

                    if let feedback {
                        Text(feedback)
                            .font(.headline)
                            .foregroundColor(
                                feedback == "Great!" ? .green : .red
                            )
                    }

                    Spacer()

                } else {
                    Text("Lesson not found")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical)
            .navigationTitle("Lesson")
            .background(Color.white.ignoresSafeArea())
        }
        .tint(.accentColor)
        .background(Color.white)
    }

    private func check(_ lesson: Lesson) {
        let userAnswer = answer
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        let correctAnswer = lesson.answer
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if userAnswer == correctAnswer {
            feedback = "Great!"

            if !lesson.isCompleted {
                coursesVM.completeLesson(
                    courseID: courseID,
                    levelID: levelID,
                    lessonID: lessonID
                )

                authVM.addPoints(10)
                if let user = authVM.currentUser {
                    leaderboardVM.updateLeaderboard(username: user.username, points: user.points)
                }
            }
        } else {
            feedback = "Try again"
        }
    }
}
