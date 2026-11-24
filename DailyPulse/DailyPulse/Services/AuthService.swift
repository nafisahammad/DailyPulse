import Foundation
import Combine

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

public protocol AuthServiceProtocol {
    var currentUser: AppUser? { get }
    var userPublisher: AnyPublisher<AppUser?, Never> { get }

    func signUp(email: String, password: String, displayName: String) async throws -> AppUser
    func signIn(email: String, password: String) async throws -> AppUser
    func signOut() throws
    func sendPasswordReset(email: String) async throws
}

public final class AuthService: ObservableObject, AuthServiceProtocol {
    public static let shared = AuthService()

    @Published public private(set) var currentUser: AppUser?

    public var userPublisher: AnyPublisher<AppUser?, Never> {
        $currentUser.eraseToAnyPublisher()
    }

    #if canImport(FirebaseAuth)
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    #endif

    private let userDefaultsKey = "DailyPulse_CachedUser"

    private init() {
        setupAuthStateListener()
    }

    deinit {
        #if canImport(FirebaseAuth)
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        #endif
    }

    private func setupAuthStateListener() {
        if FirebaseManager.shared.isConfigured {
            #if canImport(FirebaseAuth)
            authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
                DispatchQueue.main.async {
                    if let firebaseUser = firebaseUser {
                        let user = AppUser(
                            id: firebaseUser.uid,
                            email: firebaseUser.email ?? "",
                            displayName: firebaseUser.displayName ?? ""
                        )
                        self?.currentUser = user
                    } else {
                        self?.currentUser = nil
                    }
                }
            }
            return
            #endif
        }

        // Offline / Demo fallback: Restore last session if saved
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(AppUser.self, from: data) {
            self.currentUser = user
        }
    }

    // MARK: - Sign Up
    public func signUp(email: String, password: String, displayName: String) async throws -> AppUser {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              password.count >= 6 else {
            throw NSError(
                domain: "DailyPulseAuth",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Email must be valid and password at least 6 characters."]
            )
        }

        if FirebaseManager.shared.isConfigured {
            #if canImport(FirebaseAuth)
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let changeRequest = authResult.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()

            let user = AppUser(
                id: authResult.user.uid,
                email: authResult.user.email ?? email,
                displayName: displayName
            )
            await MainActor.run { self.currentUser = user }
            return user
            #endif
        }

        // Demo / Offline Mode Mock SignUp
        let mockId = "user_\(UUID().uuidString.prefix(8))"
        let user = AppUser(id: mockId, email: email, displayName: displayName)
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
        await MainActor.run { self.currentUser = user }
        return user
    }

    // MARK: - Sign In
    public func signIn(email: String, password: String) async throws -> AppUser {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty else {
            throw NSError(
                domain: "DailyPulseAuth",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Please enter both email and password."]
            )
        }

        if FirebaseManager.shared.isConfigured {
            #if canImport(FirebaseAuth)
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            let user = AppUser(
                id: authResult.user.uid,
                email: authResult.user.email ?? email,
                displayName: authResult.user.displayName ?? ""
            )
            await MainActor.run { self.currentUser = user }
            return user
            #endif
        }

        // Demo / Offline Mode Mock SignIn
        let user = AppUser(
            id: "demo_user_101",
            email: email,
            displayName: email.components(separatedBy: "@").first?.capitalized ?? "Explorer"
        )
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
        await MainActor.run { self.currentUser = user }
        return user
    }

    // MARK: - Sign Out
    public func signOut() throws {
        if FirebaseManager.shared.isConfigured {
            #if canImport(FirebaseAuth)
            try Auth.auth().signOut()
            #endif
        }
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        DispatchQueue.main.async {
            self.currentUser = nil
        }
    }

    // MARK: - Password Reset
    public func sendPasswordReset(email: String) async throws {
        guard !email.isEmpty else {
            throw NSError(
                domain: "DailyPulseAuth",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Please enter your email address."]
            )
        }

        if FirebaseManager.shared.isConfigured {
            #if canImport(FirebaseAuth)
            try await Auth.auth().sendPasswordReset(withEmail: email)
            return
            #endif
        }

        // In demo mode, simulate success
        print("Demo: Password reset requested for \(email)")
    }
}
