import Foundation

#if canImport(ActivityKit)
import ActivityKit

@MainActor
final class DriveLiveActivityManager {
    static let shared = DriveLiveActivityManager()

    private var activity: Activity<DriveTrackingActivityAttributes>?
    private var lastUpdateDate: Date = .distantPast

    private init() {}

    func start(
        distanceKm: Double,
        elapsedSeconds: Int,
        errorCount: Int,
        status: DriveTrackingActivityAttributes.ContentState.Status
    ) {
        guard #available(iOS 16.2, *), ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = DriveTrackingActivityAttributes(
            driveName: "Aktuelle Fahrt",
            startedAt: Date()
        )

        let state = DriveTrackingActivityAttributes.ContentState(
            distanceKm: distanceKm,
            elapsedSeconds: elapsedSeconds,
            errorCount: errorCount,
            status: status
        )

        let content = ActivityContent(state: state, staleDate: nil)

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            lastUpdateDate = Date()
        } catch {
            activity = nil
        }
    }

    func update(
        distanceKm: Double,
        elapsedSeconds: Int,
        errorCount: Int,
        status: DriveTrackingActivityAttributes.ContentState.Status
    ) {
        guard #available(iOS 16.2, *), let activity else { return }

        let now = Date()
        guard now.timeIntervalSince(lastUpdateDate) >= 1.0 else { return }

        let updatedState = DriveTrackingActivityAttributes.ContentState(
            distanceKm: distanceKm,
            elapsedSeconds: elapsedSeconds,
            errorCount: errorCount,
            status: status
        )

        let content = ActivityContent(state: updatedState, staleDate: nil)

        Task {
            await activity.update(content)
        }

        lastUpdateDate = now
    }

    func end(
        distanceKm: Double,
        elapsedSeconds: Int,
        errorCount: Int,
        status: DriveTrackingActivityAttributes.ContentState.Status
    ) {
        guard #available(iOS 16.2, *), let activity else { return }

        let finalState = DriveTrackingActivityAttributes.ContentState(
            distanceKm: distanceKm,
            elapsedSeconds: elapsedSeconds,
            errorCount: errorCount,
            status: status
        )

        let content = ActivityContent(state: finalState, staleDate: Date())

        Task {
            await activity.end(content, dismissalPolicy: .immediate)
        }

        self.activity = nil
        lastUpdateDate = .distantPast
    }
}
#endif
