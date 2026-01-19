#import "../setup.typ": gls
= Einleitung

Diese Studienarbeit wird im 5. und 6. Semester an der Dualen Hochschule Baden-Württemberg (#gls("DHBW")) in Karlsruhe durchgeführt und trägt den Arbeitstitel „Entwicklung einer App zur Analyse des Fahrverhaltens von PKW-Fahrern“. Ziel ist es, Fahrdaten mit dem Smartphone zu erfassen, auszuwerten und verständlich aufzubereiten. Die App kombiniert Standort- und Bewegungsdaten, erkennt auffällige Fahrmanöver (z. B. starkes Beschleunigen, abruptes Bremsen, aggressives Kurvenfahren) und gibt kontextbezogenes Feedback – sowohl während der Fahrt als auch in einer nachträglichen Zusammenfassung.

== Umfeld

Die Arbeit liegt im Bereich mobiler Sensorik und nutzerzentrierter Gestaltung. Die geplante Umsetzung erfolgt auf #gls("iOS") und nutzt etablierte System-Schnittstellen wie #gls("Core Location") (für Standortdaten über das Global Positioning System (#gls("GPS"))) und #gls("Core Motion") (für Bewegungsdaten wie #gls("G-Sensor") und #gls("Gyroskop")). Zusätzlich werden Anforderungen an Datenschutz und #gls("Datensparsamkeit") berücksichtigt, damit die Auswertung nachvollziehbar bleibt und nur notwendige Daten verarbeitet werden. Ein #gls("UX")-Konzept dient dabei als Grundlage für Navigation, Zustände (Start/Stopp, Fahrt aktiv, Auswertung) sowie Hinweise zu Fehlerfällen und Datenschutz.

== Motivation

Fahrverhalten wirkt sich unmittelbar auf Sicherheit, Komfort und Umwelt aus. Gleichzeitig erhalten viele Fahrer wenig objektives, zeitnahes Feedback. Eine rein smartphonebasierte Lösung senkt die Einstiegshürden, da keine zusätzliche Fahrzeughardware nötig ist. Die App soll verständliche, situationsnahe Hinweise liefern und so Selbstreflexion fördern (z. B. „zu starkes Bremsen/ Beschleunigen“) – mit dem Ziel ein bewussteren und sichereren Fahrstils zu fördern. Auf diese Weise können Fahrer ihre Fahrweise eigenverantwortlich verbessern, was zu mehr Sicherheit und Umweltbewusstsein beiträgt. Besonders jüngere Fahrer, die häufig Smartphones nutzen, profitieren von objektivem Feedback, da in dieser Zielgruppe oft noch Unsicherheiten und wenig Fahrerfahrung bestehen.

== Problemstellung

Bestehende Systeme sind häufig an fahrzeuginterne Hardware gebunden (z. B. #gls("OBD")), flottenorientiert und damit für Privatnutzer überdimensioniert oder liefern schwer interpretierbare Kennzahlen ohne klare Handlungsempfehlung. Gesucht ist eine leicht zugängliche App, die ohne zusätzliche Fahrzeugtechnik auskommt, während der Fahrt robust läuft, Ereignisse zuverlässig erkennt und verständliche Rückmeldungen gibt – bei maximaler Transparenz und #gls("Datensparsamkeit").


== Aufgabenstellung

Gegenstand der Arbeit ist die Konzeption, prototypische Implementierung und Evaluation einer App zur Fahrstilanalyse. Die App soll Fahrten aufzeichnen, auffällige Manöver erkennen und die Ergebnisse so darstellen, dass Nutzende sowohl während der Fahrt (dezent und optional) als auch im Nachgang konkrete Hinweise erhalten. Die prototypische Umsetzung erfolgt auf #gls("iOS").


=== Ziele

- Die App erfasst kontinuierlich und energieeffizient Standort- und Bewegungsdaten (u. a. #gls("GPS")) und speichert diese zuverlässig über eine robuste Start-/Stopp-Logik (inklusive geeignetem #gls("Logging")).

- Die App erkennt auffällige Ereignisse wie starke Beschleunigungen, Bremsungen und Kurvenfahrten mithilfe nachvollziehbarer, erklärbarer Regeln (z. B. Schwellwerte als #gls("Heuristik")), sodass Ergebnisse für Nutzende transparent bleiben.

- Die App bietet optionales Live-Feedback mit geringer Ablenkung und stellt nach der Fahrt eine verständliche Zusammenfassung bereit, in der Ereignisse markiert und relevante Kennzahlen sowie Trends dargestellt werden.

- Die Interaktionsflüsse sind konsistent umgesetzt und orientieren sich am vorhandenen #gls("Figma")-Design; erste Nutzertests liefern dokumentierte Erkenntnisse zur Gebrauchstauglichkeit.

=== Nicht-Ziele

- Eine Fahrzeugdiagnose oder eine Integration über #gls("OBD") bzw. #gls("CAN") ist nicht Bestandteil der Arbeit, um die Lösung bewusst hardwareunabhängig und niedrigschwellig zu halten.

- Ein versicherungsrelevantes #gls("Scoring") oder eine risikobewertende Analyse auf Basis von #gls("ML") ist nicht Teil des Projekts, da der Fokus auf Transparenz, Nachvollziehbarkeit und Nutzerfeedback liegt.


== Vorgehensweise

Die Arbeit gliedert sich in einen theoretischen Teil, die Konzeption und prototypische Umsetzung der App sowie eine abschließende Evaluation. Zunächst werden die relevanten Grundlagen kapitelweise erarbeitet. Darauf aufbauend werden Anforderungen abgeleitet, der Prototyp implementiert und anschließend durch Tests und erste Nutzungsrückmeldungen bewertet. Den Abschluss bildet eine Zusammenfassung mit Grenzen und Ausblick.
