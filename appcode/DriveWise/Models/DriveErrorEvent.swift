import Foundation

enum DriveErrorEventType: String, Codable, Hashable {
    case brake
    case acceleration
    case turn
}

enum DriveErrorEventSeverity: String, Codable, Hashable {
    case hard
    case veryHard

    var rank: Int {
        switch self {
        case .hard:
            return 1
        case .veryHard:
            return 2
        }
    }

    var numericValue: Double {
        Double(rank)
    }

    static func from(numericValue: Double) -> DriveErrorEventSeverity {
        numericValue >= 2 ? .veryHard : .hard
    }
}

struct DriveErrorEvent: Identifiable, Codable, Hashable {
    let id: UUID
    var timestamp: Date
    var type: DriveErrorEventType
    var severity: DriveErrorEventSeverity
    var latitude: Double?
    var longitude: Double?
    var speedKmh: Double
    var accelerationG: Double
}
