//
//  LessonRowView.swift
//  Pinglish
//

import SwiftUI

struct LessonRowView: View {
    let lesson: Lesson

    var body: some View {
        HStack {
            Text(lesson.referenceEN)
            Spacer()
            if lesson.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }
}

