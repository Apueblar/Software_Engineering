//
//  RegisterView.swift
//  Pinglish
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                Text("Create account")
                    .font(.title2.bold())
                    .padding(.top, 32)

                VStack(spacing: 14) {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .roundedInput()

                    SecureField("Password", text: $password)
                        .roundedInput()

                    SecureField("Confirm Password", text: $confirmPassword)
                        .roundedInput()
                }
                .padding(.horizontal)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.horizontal)
                }

                Button {
                    guard password == confirmPassword else {
                        errorMessage = "Passwords do not match."
                        return
                    }
                    do {
                        try authVM.signUp(username: username, password: password)
                    } catch {
                        errorMessage = (error as? LocalizedError)?.errorDescription ?? "Register error."
                    }
                } label: {
                    Text("Register")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Sign Up")
            .background(Color.white.ignoresSafeArea())
        }
        .tint(.accentColor)
        .background(Color.white)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(AuthViewModel())
    }
}
