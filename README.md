<<<<<<< HEAD
# AppCode



## Getting started

To make it easy for you to get started with GitLab, here's a list of recommended next steps.

Already a pro? Just edit this README.md and make it your own. Want to make it easy? [Use the template at the bottom](#editing-this-readme)!

## Add your files

- [ ] [Create](https://docs.gitlab.com/ee/user/project/repository/web_editor.html#create-a-file) or [upload](https://docs.gitlab.com/ee/user/project/repository/web_editor.html#upload-a-file) files
- [ ] [Add files using the command line](https://docs.gitlab.com/topics/git/add_files/#add-files-to-a-git-repository) or push an existing Git repository with the following command:

```
cd existing_repo
git remote add origin https://gitlab.com/studienarbeit_heid_joch/appcode.git
git branch -M main
git push -uf origin main
```

## Integrate with your tools

- [ ] [Set up project integrations](https://gitlab.com/studienarbeit_heid_joch/appcode/-/settings/integrations)

## Collaborate with your team

- [ ] [Invite team members and collaborators](https://docs.gitlab.com/ee/user/project/members/)
- [ ] [Create a new merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html)
- [ ] [Automatically close issues from merge requests](https://docs.gitlab.com/ee/user/project/issues/managing_issues.html#closing-issues-automatically)
- [ ] [Enable merge request approvals](https://docs.gitlab.com/ee/user/project/merge_requests/approvals/)
- [ ] [Set auto-merge](https://docs.gitlab.com/user/project/merge_requests/auto_merge/)

## Test and Deploy

Use the built-in continuous integration in GitLab.

- [ ] [Get started with GitLab CI/CD](https://docs.gitlab.com/ee/ci/quick_start/)
- [ ] [Analyze your code for known vulnerabilities with Static Application Security Testing (SAST)](https://docs.gitlab.com/ee/user/application_security/sast/)
- [ ] [Deploy to Kubernetes, Amazon EC2, or Amazon ECS using Auto Deploy](https://docs.gitlab.com/ee/topics/autodevops/requirements.html)
- [ ] [Use pull-based deployments for improved Kubernetes management](https://docs.gitlab.com/ee/user/clusters/agent/)
- [ ] [Set up protected environments](https://docs.gitlab.com/ee/ci/environments/protected_environments.html)

***

# Editing this README

When you're ready to make this README your own, just edit this file and use the handy template below (or feel free to structure it however you want - this is just a starting point!). Thanks to [makeareadme.com](https://www.makeareadme.com/) for this template.

## Suggestions for a good README

Every project is different, so consider which of these sections apply to yours. The sections used in the template are suggestions for most open source projects. Also keep in mind that while a README can be too long and detailed, too long is better than too short. If you think your README is too long, consider utilizing another form of documentation rather than cutting out information.

## Name
Choose a self-explaining name for your project.

## Description
Let people know what your project can do specifically. Provide context and add a link to any reference visitors might be unfamiliar with. A list of Features or a Background subsection can also be added here. If there are alternatives to your project, this is a good place to list differentiating factors.

## Badges
On some READMEs, you may see small images that convey metadata, such as whether or not all the tests are passing for the project. You can use Shields to add some to your README. Many services also have instructions for adding a badge.

## Visuals
Depending on what you are making, it can be a good idea to include screenshots or even a video (you'll frequently see GIFs rather than actual videos). Tools like ttygif can help, but check out Asciinema for a more sophisticated method.

## Installation
Within a particular ecosystem, there may be a common way of installing things, such as using Yarn, NuGet, or Homebrew. However, consider the possibility that whoever is reading your README is a novice and would like more guidance. Listing specific steps helps remove ambiguity and gets people to using your project as quickly as possible. If it only runs in a specific context like a particular programming language version or operating system or has dependencies that have to be installed manually, also add a Requirements subsection.

## Usage
Use examples liberally, and show the expected output if you can. It's helpful to have inline the smallest example of usage that you can demonstrate, while providing links to more sophisticated examples if they are too long to reasonably include in the README.

## Support
Tell people where they can go to for help. It can be any combination of an issue tracker, a chat room, an email address, etc.

## Roadmap
If you have ideas for releases in the future, it is a good idea to list them in the README.

## Contributing
State if you are open to contributions and what your requirements are for accepting them.

For people who want to make changes to your project, it's helpful to have some documentation on how to get started. Perhaps there is a script that they should run or some environment variables that they need to set. Make these steps explicit. These instructions could also be useful to your future self.

You can also document commands to lint the code or run tests. These steps help to ensure high code quality and reduce the likelihood that the changes inadvertently break something. Having instructions for running tests is especially helpful if it requires external setup, such as starting a Selenium server for testing in a browser.

## Authors and acknowledgment
Show your appreciation to those who have contributed to the project.

## License
For open source projects, say how it is licensed.

## Project status
If you have run out of energy or time for your project, put a note at the top of the README saying that development has slowed down or stopped completely. Someone may choose to fork your project or volunteer to step in as a maintainer or owner, allowing your project to keep going. You can also make an explicit request for maintainers.
=======
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
>>>>>>> f43926b4f236178e81de6fade8c0f3d9fe95c16c
