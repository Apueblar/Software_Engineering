
//
//  OnedriveView.swift
//  iOS-Examples-W6
//
//  Created by Oleksandr Yeroshkin on 17/11/2025.
//

import SwiftUI

struct ForYouCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
}

struct RecentFile: Identifiable {
    let id = UUID()
    let name: String
    let date: String
    let size: String
    let iconType: FileIconType
}

enum FileIconType {
    case word
    case document
    
    var icon: String {
        switch self {
        case .word: return "doc.text.fill"
        case .document: return "doc.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .word: return .blue
        case .document: return .orange
        }
    }
}

struct OnedriveView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: Int = 0
    
    let forYouCards: [ForYouCard] = [
        ForYouCard(title: "On this day", subtitle: "September 17", imageName: "photo"),
        ForYouCard(title: "September moments", subtitle: "2022", imageName: "photo"),
        ForYouCard(title: "October", subtitle: "2022", imageName: "photo")
    ]
    
    let recentFiles: [RecentFile] = [
        RecentFile(name: "Homework_Assignment_1", date: "Mar 24", size: "1.6 MB", iconType: .word),
        RecentFile(name: "English_Paper_Draft_2", date: "Sep 12", size: "3.6 MB", iconType: .document),
        RecentFile(name: "Personal_Statement", date: "Aug 24", size: "3.6 MB", iconType: .document),
        RecentFile(name: "Resume 2021", date: "June 23", size: "3.6 MB", iconType: .word),
        RecentFile(name: "Tuition Payment Receipt", date: "Jun 24", size: "210 KB", iconType: .document),
        RecentFile(name: "Homework_Assignment_1", date: "Mar 24", size: "1.6 MB", iconType: .word),
        RecentFile(name: "English_Paper_Draft_2", date: "Sep 12", size: "3.6 MB", iconType: .document),
        RecentFile(name: "Personal_Statement", date: "Aug 24", size: "3.6 MB", iconType: .document),
        RecentFile(name: "Resume 2021", date: "June 23", size: "3.6 MB", iconType: .word),
        RecentFile(name: "Tuition Payment Receipt", date: "Jun 24", size: "210 KB", iconType: .document),
        RecentFile(name: "Tuition Payment Receipt", date: "Jun 24", size: "210 KB", iconType: .document),
        RecentFile(name: "Tuition Payment Receipt", date: "Jun 24", size: "210 KB", iconType: .document),
        RecentFile(name: "Tuition Payment Receipt", date: "Jun 24", size: "210 KB", iconType: .document),
        RecentFile(name: "Tuition Payment Receipt", date: "Jun 24", size: "210 KB", iconType: .document),
        RecentFile(name: "Tuition Payment Receipt", date: "Jun 24", size: "210 KB", iconType: .document),
        RecentFile(name: "Tuition Payment Receipt", date: "Jun 24", size: "210 KB", iconType: .document),
        RecentFile(name: "Tuition Payment Receipt", date: "Jun 24", size: "210 KB", iconType: .document),
        RecentFile(name: "Tuition Payment Receipt", date: "Jun 24", size: "210 KB", iconType: .document)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Blue Header Section
            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                            
                            Text("Home")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    
                    Text("Files, Folders")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .background(Color.blue)
            
            // Main Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // For You Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("For You")
                            .font(.system(size: 22, weight: .bold))
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(forYouCards) { card in
                                    ForYouCardView(card: card)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 16)
                    
                    // Recent Files Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Files")
                                .font(.system(size: 22, weight: .bold))
                            
                            Spacer()
                            
                            Button("See All") {
                                // See all action
                            }
                            .font(.system(size: 17))
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            ForEach(recentFiles) { file in
                                RecentFileRow(file: file)
                                
                                if file.id != recentFiles.last?.id {
                                    Divider()
                                        .padding(.leading, 60)
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            
            // Bottom Navigation Bar
            HStack(spacing: 0) {
                ForEach(0..<5) { index in
                    Button(action: {
                        selectedTab = index
                    }) {
                        VStack(spacing: 4) {
                            if index == 2 {
                                // Camera button with blue circle
                                ZStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 32, height: 32)
                                    
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                }
                            } else {
                                Image(systemName: bottomTabIcon(for: index))
                                    .font(.system(size: 24))
                                    .foregroundColor(selectedTab == index ? .blue : .gray)
                            }
                            
                            if index != 2 {
                                Text(bottomTabLabel(for: index))
                                    .font(.system(size: 10))
                                    .foregroundColor(selectedTab == index ? .blue : .gray)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                    }
                }
            }
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(.separator)),
                alignment: .top
            )
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func bottomTabIcon(for index: Int) -> String {
        switch index {
        case 0: return "house.fill"
        case 1: return "folder.fill"
        case 2: return "camera.fill"
        case 3: return "person.2.fill"
        case 4: return "photo.fill"
        default: return "circle"
        }
    }
    
    private func bottomTabLabel(for index: Int) -> String {
        switch index {
        case 0: return "Home"
        case 1: return "Files"
        case 2: return ""
        case 3: return "Shared"
        case 4: return "Photos"
        default: return ""
        }
    }
}

struct ForYouCardView: View {
    let card: ForYouCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 150)
                    .overlay(
                        Image(systemName: "photo.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.7))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(card.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(12)
            }
        }
    }
}

struct RecentFileRow: View {
    let file: RecentFile
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: file.iconType.icon)
                .font(.system(size: 32))
                .foregroundColor(file.iconType.color)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(file.name)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text(file.date)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    Text("·")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    Text(file.size)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

#Preview {
    NavigationStack {
        OnedriveView()
    }
}
