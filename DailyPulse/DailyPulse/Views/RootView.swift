import SwiftUI

public struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel

    public init() {}

    public var body: some View {
        Group {
            if authVM.isAuthenticated {
                MainTabView()
                    .transition(.opacity)
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: authVM.isAuthenticated)
    }
}
