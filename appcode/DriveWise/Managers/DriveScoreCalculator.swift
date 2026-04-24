import Foundation

struct DriveScoreCalculator {
    static func calculateScore(
        distanceKm: Double,
        durationSeconds: Int,
        hardBrakeCount: Int,
        veryHardBrakeCount: Int,
        hardAccelCount: Int,
        veryHardAccelCount: Int,
        sharpTurnCount: Int,
        verySharpTurnCount: Int,
        speedingKm: Double
    ) -> Int {
        var score = 100
        let durationMinutes = Double(durationSeconds) / 60.0

        // ---|--- PENALTIES ---|---
        score -= hardBrakeCount * 5
        score -= veryHardBrakeCount * 10
        score -= hardAccelCount * 4
        score -= veryHardAccelCount * 8
        score -= sharpTurnCount * 3
        score -= verySharpTurnCount * 7
        score -= Int(speedingKm * 2.0)

        // ---|--- BONUSES ---|---
        let totalErrors = hardBrakeCount + veryHardBrakeCount +
                         hardAccelCount + veryHardAccelCount +
                         sharpTurnCount + verySharpTurnCount

        // Fehlerquote pro 10 km
        let errorsPerKm = distanceKm > 0 ? Double(totalErrors) / distanceKm : 0

        if errorsPerKm < 0.1 {  // < 1 Fehler pro 10 km
            score += 10
        } else if errorsPerKm < 0.3 {  // < 3 Fehler pro 10 km
            score += 5
        }

        // Fehlerquote pro Minute
        let errorsPerMin = durationMinutes > 0 ? Double(totalErrors) / durationMinutes : 0

        if errorsPerMin < 0.05 {  // < 1 Fehler pro 20 Minuten
            score += 10
        } else if errorsPerMin < 0.15 {  // < 1 Fehler pro 6-7 Minuten
            score += 5
        }

        // Bonus: Konsistente Fahrt
        let consistency = abs(errorsPerKm - errorsPerMin)
        if consistency < 0.05 {
            score += 5
        }

        // Bonus: Lange Fahrt ohne viele Fehler
        if distanceKm > 50 && totalErrors < 5 {
            score += 8
        }

        // Bonus: Kurze, saubere Fahrt
        if distanceKm < 10 && totalErrors == 0 {
            score += 5
        }

        return max(0, min(120, score))
    }
    
    /// Bequeme Variante, die ein Drive-Objekt nutzt
    static func calculateScore(for drive: Drive) -> Int {
        return calculateScore(
            distanceKm: drive.distanceKm,
            durationSeconds: Int(drive.duration),
            hardBrakeCount: drive.hardBrakeCount,
            veryHardBrakeCount: drive.veryHardBrakeCount,
            hardAccelCount: drive.hardAccelCount,
            veryHardAccelCount: drive.veryHardAccelCount,
            sharpTurnCount: drive.sharpTurnCount,
            verySharpTurnCount: drive.verySharpTurnCount,
            speedingKm: drive.speedingKm
        )
    }
}
