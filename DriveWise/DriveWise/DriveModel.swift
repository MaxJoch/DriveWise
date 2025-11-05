import Foundation
import SwiftUI
import Combine

struct Drive: Identifiable, Codable, Hashable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let from: String
    let to: String
    let distanceKm: Double
    let avgSpeedKmh: Double
    let maxSpeedKmh: Double
    let errorCount: Int

    var duration: TimeInterval { endDate.timeIntervalSince(startDate) }
}

final class DriveManager: ObservableObject {
    // explicit publisher to satisfy ObservableObject requirements in all Swift versions
    let objectWillChange = ObservableObjectPublisher()
    @Published private(set) var drives: [Drive] = []

    // Current drive state
    @Published var isDriving: Bool = false
    @Published var elapsedSeconds: Int = 0
    @Published var distanceKm: Double = 0
    @Published var currentSpeedKmh: Double = 0
    @Published var maxSpeedKmh: Double = 0
    @Published var errorCount: Int = 0

    private var startDate: Date?
    private var timer: Timer?

    // For demo / UI purposes we simulate movement while driving
    func startDrive(from: String = "Startpunkt", to: String = "Zielpunkt") {
        // reset counters
        elapsedSeconds = 0
        distanceKm = 0
        currentSpeedKmh = 0
        maxSpeedKmh = 0
        errorCount = 0

        startDate = Date()
        isDriving = true

        // start a simple timer that simulates speed/distance
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedSeconds += 1

            // simulate speed changes
            let base = 40.0
            let variance = Double(Int.random(in: -10...30))
            let speed = max(0, base + variance * 0.5)
            self.currentSpeedKmh = speed
            if speed > self.maxSpeedKmh { self.maxSpeedKmh = speed }

            // distance per second = km/h -> km/s = km/h / 3600
            self.distanceKm += speed / 3600.0

            // occasionally generate a simulated error (for demo)
            if Int.random(in: 0...60) == 0 {
                self.errorCount += 1
            }
        }
    }

    func stopDrive(from: String = "Startpunkt", to: String = "Zielpunkt") {
        guard isDriving else { return }
        timer?.invalidate()
        timer = nil
        isDriving = false

        let end = Date()
        let start = startDate ?? end

        // create a Drive object and append
        let avgSpeed = elapsedSeconds > 0 ? (distanceKm / Double(elapsedSeconds) * 3600.0) : 0
        let drive = Drive(id: UUID(), startDate: start, endDate: end, from: from, to: to, distanceKm: distanceKm, avgSpeedKmh: avgSpeed, maxSpeedKmh: maxSpeedKmh, errorCount: errorCount)
        drives.insert(drive, at: 0)

        // reset current values except keep last values for detail preview
        elapsedSeconds = 0
        distanceKm = 0
        currentSpeedKmh = 0
        maxSpeedKmh = 0
        errorCount = 0
    }

    // helper for preview / sample data
    func addSampleDrives() {
        let now = Date()
        let d1 = Drive(id: UUID(), startDate: now.addingTimeInterval(-3600 * 24 * 2), endDate: now.addingTimeInterval(-3600 * 24 * 2 + 600), from: "Malsch", to: "Durmersheim", distanceKm: 4.7, avgSpeedKmh: 28, maxSpeedKmh: 82, errorCount: 2)
        let d2 = Drive(id: UUID(), startDate: now.addingTimeInterval(-3600 * 24 * 3), endDate: now.addingTimeInterval(-3600 * 24 * 3 + 400), from: "Malsch", to: "Durmersheim", distanceKm: 4.7, avgSpeedKmh: 42, maxSpeedKmh: 95, errorCount: 1)
        drives = [d1, d2]
    }

    // remove drives safely from outside
    func removeDrives(at offsets: IndexSet) {
        drives.remove(atOffsets: offsets)
    }
}
