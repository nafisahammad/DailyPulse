import Foundation
import Combine
import SwiftUI

@MainActor
public final class SleepViewModel: ObservableObject {
    @Published public var sleepHours: Double = 7.5 {
        didSet {
            if isLoaded && sleepHours != oldValue {
                autoSave()
            }
        }
    }

    @Published public var selectedQuality: SleepQuality = .good {
        didSet {
            if isLoaded && selectedQuality != oldValue {
                autoSave()
            }
        }
    }

    @Published public var bedtime: Date = Calendar.current.date(byAdding: .hour, value: -8, to: Date()) ?? Date()
    @Published public var wakeTime: Date = Date()
    @Published public var notes: String = ""
    @Published public var showSavedBanner: Bool = false

    private var isLoaded = false
    private let recordStore: DailyRecordStore
    private var cancellables = Set<AnyCancellable>()

    public init(recordStore: DailyRecordStore = DailyRecordStore.shared) {
        self.recordStore = recordStore

        // Sync with active record
        recordStore.$currentRecord
            .receive(on: RunLoop.main)
            .sink { [weak self] record in
                guard let self = self else { return }
                self.isLoaded = false
                self.sleepHours = record.sleepHours
                if let quality = SleepQuality(rawValue: record.sleepQuality) {
                    self.selectedQuality = quality
                }
                if let bedtime = record.bedtime {
                    self.bedtime = bedtime
                }
                if let wakeTime = record.wakeTime {
                    self.wakeTime = wakeTime
                }
                self.isLoaded = true
            }
            .store(in: &cancellables)
    }

    public var formattedDuration: String {
        let hours = Int(sleepHours)
        let minutes = Int((sleepHours - Double(hours)) * 60)
        if minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(hours)h"
        }
    }

    public func calculateHoursFromTimes() {
        let diff = wakeTime.timeIntervalSince(bedtime)
        if diff > 0 {
            let calculatedHours = diff / 3600.0
            let rounded = (calculatedHours * 2).rounded() / 2
            self.sleepHours = min(max(rounded, 1.0), 16.0)
            autoSave()
        }
    }

    private func autoSave() {
        recordStore.updateSleep(
            hours: sleepHours,
            quality: selectedQuality,
            bedtime: bedtime,
            wakeTime: wakeTime
        )
    }

    public func saveSleepRecord() {
        autoSave()

        withAnimation {
            showSavedBanner = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            withAnimation {
                self?.showSavedBanner = false
            }
        }
    }
}
