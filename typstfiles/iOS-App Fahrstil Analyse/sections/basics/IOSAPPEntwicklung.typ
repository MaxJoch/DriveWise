#import "../setup.typ": gls
= #gls("iOS") App Entwicklung

== #gls("iOS") App Entwicklung mit #gls("Swift")

Die prototypische Umsetzung der Fahrstilanalyse-App erfolgt auf Basis des Betriebssystems #gls("iOS") und der Programmiersprache #gls("Swift"). #gls("Swift") wurde von Apple im Jahr 2014 eingeführt und hat sich als Standard für die Entwicklung nativer Anwendungen auf #gls("iOS"), #gls("iPadOS"), #gls("macOS") und #gls("watchOS") etabliert (@swiftBook2014). Die Sprache bietet eine moderne Syntax, hohe Typsicherheit und gute Performance und wurde mit dem Ziel entwickelt, sichere und effiziente Programmierung zu unterstützen (@swiftLang2023).

#gls("Swift") kombiniert Eigenschaften kompilierter Sprachen mit gut lesbarer Syntax und unterstützt objektorientierte, funktionale und protokollbasierte Paradigmen. Mechanismen wie striktere Typprüfung und optionale Typen reduzieren typische Fehler (z. B. Nullzeiger-Probleme) und erhöhen Stabilität und Sicherheit der Anwendung (@swiftLang2023).

Die Entwicklung erfolgt in der integrierten Entwicklungsumgebung (Integrated Development Environment, #gls("IDE")) #gls("Xcode"), die Werkzeuge für Code-Erstellung, Debugging und Performance-Analyse bereitstellt. Zusätzlich können Benutzeroberflächen gestaltet und mit Logik verknüpft werden, was eine konsistente Umsetzung des im #gls("Figma")-Prototypen definierten Designs unterstützt (@xcodeApple2024).

== Zugriff auf Sensorik unter iOS

Für die Datenerfassung nutzt die App primär die Frameworks #gls("Core Location") und #gls("Core Motion") (@appleCoreLocation; @appleCoreMotion). Standortdaten werden über #gls("Core Location") bereitgestellt, typischerweise über Klassen wie `CLLocationManager` und `CLLocation` (@appleCoreLocation; @appleCLLocation). Einstellungen wie `desiredAccuracy` und `distanceFilter` steuern Genauigkeit und Aktualisierungsverhalten und beeinflussen damit auch den Energieverbrauch (@appleCLLocation). Für Fahrten, die im Hintergrund weiterlaufen, kann die Standortaktualisierung über `allowsBackgroundLocationUpdates` fortgesetzt werden, sofern die App entsprechend konfiguriert ist (@appleCoreLocation).

Bewegungsdaten werden über #gls("Core Motion") erfasst, z. B. über `CMMotionManager` oder `CMDeviceMotion` (@appleCoreMotion). Durch systemnahe Verarbeitung und (je nach Quelle) Sensorfusion stehen häufig stabilere Signale zur Verfügung, die für eine robuste Ereigniserkennung hilfreich sind (@allan2011, S. 37 ff.). Insgesamt ermöglichen die nativen Frameworks eine ressourcenschonende Erfassung, die für eine kontinuierliche Fahrtdatenerhebung erforderlich ist.

== Lokale Speicherung und Datenformat

Die erfassten Daten werden lokal auf dem Gerät gespeichert, um Offline-Funktionalität zu gewährleisten und Anforderungen an Datenschutz sowie #gls("Datensparsamkeit") zu unterstützen. Für Dateizugriffe innerhalb des App-Containers stellt #gls("iOS") z. B. `FileManager` bereit (@appleFileManager). Die Speicherung kann in einem strukturierten Textformat wie JavaScript Object Notation (#gls("JSON")) erfolgen, da es eine kompakte Serialisierung und eine einfache Weiterverarbeitung ermöglicht (@nurseitov2009, S. 160). Nach Abschluss einer Fahrt können Daten gebündelt und asynchron an eine Server- oder Webanwendung übertragen werden, um Energieverbrauch und Datenverlust zu reduzieren (@bangash2021, S. 3 f.).

== Benutzeroberfläche mit #gls("SwiftUI")

Für die Benutzeroberfläche kann #gls("SwiftUI") genutzt werden, ein deklaratives Framework, das die Umsetzung responsiver und interaktiver Layouts unterstützt (@swiftuiApple2024). Durch wiederverwendbare Komponenten lassen sich konsistente Ansichten erstellen und das #gls("UX")-Konzept effizient umsetzen.

== Verwendung von #gls("Firebase") Authentication für Kontofunktionen

Für Kontofunktionen wird #gls("Firebase") Authentication eingesetzt. #gls("Firebase") ist eine Entwicklungsplattform von Google, die verschiedene Dienste bereitstellt, um Anwendungen zu erstellen und zu betreiben (@firebaseDocs). #gls("Firebase") Authentication unterstützt die schnelle Integration eines Benutzerverwaltungssystems mit vorgefertigten Authentifizierungsverfahren, z. B. E-Mail/Passwort, Telefonnummer sowie Anmeldungen über Google-Konto oder Apple-ID (@firebaseAuth2025; @firebaseSignIn2025).

Für den Prototyp ist die kostenlose Stufe geeignet, da sie bis zu 50.000 monatliche aktive Nutzer ohne zusätzliche Kosten abdeckt; Einschränkungen bestehen dabei insbesondere bei SMS-basierter Authentifizierung (@firebasePricing2025). Da im Rahmen der Studienarbeit keine große Nutzerbasis erwartet wird, ist dieser Umfang ausreichend. Dadurch kann ein realistisches Kontosystem umgesetzt werden, ohne eigene Backend-Infrastruktur entwickeln und betreiben zu müssen.
