//
//  LoginView.swift
//  Pinglish
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.colorScheme) var colorScheme

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                Image("duba")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .accessibilityHidden(true)

                Text("PINGLISH")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.accent)

                VStack(spacing: 14) {
                    TextField(NSLocalizedString("Username", comment: ""), text: $username)
                        .accessibilityIdentifier("user_input")
                        .labelsHidden()
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .roundedInput()

                    SecureField(NSLocalizedString("Password", comment: ""), text: $password)
                        .roundedInput()
                        .accessibilityIdentifier("password_input")
                }
                .padding(.horizontal)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.horizontal)
                }

                VStack(spacing: 12) {
                    Button {
                        do {
                            try authVM.signIn(username: username, password: password)
                        } catch {
                            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Login error."
                        }
                    } label: {
                        Text("GET STARTED NOW")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                    .accessibilityIdentifier("login_button")

                    NavigationLink(destination: RegisterView()) {
                        Text("Sign Up")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .padding(.horizontal)
                    .accessibilityIdentifier("singup_link")
                }

                Spacer()
            }
            .background(Color.white.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .tint(.accentColor)
        .background(Color.white)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
