//
//  CourseListView.swift
//  Pinglish
//

import SwiftUI

struct CourseListView: View {
    @EnvironmentObject var coursesVM: CoursesViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(coursesVM.courses, id: \.id) { course in
                    NavigationLink(
                        destination: CourseDetailView(courseID: course.id)
                    ) {
                        HStack(spacing: 12) {
                            // Bandera por curso
                            Text(flag(for: course.title))
                                .font(.largeTitle)
                                .frame(width: 44, alignment: .center)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(course.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(course.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Languages")
            .tint(.accentColor)
            .scrollContentBackground(.hidden)
            .background(Color.white)
        }
        .background(Color.white.ignoresSafeArea())
    }

    private func flag(for courseTitle: String) -> String {
        switch courseTitle.lowercased() {
        case "spanish": return "🇪🇸"
        case "italian": return "🇮🇹"
        case "german":  return "🇩🇪"
        default:        return "🌍"
        }
    }
}
