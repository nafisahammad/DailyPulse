import SwiftUI

public struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showingResetAlert = false
    @State private var resetEmail = ""

    public init() {}

    public var body: some View {
        NavigationView {
            ZStack {
                Color.cardBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // App Logo & Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.namazPrimary, .hydrationPrimary, .sleepPrimary],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 88, height: 88)
                                    .shadow(color: .namazPrimary.opacity(0.3), radius: 10, y: 5)

                                Image(systemName: "heart.text.square.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.white)
                            }

                            Text("DailyPulse")
                                .font(.system(size: 32, weight: .bold, design: .rounded))

                            Text("Namaz, Hydration & Sleep Tracker")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 24)

                        // Input Form Card
                        CardView {
                            VStack(spacing: 16) {
                                // Email Field
                                HStack(spacing: 12) {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.secondary)
                                        .frame(width: 24)

                                    TextField("Email Address", text: $authVM.email)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(12)

                                // Password Field
                                HStack(spacing: 12) {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.secondary)
                                        .frame(width: 24)

                                    SecureField("Password", text: $authVM.password)
                                }
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(12)

                                // Forgot Password Link
                                HStack {
                                    Spacer()
                                    Button("Forgot Password?") {
                                        resetEmail = authVM.email
                                        showingResetAlert = true
                                    }
                                    .font(.footnote)
                                    .foregroundColor(.hydrationPrimary)
                                }

                                // Error Banner
                                if let error = authVM.errorMessage {
                                    Text(error)
                                        .font(.footnote)
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.center)
                                        .padding(.vertical, 4)
                                }

                                if let info = authVM.infoMessage {
                                    Text(info)
                                        .font(.footnote)
                                        .foregroundColor(.green)
                                        .multilineTextAlignment(.center)
                                        .padding(.vertical, 4)
                                }

                                // Login Button
                                Button {
                                    Task {
                                        authVM.isSignUp = false
                                        await authVM.authenticate()
                                    }
                                } label: {
                                    HStack {
                                        if authVM.isLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .padding(.trailing, 8)
                                        }
                                        Text("Sign In")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [.namazPrimary, .hydrationPrimary],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                .disabled(authVM.isLoading)
                            }
                        }

                        // Divider & Demo Login Shortcut
                        VStack(spacing: 16) {
                            HStack {
                                Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                                Text("OR")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                            }

                            Button {
                                Task {
                                    await authVM.quickDemoLogin()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "person.crop.circle.badge.checkmark")
                                    Text("Continue in Demo / Guest Mode")
                                        .fontWeight(.medium)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.secondaryCardBackground)
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }

                        // Switch to Sign Up
                        NavigationLink {
                            SignUpView()
                        } label: {
                            HStack {
                                Text("Don't have an account?")
                                    .foregroundColor(.secondary)
                                Text("Sign Up")
                                    .fontWeight(.bold)
                                    .foregroundColor(.namazPrimary)
                            }
                            .font(.subheadline)
                        }
                        .padding(.top, 12)
                        .padding(.bottom, 32)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
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
                Text("Enter your email address and we will send you a password reset link.")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
