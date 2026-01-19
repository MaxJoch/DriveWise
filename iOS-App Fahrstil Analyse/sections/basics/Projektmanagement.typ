#import "../setup.typ": gls

= Projektmanagement

== Projektorganisation

Die Studienarbeit wird im Rahmen des 5. und 6. Semesters im Studiengang Informatik an der #gls("DHBW") Karlsruhe durchgeführt. 
Der Bearbeitungszeitraum ist in zwei Präsenzphasen gegliedert: vom 29.09.2025 bis 21.12.2025 sowie vom 16.02.2026 bis 17.05.2026. 
Die Arbeit wird von Prof. Dr. Roland Schätzle betreut. 

Das Projektteam besteht aus zwei Studierenden: Max Joch und Joscha Heid. Beide übernehmen sowohl Entwicklungs- als auch Designaufgaben und sind darüber hinaus in die Projektplanung eingebunden. 
Joscha Heid fungiert zusätzlich als Projektleiter und koordiniert Termine, Aufgabenverteilung und Kommunikation mit dem Betreuer. 
Die Betreuung durch Prof. Schätzle erfolgt insbesondere über regelmäßige Statusgespräche und Feedback zu Zwischenergebnissen.

Die Zusammenarbeit findet überwiegend in selbstorganisierten Arbeitssitzungen statt, die je nach Verfügbarkeit in Räumen der #gls("DHBW") oder remote durchgeführt werden. 
Da Quellcode und Dokumentation vollständig digital vorliegen, ist eine ortsunabhängige Kollaboration problemlos möglich. 

Zur Entwicklung wird die integrierte Entwicklungsumgebung (#gls("IDE")) #gls("Xcode") eingesetzt. 
Die App wird nativ in #gls("Swift") bzw. #gls("SwiftUI") für #gls("iOS") umgesetzt. 
Für die Auswertung und Speicherung der Fahrdaten kommen die System-#gls("API")s #gls("Core Motion") und #gls("Core Location") sowie eine lokale Datenhaltung (z. B. im #gls("JSON")-Format) zum Einsatz. 
Die Studienarbeit selbst wird mit Typst erstellt, wodurch eine klare Trennung zwischen Inhalt und Layout sowie eine konsistente Zitations- und Abbildungsverwaltung ermöglicht wird.

Als zentrale Plattform für Versionsverwaltung und Zusammenarbeit dient ein privates GitLab-Repository. 
Dort werden Quellcode, Projektdokumente und Issues gemeinsam verwaltet. 
Die Nutzung von Git ermöglicht eine lückenlose Nachverfolgbarkeit von Änderungen, die parallele Bearbeitung durch beide Teammitglieder sowie eine strukturierte Organisation von Aufgaben (z. B. über Branches, Merge Requests und Issue-Boards).

Das Vorgehen im Projekt ist iterativ und an klassische Softwareentwicklungsprozesse angelehnt. 
Zunächst werden Anforderungen erhoben und konsolidiert (Anforderungsanalyse). 
Darauf aufbauend erfolgt eine technische Konzeption, in der Frameworks, Datenmodell, Speicherkonzept und grundlegende #gls("UX")-Strukturen festgelegt werden. 
Anschließend werden die einzelnen Views auf #gls("UX") Ebene umgesetzt, bevor die Datenerfassung (#gls("GPS")-Tracking, Sensorintegration) mit den Analysealgorithmen implementiert und Feedbackmechanismen (Karten, Kennzahlen, Gamification) ausgearbeitet werden. 
Die Implementierung wird durch Testfahrten, Validierungsschritte und Usability-Tests begleitet und abschließend durch eine schriftliche Dokumentation mit Reflexion und Ausblick ergänzt.

Im Rahmen der Projektorganisation wurde zudem ein einfaches Risikomanagement etabliert. 
Zentrale Risiken – etwa eine eingeschränkte technische Umsetzbarkeit bestimmter Funktionen, zeitliche Verzögerungen, unzureichende Datenqualität, Krankheit von Teammitgliedern oder Änderungen in #gls("iOS")-Frameworks – wurden identifiziert und hinsichtlich Eintrittswahrscheinlichkeit und Projekteinfluss bewertet. 
Daraus wurde ein Risiko-Faktor (Wahrscheinlichkeit × Einfluss) abgeleitet und für jedes Risiko konkrete Minderungsmaßnahmen definiert (z. B. frühe Machbarkeitsanalysen, Zeitpuffer, frühzeitige Testfahrten, Dokumentation der Aufgabenverteilung). 
Dieses strukturierte Vorgehen unterstützt die Planungssicherheit und erleichtert den Umgang mit unerwarteten Projektverläufen.


== Anforderungsanalyse

Die Anforderungsanalyse ist ein Schritt der Software-Entwicklung und umfasst grundlegend die Erfassung und Dokumentation der Anforderungen, die an ein Software-System gestellt werden. Durch eine solche Dokumentation wird sichergestellt, dass alle am Projekt Beteiligten auf dem selben Stand sind, was das erwartete Ergebnis betrifft (@sommerville2016 S.102). Hierbei werden sowohl funktionale Anforderungen, als auch nicht funktionale Anforderungen (sogenannte Quality-Requirements) aufgenommen und festgehalten. Diese nicht-funktionalen Anforderungen gehen über funktionale Features hinaus und beschreiben oft Aspekte, wie Performance oder Verfügbarkeit etc. (@pohl2015 S.8). Weiterführend können auch Nicht-Ziele definiert werden, die genauer abstecken, welche Features nicht Teil der Entwicklung sein werden.

All diese festgehaltenen Punkte dienen dazu, spätere Missverständnisse zu verhindern und das Risiko für zeitkritische oder kostspielige Änderungswünsche zu minimieren. Die Wahrscheinlichkeit wird deutlich erhöht, dass das Endprodukt den Vorstellungen aller zu Projektbeginn Beteiligten Personen entspricht (@ieee29148_2018 S.12-13).

Das Lastenheft spielt bei diesem Prozess eine zentrale Rolle. Es beschreibt die Anforderungen und Vorstellungen aus Sicht des Auftraggebers. Hierbei ist wichtig, dass noch keine technische Beschreibung der Lösung aufgenommen wird. Diese Ausarbeitung wird erst später im Pflichtenheft erforderlich.

=== Vorgehensweise der Anforderungsanalyse im Projekt DriveWise

Da im Projekt DriveWise die Projektmitglieder gleichzeitig auch die Stakeholder sind, handelt es sich um selbstaufgelegte Anforderungen. Diese Anforderungen wurden gemeinsam festgelegt und anschließend in einem Lastenheft festgehalten. Hierbei wurden sowohl funktionale, als auch nicht funktionale Anforderungen erarbeitet.

Hierbei wurde damit begonnen die Hauptanforderungen an das Projekt in einem Satz gebündelt zu formulieren, um auf den ersten Blick einen guten Überblick zu haben. Anschließend wurden der Anwendungsbereich und die Zielgruppe definiert (Privatpersonen mit #gls("iOS")-Gerät, die ihr Fahrverhalten verbessern wollen). Danach wurden die funktionalen Anforderungen definiert, darunter:

1. Nutzerregistrierung und Login:

Um individuelle Fahrdaten sicher speichern zu können, soll ein Login-System bereitgestellt werden, über das sich Nutzer mit einer Email Adresse und einem Passwort anmelden können. Nach erfolgreicher Anmeldung werden Daten Accountbasiert gespeichert, sodass eine individuelle Analyse, sowie Geräteübergreifendes Verwenden der App möglich ist. Für den Fall, dass ein Nutzer seine Daten vergisst, soll es eine einfache Möglichkeit geben, sein Passwort zurückzusetzen. Der gesamte Prozess sollte auch für technisch unerfahrene Nutzer einfach verständlich sein.

2. Erfassung von Fahr- und Sensordaten:

Die App soll iPhone-interne Sensoren verwenden, um Bewegungs- und Positionsdaten zu ermitteln. Diese Daten sollen gespeichert und als Grundlage für die Bewertung des Fahrstils verwendet werden. Die Analyse umfasst die Durchschnittsgeschwindigkeit und Fahrzeit, die Erkennung von starkem Beschleunigen, abruptem Bremsen und riskantem Kurvenverhalten, sowie G-Kraft-Spitzen und einer Segmentierung der Strecke in Abschnitte. Durch diese Daten soll dem Nutzer sichtbar gemacht werden, wie er seinen Fahrstil verbessern kann, da er anschaulich sieht, wo seine Problemzohnen im Bereich des Straßenverkehrs liegen.

3. Echtzeit-Feedback während der Fahrt:

Während der Fahrt soll das Fahrverhalten in Echtzeit analysiert werden, sodass der Nutzer noch während der Fahrt vor gefährlichem Fahrverhalten gewarnt werden kann. Diese Warnung soll entweder visuell oder akustisch erfolgen, jedoch dezent und sicher, sodass der Fahrer nicht während der Fahrt abgelenkt wird. Mögliche Warnfälle umfassen zu starkes Beschleunigen, abruptes Bremsen oder auch übermäßige Kurvenbeschleunigung.

4. Auswertung einer Route nach der Fahrt inklusive Kartenansicht:

Nach jeder Fahrt soll der Nutzer eine detaillierte Auswertung über seine Fahrt erhalten. Hierbei soll es eine Kartenansicht geben, auf der auffällige Bereiche der Route farblich hervorgehoben werden. Zusätzlich soll der Nutzer statistische Kennzahlen erhalten, anhand derer ein Score für die einzelne Fahrt errechnet wird.

5. Generierung von Wochen- und/oder Monatsberichten:

Um die langfristige Entwicklung eines Nutzers zu erkennen soll die App automatisch wöchentliche oder monatliche Reports erstellen. Diese sollen als Zusammenfassung dienen, um dem Nutzer sein Fahrverhalten und mögliche Änderungen dessen anschaulich zu machen. Hierbei können die Änderungen positiv oder auch negativ sein.

6. Gamification-Elemente zur spielerischen Motivationssteigerung:

Um dem Nutzer eine spielerische Motivation zu geben, die App weiter zu verwenden und seinen Fahrstil zu verbessern, soll die App auf Gamification Elemente setzen. Hierzu zählen beispielsweise Fortschrittsbalken und Challenges, aber auch Belohnungen für ein gutes Fahrverhalten.

Darüber hinaus wurden nicht-funktionale Anforderungen an Usability und Design formuliert, die alle Altersklassen abdecken sollen.

1. Benutzerfreundlichkeit

Die App soll ein modernes, aber klares Desing aufweisen mit einer intuitiven Navigation. Statistiken sollen klar veranschaulicht sein, statt lange Zahlenreihen zu verwenden. Hierdurch sollen Nutzer aller Altersklassen angesprochen werden, unabhängig von technischem Vorwissen.

Zu guter Letzt wurden Nicht-Ziele definiert, die explizit nicht Teil des Projekts sind. Diese enthalten folgende Punkte. Die App soll keine Verbindung zu #gls("OBD")-Systemen oder anderen fahrzeuginternen Sensoren herstellen. Ebenfalls soll sie nicht dazu dienen, eine technische Fahrzeugdiagnose zu erhalten, da die App lediglich für den Fahrstil und nicht das Fahrzeug selbst gedacht ist. Auch soll es keine Integration mit anderen externen Geräten oder Fahrzeugsteuerungen geben.


== Projektplan
in arbeit (TODO)


== Qualitätssicherungsmaßnahmen

Um die Qualität der entwickelten App sowie der Studienarbeit sicherzustellen, wurden sowohl allgemeine als auch phasen- und bereichsspezifische Qualitätssicherungsmaßnahmen definiert. 
Ziel ist es, funktionale Korrektheit, Stabilität, Benutzerfreundlichkeit, Sicherheit und Nachvollziehbarkeit der Ergebnisse systematisch abzusichern. 

=== Allgemeine QS-Maßnahmen

Zu den übergreifenden Maßnahmen gehören regelmäßige Code-Reviews, bei denen Quellcode hinsichtlich Lesbarkeit, Struktur und Funktionalität überprüft wird. 
Die Nutzung von GitLab als Versionsverwaltungssystem stellt sicher, dass Änderungen versioniert, nachvollziehbar dokumentiert und bei Bedarf wiederhergestellt werden können. 

Für alle wesentlichen Tests (Funktions-, Performance- und später Usability-Tests) werden Testprotokolle geführt, in denen Vorgehen, Testdaten, Ergebnisse und ggf. identifizierte Fehler festgehalten werden. 
Zusätzlich sind Feedbackrunden mit Kommiliton:innen sowie dem Betreuer vorgesehen, insbesondere in der Abschlussphase, um externe Perspektiven auf #gls("UX"), Verständlichkeit und Funktionalität zu integrieren. 

Die Projektarbeit wird durch wöchentliche Team-Meetings begleitet, in denen Fortschritte, offene Punkte und Risiken besprochen werden. 
Monatliche Treffen mit dem Betreuer dienen der Abstimmung zentraler Entscheidungen und der Überprüfung des Projektstands. 
Als Qualitätskriterien werden u. a. die Erfüllung der Anforderungen, die Stabilität der App, die Nachvollziehbarkeit der Analyseergebnisse sowie die formale Korrektheit der Studienarbeit (z. B. Zitation, Quellenverzeichnis) festgelegt.

=== Spezifische QS-Maßnahmen nach Bereichen und Meilensteinen

Die Qualitätssicherung wird zusätzlich entlang definierter Meilensteine und Themenfelder konkretisiert.

*Projekt & Zusammenarbeit (M1–M3).*  
Zu Projektbeginn wird sichergestellt, dass alle Teammitglieder Zugriff auf das GitLab-Repository haben und grundlegende Git-Kenntnisse vorhanden sind. 
Es wird geprüft, ob das gemeinsame Arbeiten über Branches und Merge Requests funktioniert und eine aktuelle README mit Setup-Anleitung (z. B. #gls("Xcode")-Version, benötigte Abhängigkeiten) vorliegt. 
Außerdem wird der Build-Prozess auf den Entwicklungsgeräten getestet, um eine konsistente Entwicklungsumgebung sicherzustellen.

*#gls("UI") & Design (M4–M5).*  
In dieser Phase wird die Konformität der implementierten Oberfläche mit den #gls("Figma")-Mockups überprüft. 
Dabei werden Farben, Icons, Layout, Abstände und die Funktionsweise von Navigation Bar und Tab Bar mit dem Prototyp abgeglichen. 
Zudem wird getestet, ob das Layout auf unterschiedlichen Gerätegrößen (z. B. iPhone SE bis iPhone 15 Pro Max) korrekt skaliert und ob Animationen sowie Übergänge flüssig sind. 
Falls ein Dark-Mode-Design vorgesehen ist, wird dessen Vollständigkeit ebenfalls geprüft.

*Funktionalität & Logik (M4–M5).*  
Für die fachliche Logik werden spezifische Tests definiert: 
Es wird kontrolliert, ob Fahrten korrekt gestartet, pausiert und beendet werden, ob #gls("GPS")-Daten zuverlässig – auch im Hintergrundbetrieb – aufgezeichnet werden und ob die Logik zur Erkennung von Beschleunigungs-, Brems- und Lenkereignissen valide und reproduzierbar ist. 
Ebenso werden Gamification-Funktionen (Punktesystem, Badges, Level) sowie Authentifizierungs- und Datenhaltungsmechanismen getestet. 

*Benutzererlebnis & Stabilität (M5–M6).*  
In dieser Phase stehen realitätsnahe Tests im Vordergrund. 
Die App wird auf verschiedenen #gls("iOS")-Geräten gestartet und auf Absturzfreiheit überprüft. 
Testfahrten unter realen Bedingungen (Stadt, Landstraße, Autobahn) dienen dazu, das Verhalten der App während längerer Nutzung zu bewerten und potenzielle Probleme hinsichtlich Speicherverbrauch, Energieeffizienz und Robustheit aufzudecken. 
Zusätzlich wird auf Zugänglichkeit und Lesbarkeit geachtet (Kontraste, Schriftgrößen, Touch-Ziele), um die App auch für unterschiedliche Nutzergruppen gut nutzbar zu machen. 

\todo muss noch geschaut werden ob wir das machen wollen

*Sicherheit & Datenschutz (M5–M6).*  
Da #gls("GPS")- und Fahrdaten personenbezogene Informationen enthalten können, werden spezielle Maßnahmen zur Sicherstellung von Sicherheit und Datenschutz vorgesehen. 
Dazu gehören die Überprüfung von Zugriffsregeln (z. B. dass nur eingeloggte Nutzer auf ihre eigenen Daten zugreifen können), die Vermeidung unverschlüsselter Speicherung sensibler Daten und die Bereitstellung einer verständlichen Datenschutzerklärung mit Einwilligungsabfrage beim ersten Start. 
Zudem werden Prozesse für den Export bzw. die Löschung persönlicher Daten im Sinne der DSGVO dokumentiert und getestet. 

Durch die Kombination aus organisatorischen Regelungen, klar definierten Meilensteinen und detaillierten Qualitätssicherungsmaßnahmen wird gewährleistet, dass die entwickelte App sowohl den fachlichen Anforderungen als auch den wissenschaftlichen und formalen Anforderungen der Studienarbeit gerecht wird.