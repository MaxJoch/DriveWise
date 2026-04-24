# DriveWise Live Activity Setup

## 1) Widget Extension Target anlegen
1. In Xcode: **File > New > Target...**
2. Wähle **Widget Extension**
3. Name: `DriveWiseWidgetExtension`
4. Bei Fragen nach Beispiel-Widget-UI kannst du die Defaults lassen.

## 2) Dateien diesem Target zuordnen
Füge aus diesem Ordner folgende Dateien dem neuen Target hinzu:
- `DriveWiseWidgetBundle.swift`
- `DriveTrackingActivityAttributes.swift`
- `DriveTrackingLiveActivity.swift`
- `Info.plist`

## 3) Alte Template-Dateien entfernen
Lösche die vom Xcode-Template erzeugten Widget-Dateien aus dem Target (falls vorhanden), damit nur die oben genannten aktiv sind.

## 4) Signing und Bundle Identifier prüfen
- Team: gleich wie App-Target
- Bundle Identifier z. B. `studienarbeit.DriveWise.Widget`

## 5) App Group / Capabilities
Für die aktuelle Umsetzung nicht zwingend nötig, da Updates direkt über ActivityKit laufen.

## 6) Testen
1. App auf echtem iPhone starten (Live Activities brauchen echtes Gerät)
2. In der App eine Fahrt starten
3. Sperrbildschirm öffnen und Live Activity prüfen
4. Fahrt beenden und prüfen, dass die Activity endet

## Hinweise
- Die App-Seite (Start/Update/Stop) ist bereits implementiert.
- Werte in der Live Activity: `KM`, `Zeit`, `Fehler`, `Status`.
