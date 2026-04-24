# Firebase Setup (kostenfrei, ohne iCloud)

## Ziel
DriveWise speichert Fahrten und relevante App-Einstellungen pro Nutzer in Firebase Firestore.

- Keine iCloud-/Push-Capability erforderlich.
- Funktioniert mit Firebase Spark Plan (kostenlos).
- Daten bleiben strikt pro eingeloggtem Nutzer getrennt.

## Schnellcheck (in dieser Reihenfolge)
1. Firebase Projekt vorhanden.
2. iOS App in Firebase registriert (Bundle ID passt exakt).
3. Datei GoogleService-Info.plist im Xcode-Projekt enthalten.
4. Authentication mit E-Mail/Passwort aktiviert.
5. Firestore aktiviert.
6. Firestore Rules gesetzt und deployed.
7. In DriveWise mit zwei verschiedenen Accounts testen.

## 1) Firebase Projekt und iOS App
1. Firebase Console -> Projekt auswaehlen oder neu anlegen.
2. Project Settings -> Your apps -> iOS App hinzufuegen.
3. Bundle Identifier exakt wie in Xcode setzen (Target DriveWise).
4. GoogleService-Info.plist herunterladen.
5. In Xcode in das App-Target aufnehmen (Copy items if needed aktivieren).

Hinweis:
- Wenn in Xcode bereits eine passende GoogleService-Info.plist vorhanden ist und Firebase Auth schon funktioniert, kannst du diesen Schritt ueberspringen.

## 2) Authentication aktivieren
1. Firebase Console -> Build -> Authentication.
2. Reiter Sign-in method.
3. Email/Password aktivieren.
4. Speichern.

Ohne diesen Schritt sind Login/Signup-Calls aus der App nicht nutzbar.

## 3) Firestore aktivieren
1. Firebase Console -> Build -> Firestore Database.
2. Create database.
3. Modus: Production.
4. Region in deiner Naehe waehlen (einmalig).

## 4) Firestore Security Rules setzen
In Firestore Rules folgenden Inhalt setzen und deployen:

```txt
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Wirkung:
- Jeder Nutzer darf nur unter users/{eigene uid}/... lesen und schreiben.
- Kein Nutzer kann Daten eines anderen Nutzers sehen.

## 5) Welche Daten DriveWise in Firestore schreibt
Pfade:
- Fahrten: users/{uid}/drives/{driveId}
- Einstellungen: users/{uid}/settings/app

Verhalten:
- Initial einmaliger Pull nach Login.
- Fahrten bei Speichern/Loeschen synchronisiert.
- Einstellungen werden debounced synchronisiert (gebuendelte Writes).

## 6) Kostenfrei bleiben (wichtig)
Die aktuelle Implementierung ist bereits auf niedrige Kosten optimiert:
- Kein permanenter Realtime-Listener.
- Keine hochfrequenten Sensor-Uploads.
- Nur punktuelle Writes (Save/Delete + gebuendelte Settings).

Empfehlungen:
1. Spark Plan aktiv lassen.
2. In Google Cloud ein Budget + Alert setzen (z. B. 1 EUR als Warnschwelle).
3. Keine grossen Test-Importe mit Tausenden Fahrten durchfuehren.
4. Bei Lasttests mit mehreren Accounts auf Read/Write-Zaehler in Firebase Console achten.

## 7) Funktionstest (2 Minuten)
1. Mit Account A einloggen und eine kurze Testfahrt speichern.
2. In Firebase Console pruefen, ob Dokument unter users/{uid-von-A}/drives/... existiert.
3. Auf zweitem Geraet oder Simulator mit demselben Account A einloggen.
4. Pruefen, ob Fahrt geladen wird.
5. Mit Account B einloggen und pruefen, dass A-Daten nicht sichtbar sind.

## 8) Migration von lokal auf Firebase
Beim ersten erfolgreichen Sync gilt:
- Wenn Firebase fuer den Nutzer leer ist, werden lokale Fahrten einmalig hochgeladen.
- Danach ist Firebase die Quelle fuer geraeteuebergreifende Konsistenz.

## Troubleshooting
- Login klappt nicht:
  - Pruefen, ob Email/Password Provider in Authentication aktiv ist.
- Firestore bleibt leer:
  - Pruefen, ob Nutzer wirklich eingeloggt ist.
  - Pruefen, ob Firestore Rules deployed wurden.
  - Pruefen, ob GoogleService-Info.plist zum richtigen Firebase-Projekt gehoert.
- Permission denied in Firestore:
  - Meist stimmt uid in Rule-Pfad nicht oder Nutzer ist nicht authentifiziert.
