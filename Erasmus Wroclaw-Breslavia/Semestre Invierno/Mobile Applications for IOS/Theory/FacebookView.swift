//
//  FacebookView.swift
//  iOS-Examples-W6
//
//  Created by Oleksandr Yeroshkin on 17/11/2025.
//

import SwiftUI

struct StoryCard: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let profileImageName: String
    let isCreateStory: Bool
}

struct FacebookView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: Int = 0
    
    let stories: [StoryCard] = [
        StoryCard(name: "Create story", imageName: "person.circle.fill", profileImageName: "person.circle.fill", isCreateStory: true),
        StoryCard(name: "Bente Othman", imageName: "photo", profileImageName: "person.circle.fill", isCreateStory: false),
        StoryCard(name: "Jordan Jones", imageName: "photo", profileImageName: "person.circle.fill", isCreateStory: false),
        StoryCard(name: "Joseph Lyons", imageName: "photo", profileImageName: "person.circle.fill", isCreateStory: false)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: -   Main content
            ScrollView {
                VStack(spacing: 0) {
                    // MARK: -   Top Navigation Bar
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 8) {
                                Text("facebook")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button(action: {}) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.primary)
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 24))
                                    .foregroundColor(.primary)
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "message.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    
                    Divider()
                    
                    // MARK: -   Create Post Section
                    HStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("What's on your mind?")
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    
                    Divider()
                    
                    // MARK: -   Stories Section
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(stories) { story in
                                StoryCardView(story: story)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    
                    Divider()
                    
                    // MARK: -   Feed Post
                    VStack(alignment: .leading, spacing: 0) {
                        // Post Header
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Becker Threads")
                                    .font(.system(size: 15, weight: .semibold))
                                
                                HStack(spacing: 4) {
                                    Text("5h")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                    
                                    Image(systemName: "globe")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                Button(action: {}) {
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary)
                                }
                                
                                Button(action: {}) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        
                        // MARK: - Post Text
                        Text("everything shown is under $100 and was made before 1982! except the 🌻 #vintage #fashion")
                            .font(.system(size: 15))
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                        
                        // MARK: - Post Image
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.green.opacity(0.3), Color.pink.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 400)
                            .overlay(
                                VStack {
                                    Image(systemName: "photo.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("Post Image")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            )
                    }
                    .padding(.bottom, 20)
                }
            }
            
            // MARK: - Bottom Navigation Bar
            HStack(spacing: 0) {
                ForEach(0..<5) { index in
                    Button(action: {
                        selectedTab = index
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: bottomTabIcon(for: index))
                                .font(.system(size: 24))
                                .foregroundColor(selectedTab == index ? .blue : .gray)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
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
        case 1: return "play.rectangle.fill"
        case 2: return "storefront.fill"
        case 3: return "bell.fill"
        case 4: return "line.3.horizontal"
        default: return "circle"
        }
    }
}

struct StoryCardView: View {
    let story: StoryCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .top) {
                // Story background
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: story.isCreateStory ? [Color.gray.opacity(0.3), Color.gray.opacity(0.1)] : [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 180)
                
                if story.isCreateStory {
                    VStack {
                        Spacer()
                        
                        // MARK: -   Profile picture with plus button
                        ZStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 15, y: 15)
                        }
                        .padding(.bottom, 8)
                    }
                } else {
                    VStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .padding(.top, 8)
                        
                        Spacer()
                    }
                }
            }
            
            // MARK: -   Story name
            Text(story.name)
                .font(.system(size: 12, weight: story.isCreateStory ? .regular : .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .frame(width: 100, alignment: .leading)
                .padding(.top, 4)
        }
    }
}

#Preview {
    NavigationStack {
        FacebookView()
    }
}
