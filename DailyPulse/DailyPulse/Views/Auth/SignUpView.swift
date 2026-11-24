import SwiftUI

public struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    public init() {}

    public var body: some View {
        Form {
            Section("Account Details") {
                TextField("Full Name", text: $authVM.displayName)

                TextField("Email", text: $authVM.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password (at least 6 characters)", text: $authVM.password)

                SecureField("Confirm Password", text: $authVM.confirmPassword)

                if let error = authVM.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }

                Button {
                    Task {
                        authVM.isSignUp = true
                        await authVM.authenticate()
                    }
                } label: {
                    HStack {
                        if authVM.isLoading {
                            ProgressView()
                                .padding(.trailing, 4)
                        }
                        Text("Create Account")
                            .bold()
                    }
                }
                .disabled(authVM.isLoading)
            }
        }
        .navigationTitle("Sign Up")
    }
}
