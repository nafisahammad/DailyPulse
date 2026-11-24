import Foundation
import Combine

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

public protocol FirestoreServiceProtocol {
    func saveDailyRecord(_ record: DailyRecord) async throws
    func fetchDailyRecord(userId: String, dateKey: String) async throws -> DailyRecord?
    func fetchHistory(userId: String, limitDays: Int) async throws -> [DailyRecord]
}

public final class FirestoreService: FirestoreServiceProtocol {
    public static let shared = FirestoreService()

    private let localStoreKeyPrefix = "DailyPulse_Records_"

    private init() {}

    // MARK: - Save Daily Record to Firestore
    public func saveDailyRecord(_ record: DailyRecord) async throws {
        guard !record.userId.isEmpty else {
            throw NSError(
                domain: "DailyPulseFirestore",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated. Cannot save record."]
            )
        }

        if FirebaseManager.shared.isConfigured {
            #if canImport(FirebaseFirestore)
            let db = Firestore.firestore()
            let docRef = db.collection("users")
                .document(record.userId)
                .collection("daily_records")
                .document(record.id)

            try await docRef.setData(record.dictionaryRepresentation, merge: true)
            print("☁️ [Firestore] Successfully saved/updated record for \(record.id)")
            #endif
        }

        // Always save to local cache for instant offline access and responsive UI
        saveToLocalCache(record)
    }

    // MARK: - Fetch Daily Record for Date
    public func fetchDailyRecord(userId: String, dateKey: String) async throws -> DailyRecord? {
        guard !userId.isEmpty else { return nil }

        if FirebaseManager.shared.isConfigured {
            #if canImport(FirebaseFirestore)
            let db = Firestore.firestore()
            let docRef = db.collection("users")
                .document(userId)
                .collection("daily_records")
                .document(dateKey)

            let snapshot = try await docRef.getDocument()
            if let rawData = snapshot.data() {
                var data = rawData
                if data["id"] == nil {
                    data["id"] = snapshot.documentID
                }
                if let record = DailyRecord.from(dictionary: data) {
                    saveToLocalCache(record)
                    return record
                }
            }
            #endif
        }

        // Fallback to local cache
        return fetchFromLocalCache(userId: userId, dateKey: dateKey)
    }

    // MARK: - Fetch History (Past records)
    public func fetchHistory(userId: String, limitDays: Int = 30) async throws -> [DailyRecord] {
        guard !userId.isEmpty else { return [] }

        var records: [DailyRecord] = []

        if FirebaseManager.shared.isConfigured {
            #if canImport(FirebaseFirestore)
            let db = Firestore.firestore()
            let query = db.collection("users")
                .document(userId)
                .collection("daily_records")
                .order(by: "date", descending: true)
                .limit(to: limitDays)

            do {
                let snapshot = try await query.getDocuments()
                records = snapshot.documents.compactMap { doc in
                    var data = doc.data()
                    if data["id"] == nil {
                        data["id"] = doc.documentID
                    }
                    return DailyRecord.from(dictionary: data)
                }
                if !records.isEmpty {
                    return records
                }
            } catch {
                print("⚠️ [Firestore] fetchHistory error: \(error.localizedDescription)")
            }
            #endif
        }

        // Fallback to local cached records
        records = fetchAllFromLocalCache(userId: userId)
        return records.sorted(by: { $0.date > $1.date })
    }

    // MARK: - Local Cache Helpers (Offline & Demo Mode)
    private func localKey(userId: String) -> String {
        "\(localStoreKeyPrefix)\(userId)"
    }

    private func saveToLocalCache(_ record: DailyRecord) {
        let key = localKey(userId: record.userId)
        var allRecords = fetchAllFromLocalCache(userId: record.userId)
        if let index = allRecords.firstIndex(where: { $0.id == record.id }) {
            allRecords[index] = record
        } else {
            allRecords.append(record)
        }

        if let encoded = try? JSONEncoder().encode(allRecords) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    private func fetchFromLocalCache(userId: String, dateKey: String) -> DailyRecord? {
        let allRecords = fetchAllFromLocalCache(userId: userId)
        return allRecords.first(where: { $0.id == dateKey })
    }

    private func fetchAllFromLocalCache(userId: String) -> [DailyRecord] {
        let key = localKey(userId: userId)
        guard let data = UserDefaults.standard.data(forKey: key),
              let list = try? JSONDecoder().decode([DailyRecord].self, from: data) else {
            return []
        }
        return list
    }
}
