//
//  HomeView.swift
//  Pinglish
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var coursesVM: CoursesViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            List {
                // Encabezado
                Section {
                    header
                        .listRowBackground(Color.clear)
                }

                // Lista vertical de cursos con bandera y botón
                Section(header: Text("Courses").font(.headline)) {
                    ForEach(coursesVM.courses) { course in
                        CourseRowWithFlag(
                            flag: flag(for: course.title),
                            title: course.title,
                            subtitle: course.subtitle
                        ) {
                            // Acción del botón: navegar al detalle del curso
                            // Usamos NavigationLink programático dentro de la fila
                        }
                        .background(
                            NavigationLink("", destination: CourseDetailView(courseID: course.id))
                                .opacity(0) // Oculto, permite navegación al tocar toda la fila
                        )
                        .contentShape(Rectangle())
                    }
                }
            }
            .navigationTitle("Home")
            .scrollContentBackground(.hidden)
            .background(backgroundColor.ignoresSafeArea())
        }
        .tint(.accentColor)
        .background(backgroundColor.ignoresSafeArea())
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? Color(.systemGroupedBackground) : .white
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 54, height: 54)
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.accent)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Hi, \(authVM.currentUser?.username ?? "Guest")")
                    .font(.title2.bold())
                Text("Choose a course to start")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Cambiado: ahora navega a SettingsView
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape.fill")
                    .font(.headline)
                    .foregroundStyle(.accent)
                    .padding(10)
                    .background(Color.accentColor.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .accessibilityLabel("Settings")
        }
        .padding(.vertical, 6)
    }

    // MARK: - Flag helper

    private func flag(for courseTitle: String) -> String {
        switch courseTitle.lowercased() {
        case "spanish": return "🇪🇸"
        case "italian": return "🇮🇹"
        case "german":  return "🇩🇪"
        default:        return "🌍"
        }
    }
}

private struct CourseRowWithFlag: View {
    let flag: String
    let title: String
    let subtitle: String
    var action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(flag)
                .font(.largeTitle)
                .frame(width: 44, alignment: .center)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Botón visual (la fila completa también navega con el NavigationLink oculto)
            Image(systemName: "chevron.right.circle.fill")
                .font(.title3)
                .foregroundStyle(.accent)
                .accessibilityLabel("Go to \(title)")
        }
        .padding(.vertical, 6)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
            .environmentObject(CoursesViewModel())
            .preferredColorScheme(.light)

        HomeView()
            .environmentObject(AuthViewModel())
            .environmentObject(CoursesViewModel())
            .preferredColorScheme(.dark)
    }
}
