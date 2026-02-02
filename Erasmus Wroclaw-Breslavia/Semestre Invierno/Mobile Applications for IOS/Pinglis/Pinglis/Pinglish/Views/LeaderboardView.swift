//
//  LeaderboardView.swift
//  Pinglish
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var leaderboardVM: LeaderboardViewModel

    private var topThree: [LeaderboardEntry] {
        Array(leaderboardVM.leaderboard.prefix(3))
    }

    private var others: ArraySlice<LeaderboardEntry> {
        leaderboardVM.leaderboard.dropFirst(3)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                Image("dubaLeaderboard")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 140)
                    .accessibilityHidden(true)

                if !topThree.isEmpty {
                    podiumView(entries: topThree)
                        .padding(.horizontal)
                } else {
                    Text("No players yet")
                        .foregroundColor(.secondary)
                }

                List {
                    ForEach(Array(others.enumerated()), id: \.element.id) { index, entry in
                        HStack {
                            Text("\(index + 4).")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(width: 30, alignment: .leading)

                            Text(entry.username)
                                .font(.body)

                            Spacer()

                            Text("\(entry.points)")
                                .font(.body.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.white)
            }
            .navigationTitle("Leaderboard")
        }
        .tint(.accentColor)
        .background(Color.white.ignoresSafeArea())
    }

    @ViewBuilder
    private func podiumView(entries: [LeaderboardEntry]) -> some View {
        let first = entries.indices.contains(0) ? entries[0] : nil
        let second = entries.indices.contains(1) ? entries[1] : nil
        let third = entries.indices.contains(2) ? entries[2] : nil

        HStack(alignment: .bottom, spacing: 16) {
            podiumColumn(place: 2, entry: second, color: .accentColor, height: 120, medal: "🥈")
            podiumColumn(place: 1, entry: first, color: .accentColor, height: 160, medal: "🥇")
            podiumColumn(place: 3, entry: third, color: .accentColor, height: 100, medal: "🥉")
        }
        .frame(maxWidth: .infinity)
    }

    private func podiumColumn(place: Int, entry: LeaderboardEntry?, color: Color, height: CGFloat, medal: String) -> some View {
        VStack(spacing: 8) {
            if let entry {
                Text(entry.username)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("\(entry.points)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)

                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.12))
                    .frame(width: 90, height: height)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color, lineWidth: 2)
                    )
                    .overlay(
                        Text(medal)
                            .font(.largeTitle)
                            .foregroundColor(.primary)
                    )
                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
            } else {
                VStack(spacing: 8) {
                    Text("—").font(.headline)
                    Text("0").font(.subheadline.monospacedDigit()).foregroundStyle(.secondary)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.08))
                        .frame(width: 90, height: height)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(color.opacity(0.6), lineWidth: 1)
                        )
                        .overlay(
                            Text(medal)
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                }
            }
        }
        .frame(width: 100)
    }
}
