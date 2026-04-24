import Foundation

enum AppDateTimeFormatter {
    private static let fullDateFormatterDE: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateStyle = .full
        return formatter
    }()

    private static let shortTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    private static let daySectionFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "EEEE, dd.MM.yy"
        return formatter
    }()

    static func fullDateDE(_ date: Date) -> String {
        fullDateFormatterDE.string(from: date)
    }

    static func shortTime(_ date: Date) -> String {
        shortTimeFormatter.string(from: date)
    }

    static func daySection(_ date: Date) -> String {
        daySectionFormatter.string(from: date)
    }

    static func durationClock(_ interval: TimeInterval) -> String {
        let totalMinutes = Int(interval) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return String(format: "%02d:%02d", hours, minutes)
    }

    static func durationClockWithSuffix(_ interval: TimeInterval) -> String {
        "\(durationClock(interval))h"
    }

    /// Formatiert Dauer als "Xh Ymin" oder "Ymin" (für Statistiken)
    static func formattedDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)min"
        } else {
            return "\(minutes)min"
        }
    }

    /// Gibt den kurzen Wochentagsnamen zurück
    static func weekdayName(for weekday: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.shortWeekdaySymbols[weekday - 1]
    }
}
