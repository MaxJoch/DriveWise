//
//  DriveWiseError.swift
//  DriveWise
//
//  Custom error handling with localized descriptions
//

import Foundation

enum DriveWiseError: LocalizedError {
    // Storage errors
    case saveFailed(reason: String)
    case loadFailed(reason: String)
    case deleteFailed(reason: String)
    case migrationFailed(reason: String)
    
    // Location errors
    case locationUnavailable
    case locationPermissionDenied
    case geocodingFailed(reason: String)
    
    // Drive state errors
    case driveAlreadyRunning
    case noDriveRunning
    case invalidDriveData
    case driveTooShort(minimumSeconds: Int)
    case driveDistanceTooShort(minimumMeters: Int)
    
    // Motion errors
    case motionUnavailable
    case motionPermissionDenied
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let reason):
            return "Fehler beim Speichern: \(reason)"
        case .loadFailed(let reason):
            return "Fehler beim Laden: \(reason)"
        case .deleteFailed(let reason):
            return "Fehler beim Löschen: \(reason)"
        case .migrationFailed(let reason):
            return "Fehler bei der Migration: \(reason)"
        case .locationUnavailable:
            return "Standortdaten nicht verfügbar"
        case .locationPermissionDenied:
            return "Standortberechtigung erforderlich"
        case .geocodingFailed(let reason):
            return "Adressauflösung fehlgeschlagen: \(reason)"
        case .driveAlreadyRunning:
            return "Eine Fahrt läuft bereits"
        case .noDriveRunning:
            return "Keine aktive Fahrt"
        case .invalidDriveData:
            return "Ungültige Fahrtdaten"
        case .driveTooShort(let minimumSeconds):
            return "Fahrt nicht gespeichert: mindestens \(minimumSeconds / 60) Minute erforderlich"
        case .driveDistanceTooShort(let minimumMeters):
            return "Fahrt nicht gespeichert: mindestens \(minimumMeters) m erforderlich"
        case .motionUnavailable:
            return "Bewegungssensoren nicht verfügbar"
        case .motionPermissionDenied:
            return "Bewegungssensor-Berechtigung erforderlich"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .locationPermissionDenied:
            return "Bitte aktivieren Sie die Standortberechtigung in den Einstellungen"
        case .geocodingFailed:
            return "Versuchen Sie es später erneut oder überprüfen Sie Ihre Internetverbindung"
        case .driveAlreadyRunning:
            return "Bitte beenden Sie die aktuelle Fahrt zuerst"
        case .driveTooShort:
            return "Lassen Sie das Tracking mindestens 1 Minute laufen"
        case .driveDistanceTooShort(let minimumMeters):
            return "Fahren Sie mindestens \(minimumMeters) m"
        case .motionPermissionDenied:
            return "Bitte aktivieren Sie Motion-Sensoren in den Einstellungen"
        default:
            return nil
        }
    }
}
