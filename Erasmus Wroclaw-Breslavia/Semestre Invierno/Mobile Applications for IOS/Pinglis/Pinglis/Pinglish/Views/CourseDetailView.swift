//
//  CourseDetailView.swift
//  Pinglish
//

import SwiftUI

struct CourseDetailView: View {
    @EnvironmentObject var coursesVM: CoursesViewModel
    let courseID: UUID

    private var course: Course? {
        coursesVM.course(by: courseID)
    }

    var body: some View {
        NavigationStack {
            List {
                if let course {
                    ForEach(course.levels, id: \.id) { level in
                        Section(header:
                            Text(level.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                        ) {
                            ForEach(level.lessons, id: \.id) { lesson in
                                NavigationLink(
                                    destination: LessonView(
                                        courseID: course.id,
                                        levelID: level.id,
                                        lessonID: lesson.id
                                    )
                                ) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(lesson.referenceEN)
                                                .font(.headline)
                                            Text(lesson.sentence)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        if lesson.isCompleted {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.accent)
                                        }
                                    }
                                    .padding(.vertical, 6)
                                }
                            }
                        }
                    }
                } else {
                    Text("Course not found")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(course?.title ?? "")
            .tint(.accentColor)
            .scrollContentBackground(.hidden)
            .background(Color.white)
        }
        .background(Color.white.ignoresSafeArea())
    }
}
