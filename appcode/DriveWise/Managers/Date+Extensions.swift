import Foundation

extension Date {
    /// Gibt den Start der Woche für das Datum zurück
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
}
