import Foundation

public struct AppUser: Identifiable, Codable, Equatable {
    public let id: String
    public let email: String
    public var displayName: String
    public let createdAt: Date

    public init(id: String, email: String, displayName: String = "", createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.createdAt = createdAt
    }
}
