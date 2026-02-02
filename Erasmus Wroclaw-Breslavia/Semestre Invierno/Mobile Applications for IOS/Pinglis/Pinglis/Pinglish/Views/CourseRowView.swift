//
//  CourseRowView.swift
//  Pinglish
//

import SwiftUI

struct CourseRowView: View {
    let course: Course

    var body: some View {
        VStack(alignment: .leading) {
            Text(course.title)
                .font(.headline)

            Text(course.subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
