import Foundation

#if canImport(ActivityKit)
import ActivityKit

struct DriveTrackingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        enum Status: String, Codable, Hashable {
            case good
            case warning
            case critical

            var title: String {
                switch self {
                case .good:
                    return "Alles gut"
                case .warning:
                    return "Achtung"
                case .critical:
                    return "Warnung"
                }
            }
        }

        var distanceKm: Double
        var elapsedSeconds: Int
        var errorCount: Int
        var status: Status
    }

    var driveName: String
    var startedAt: Date
}
#endif
