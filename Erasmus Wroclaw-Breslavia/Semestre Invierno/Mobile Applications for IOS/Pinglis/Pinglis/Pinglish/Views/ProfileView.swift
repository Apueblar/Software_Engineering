//
//  ProfileView.swift
//  Pinglish
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.accent)

                Text(authVM.currentUser?.username ?? "No user")
                    .font(.title2.bold())

                Text("Points: \(authVM.currentUser?.points ?? 0)")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Button {
                    authVM.logout()
                } label: {
                    Text("Log Out")
                }
                .buttonStyle(SecondaryButtonStyle())
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Account")
            .background(Color.white.ignoresSafeArea())
        }
        .tint(.accentColor)
        .background(Color.white)
    }
}
