import Foundation
import Combine

@MainActor
public final class AuthViewModel: ObservableObject {
    @Published public var email = ""
    @Published public var password = ""
    @Published public var confirmPassword = ""
    @Published public var displayName = ""
    @Published public var isSignUp = false

    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var infoMessage: String?

    @Published public var currentUser: AppUser?

    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    public init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
        self.currentUser = authService.currentUser

        authService.userPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] user in
                self?.currentUser = user
            }
            .store(in: &cancellables)
    }

    public var isAuthenticated: Bool {
        currentUser != nil
    }

    public func authenticate() async {
        errorMessage = nil
        infoMessage = nil

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Please enter an email address."
            return
        }

        guard !password.isEmpty else {
            errorMessage = "Please enter your password."
            return
        }

        if isSignUp {
            guard password.count >= 6 else {
                errorMessage = "Password must be at least 6 characters long."
                return
            }
            guard password == confirmPassword else {
                errorMessage = "Passwords do not match."
                return
            }
        }

        isLoading = true
        defer { isLoading = false }

        do {
            if isSignUp {
                let name = displayName.isEmpty ? trimmedEmail.components(separatedBy: "@").first ?? "User" : displayName
                let user = try await authService.signUp(email: trimmedEmail, password: password, displayName: name)
                self.currentUser = user
            } else {
                let user = try await authService.signIn(email: trimmedEmail, password: password)
                self.currentUser = user
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    public func resetPassword() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Please enter your email to receive a reset link."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.sendPasswordReset(email: trimmedEmail)
            infoMessage = "Password reset instructions sent to \(trimmedEmail)."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func quickDemoLogin() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let user = try await authService.signIn(email: "demo@dailypulse.app", password: "password123")
            self.currentUser = user
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    public func signOut() {
        do {
            try authService.signOut()
            self.currentUser = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
