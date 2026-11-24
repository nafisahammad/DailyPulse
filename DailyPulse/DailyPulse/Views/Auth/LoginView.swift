import SwiftUI

public struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showingResetAlert = false
    @State private var resetEmail = ""

    public init() {}

    public var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .center, spacing: 8) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)

                        Text("DailyPulse")
                            .font(.title.bold())

                        Text("Namaz, Hydration & Sleep Tracker")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }

                Section("Sign In") {
                    TextField("Email", text: $authVM.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    SecureField("Password", text: $authVM.password)

                    if let error = authVM.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    if let info = authVM.infoMessage {
                        Text(info)
                            .font(.caption)
                            .foregroundColor(.green)
                    }

                    Button {
                        Task {
                            authVM.isSignUp = false
                            await authVM.authenticate()
                        }
                    } label: {
                        HStack {
                            if authVM.isLoading {
                                ProgressView()
                                    .padding(.trailing, 4)
                            }
                            Text("Sign In")
                                .bold()
                        }
                    }
                    .disabled(authVM.isLoading)
                }

                Section {
                    Button("Forgot Password?") {
                        resetEmail = authVM.email
                        showingResetAlert = true
                    }

                    NavigationLink("Create an Account", destination: SignUpView())

                    Button("Continue as Demo / Guest") {
                        Task {
                            await authVM.quickDemoLogin()
                        }
                    }
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Welcome")
            .alert("Reset Password", isPresented: $showingResetAlert) {
                TextField("Email Address", text: $resetEmail)
                Button("Send Link") {
                    authVM.email = resetEmail
                    Task {
                        await authVM.resetPassword()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter your email to receive a password reset link.")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
