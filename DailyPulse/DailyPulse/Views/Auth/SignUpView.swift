import SwiftUI

public struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    public init() {}

    public var body: some View {
        ZStack {
            Color.cardBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold, design: .rounded))

                        Text("Join DailyPulse to track prayers, water, and sleep with cloud sync.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    .padding(.top, 16)

                    // Card Form
                    CardView {
                        VStack(spacing: 16) {
                            // Display Name
                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.secondary)
                                    .frame(width: 24)

                                TextField("Full Name", text: $authVM.displayName)
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)

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

                                SecureField("Password (min 6 characters)", text: $authVM.password)
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)

                            // Confirm Password Field
                            HStack(spacing: 12) {
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(.secondary)
                                    .frame(width: 24)

                                SecureField("Confirm Password", text: $authVM.confirmPassword)
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)

                            // Error Message
                            if let error = authVM.errorMessage {
                                Text(error)
                                    .font(.footnote)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.vertical, 4)
                            }

                            // Sign Up Button
                            Button {
                                Task {
                                    authVM.isSignUp = true
                                    await authVM.authenticate()
                                }
                            } label: {
                                HStack {
                                    if authVM.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .padding(.trailing, 8)
                                    }
                                    Text("Create Account")
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

                    // Back to Login Link
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Text("Already have an account?")
                                .foregroundColor(.secondary)
                            Text("Sign In")
                                .fontWeight(.bold)
                                .foregroundColor(.namazPrimary)
                        }
                        .font(.subheadline)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }
}
