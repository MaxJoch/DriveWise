# DriveWise – Fahrstilanalyse per iOS-App

DriveWise ist eine iOS-App, die das Fahrverhalten von Autofahrenden anhand von Smartphone-Sensordaten analysiert.  
Die App zeichnet Fahrten auf, wertet Geschwindigkeit und Beschleunigungen aus und gibt dem Nutzer über Kennzahlen,
Fehlerereignisse und Gamification-Elemente (Level, Quests) feedback zu seinem Fahrstil.

Das Projekt wurde im Rahmen einer Studienarbeit an der DHBW Karlsruhe im Studiengang Informatik umgesetzt.

---

## Inhalt

- [Ziel des Projekts](#ziel-des-projekts)
- [Funktionen](#funktionen)
- [Screenshots](#screenshots)
- [Technologien](#technologien)
- [Projektstruktur](#projektstruktur)
- [Getting Started](#getting-started)
- [Architektur & zentrale Komponenten](#architektur--zentrale-komponenten)
- [Status & Ausblick](#status--ausblick)
- [Autoren](#autoren)
- [Lizenz](#lizenz)

---

## Ziel des Projekts

Ziel von DriveWise ist es zu untersuchen, inwieweit sich das Fahrverhalten **allein mit einem Smartphone**
analysieren lässt – ohne zusätzliche Telematik-Hardware oder OBD-Adapter.

Im Fokus stehen dabei:

- Erfassung von Fahrten (Start/Ziel, Distanz, Dauer)
- Analyse von Beschleunigungs- und Bremsvorgängen sowie G-Kräften
- Ableitung eines einfachen Fahrstils („Fahrfehler“, Score)
- UX-Konzept, das **fahrsicher** ist (keine komplexe Bedienung während der Fahrt)

Die App ist ein **Prototyp** und wurde zu Forschungs- und Lernzwecken im Rahmen der Studienarbeit entwickelt.

---

## Funktionen

Aktuell implementierte Hauptfunktionen:

- 🚗 **Fahrttracking**
  - Start/Stop einer Fahrt über einen zentralen Button
  - Aufzeichnung von Distanz (km) und Fahrtdauer
  - Zählung von „Fahrfehlern“ (simuliert bzw. prototypisch)

- 📊 **Fahrtenübersicht**
  - Liste aller Fahrten, gruppiert nach Datum
  - Anzeige von Start-/Zielort, Distanz und Dauer

- 🗺️ **Fahrtdetails**
  - Kopfbereich mit Datum, Distanz und Dauer
  - Platzhalter für Kartenansicht der Route
  - Fehlerübersicht (Bremsen, Lenken, Beschleunigen)
  - Kennzahlen wie Durchschnitts- und Höchstgeschwindigkeit,
    maximale Beschleunigung (G)

- 🏆 **Gamification / Erfolge**
  - Level-System mit XP-Fortschrittsbalken
  - Quests, z. B. „Erreiche X km Gesamtstrecke“
  - Motivation zu defensivem und fehlerfreiem Fahren

- 📈 **Statistiken**
  - Übersicht über Fahrten und Fehler pro Zeitraum (Woche/Monat)
  - Kennzahlen wie Gesamtdistanz, Anzahl Fahrten, Fehleranzahl
  - Platzhalterbereiche für Diagramme

- 👤 **Profil / Konto (UI-Prototyp)**
  - Profilansicht mit Nutzername
  - Screens für E-Mail- und Passwortänderung (UI, ohne Backend-Logik)

---

## Technologien

- **Programmiersprache:** Swift
- **UI-Framework:** SwiftUI
- **Plattform:** iOS
- **IDE:** Xcode
- **Sensorik:** Core Location (GPS), perspektivisch Core Motion (Beschleunigung / Gyro)
- **Design:** Figma (UX-/UI-Prototyp, der in SwiftUI nachgebaut wurde)

---

## Projektstruktur

Die Struktur kann je nach Repository leicht abweichen. Typisch:

```text
DriveWise/
├─ DriveWise.xcodeproj        # Xcode-Projekt
├─ DriveWise/
│  ├─ ContentView.swift       # Einstieg, TabView-Navigation
│  ├─ StartseiteView.swift    # Startbildschirm (Score, Tracking, Status)
│  ├─ FahrtenListView.swift   # Liste aller Fahrten
│  ├─ FahrtDetailView.swift   # Detailansicht einer Fahrt
│  ├─ AchievementsView.swift  # Erfolge / Quests
│  ├─ StatisticsView.swift    # Statistiken
│  ├─ DriveManager.swift      # Zentrale Logik & Zustandsverwaltung
│  ├─ Models/
│  │   └─ Drive.swift         # Datenmodell für eine Fahrt
│  └─ Resources/
│      ├─ Assets.xcassets     # App-Icon, Farben, Bilder
│      └─ ...
└─ README.md                  # Dieses Dokument
````

---

## Getting Started

### Voraussetzungen

* Xcode (z. B. 15.x oder neuer)
* iOS-Simulator oder echtes iPhone mit aktueller iOS-Version
* Swift und SwiftUI werden von Xcode mitgeliefert

### Projekt lokal starten

1. Repository klonen:

   ```bash
   git clone https://github.com/<user>/<repo>.git
   cd <repo>
   ```

2. Projekt in Xcode öffnen:

   * `DriveWise.xcodeproj` (oder `.xcworkspace`, falls vorhanden) öffnen

3. Zielgerät auswählen:

   * iOS-Simulator (z. B. iPhone 15 Pro)
   * oder ein angeschlossenes physisches Gerät

4. Build & Run:

   * In Xcode auf ▶️ klicken
   * Die App startet mit der **Startseite** (Tab „DriveWise“).

> **Hinweis:** Aktuell handelt es sich um einen Prototyp.
> Einige Daten (z. B. Fahrfehler, Geschwindigkeiten) können simuliert oder vereinfacht sein.

---

## Architektur & zentrale Komponenten

### Tab-Navigation (`ContentView`)

Die globale Navigation ist über eine `TabView` gelöst:

* Tabs: `Erfolge`, `Statistiken`, `Startseite`, `Fahrten`, `Profil`
* Die `Startseite` ist der zentrale Einstiegspunkt und wird beim Start der App ausgewählt.
* Jeder Tab ist in einen `NavigationStack` eingebettet, um Detailnavigation
  (z. B. von Liste → Detail) zu ermöglichen.

Ein `DriveManager` wird als `@StateObject` in `ContentView` erzeugt
und via `.environmentObject` an alle Unter-Views weitergegeben.

### Zustandsverwaltung (`DriveManager`)

Der `DriveManager` hält u. a.:

* eine Liste von `Drive`-Objekten (Fahrten),
* aktuellen Fahrzustand (`isDriving`),
* Distanz, Dauer, Fehlerzähler während der Fahrt.

Er stellt Methoden wie `startDrive` und `stopDrive` bereit, die von der UI (z. B. `StartseiteView`) aufgerufen werden.

### Datenmodell (`Drive`)

`Drive` kapselt die Informationen einer Fahrt, u. a.:

* Start- und Endzeit
* Start- und Zielort (als Strings)
* Distanz in km
* Durchschnitts- und Höchstgeschwindigkeit
* Anzahl erkannter Fahrfehler

Das Modell wird in Fahrtenliste, Details, Statistiken und Gamification verwendet.

### Views

* **StartseiteView**

  * Zeigt den aktuellen DriveWise-Score
  * Button zum Starten/Beenden des Fahrtrackings
  * Kurzübersicht zur laufenden Fahrt (Fehler, Distanz, Dauer)
  * Statuskarte (farbliche Ampel) als Platzhalter für Live-Feedback

* **FahrtenListView**

  * Listet alle Fahrten chronologisch
  * Navigation in `FahrtDetailView` per Tap

* **FahrtDetailView**

  * Kopfkarte mit Datum, Distanz, Dauer, Startort
  * Platzhalter für Kartenansicht
  * Fehlerübersicht (Allgemein, Bremsen, Lenken, Beschleunigen)
  * Kennzahlkarten (Durchschnitts-/Höchstgeschwindigkeit, max. G-Kraft)

* **StatisticsView**

  * Aggregierte Kennzahlen pro Woche/Monat
  * Platzhalter-Bereiche für Diagramme

* **AchievementsView**

  * Level und XP-Fortschrittsbalken
  * Anzeige von Quests (z. B. bestimmte Distanzziele)

---

## Status & Ausblick

**Aktueller Stand (Prototyp):**

* UX aus Figma wurde weitgehend 1:1 in SwiftUI nachgebaut.
* Zentrale Screens (Startseite, Fahrten, Fahrtdetails, Erfolge, Statistiken) sind implementiert.
* Fahrten und Kennzahlen werden in einer vereinfachten Form verwaltet.

**Geplante / mögliche Erweiterungen:**

* echte Sensordatenerfassung über Core Motion (Beschleunigung, Gyroskop)
* robustes GPS-Tracking über Core Location inkl. Hintergrundmodus
* plausiblere Berechnungen von Fahrfehlern und Scores
* Persistente Speicherung (z. B. Core Data / lokale Datenbank)
* Anbindung an ein Backend (z. B. Firebase Authentication / Firestore)
* ausführlichere Tests (Unit-/UI-Tests, Usability-Tests)

---

## Autoren

Dieses Projekt wurde im Rahmen einer Studienarbeit an der **DHBW Karlsruhe** erstellt von:

* **Max Joch** – Entwicklung, UX, Sensorik & Analyse
* **Joscha Heid** – Entwicklung, UX, Gamification & Konzeption

Betreuer: **Prof. Dr. Roland Schätzle**

---

## Lizenz

Dieses Projekt wurde im Rahmen einer Studienarbeit erstellt und ist in erster Linie
zu Demonstrations- und Lernzwecken gedacht.
