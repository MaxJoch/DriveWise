#import "../setup.typ": gls

= Benchmarking bestehender Lösungen zur Fahrverhaltensanalyse

Das Benchmarking bestehender Lösungen dient dazu, die im Rahmen dieser Studienarbeit entwickelte Fahrstilanalyse-App im Markt- und Technologiekontext zu verorten. Untersucht werden insbesondere Anwendungen, die Fahrten aufzeichnen und Fahrverhalten bewerten. Dabei lassen sich zwei grundlegende Ansätze unterscheiden: telematikbasierte Systeme mit externer Hardware (insbesondere Versicherungsprodukte) und rein smartphonebasierte Tracking-Apps.

== Telematik im automobilen Kontext

Der Begriff *Telematik* bezeichnet die Verbindung von Telekommunikation und Informatik zur Erfassung, Übertragung und Auswertung von Daten über räumlich verteilte Objekte (@geotabTelematics; @naicTelematics2023). Im Fahrzeugbereich kommen typischerweise #gls("GPS")-Empfänger, Beschleunigungssensoren und eine Kommunikationsschnittstelle (z. B. Mobilfunk) zum Einsatz, um Positions-, Bewegungs- und Zustandsdaten kontinuierlich zu erfassen und an Backend-Systeme zu übertragen (@geotabTelematics).

In der Kfz-Versicherung wird Telematik im Rahmen von *Usage-Based Insurance* (#gls("UBI")) eingesetzt. Fahrdaten wie gefahrene Kilometer, Tageszeit, Position, starkes Beschleunigen, hartes Bremsen oder Kurvenfahrten werden über fest installierte Geräte oder Smartphone-Apps aufgezeichnet und in Echtzeit an den Versicherer bzw. dessen Dienstleister übermittelt (@naicUBI2017; @naicTelematics2023). Auf Basis dieser Verhaltensdaten werden Risikoprofile erstellt und Prämien stärker am individuellen Fahrstil ausgerichtet (@naicCIPR2015). Studien zeigen, dass Telematikdaten nicht nur zur Risikobewertung, sondern auch zur Verbesserung von Sicherheit und Umweltverträglichkeit im Straßenverkehr genutzt werden können, etwa durch Feedback und Coaching-Ansätze (@ghaffarpasand2022; @cevolini2025).

== Telematik-basierte Systeme mit externer Hardware (Versicherungstarife)

Ein typisches Beispiel für telematikbasierte Fahrstilanalyse ist der Tarif *Telematik Plus* der HUK24. Das System besteht aus einem Telematik-Sensor, der innen an der Frontscheibe angebracht wird, und der Smartphone-App „HUK Mein Auto" (@huk24TelematikPlus). Der Sensor erfasst während der Fahrt Daten zu Geschwindigkeit, Beschleunigung sowie Brems- und Lenkverhalten und übermittelt diese über die App an einen Dienstleister (HDD GmbH), der daraus Fahrwerte berechnet (@huk24TelematikPlus). Aus den aggregierten Fahrwerten wird ein Gesamtfahrwert zwischen 0 und 100 Punkten abgeleitet, der als Grundlage für einen Bonus von bis zu 30 % auf den Kfz-Beitrag dient (@huk24TelematikPlus).

Telematik-Plus-Systeme verfolgen damit primär zwei Ziele:

- *Risikoadäquate Tarifierung:* Fahrverhalten wird detailliert erfasst und in risikobasierte Prämien übersetzt (Pay-how-you-drive / Pay-as-you-drive) (@naicCIPR2015; @naicTelematics2023).
- *Verhaltensbeeinflussung durch Feedback:* Fahrerinnen und Fahrer erhalten über die App Rückmeldungen zu ihrem Fahrstil und werden zu defensivem, sicherem und zunehmend auch umweltbewusstem Fahren motiviert (@huk24TelematikPlus; @cevolini2025).

Nachteilig ist aus Anwendersicht, dass zusätzliche Hardware im Fahrzeug installiert werden muss und die Auswertung stark an den Versicherungszweck gebunden ist. Die individuelle Transparenz über die Rohdaten bleibt begrenzt, da dem Versicherer meist nur aggregierte Fahrwerte und nicht die vollständigen Fahrdaten zur Verfügung stehen (@huk24TelematikPlus; @naicCIPR2015).

== Smartphone-basierte Fahrten-Tracker ohne explizite Fahrstilanalyse

Neben versicherungsgetriebenen Telematiklösungen existiert eine Vielzahl von Apps, die Fahrten primär zu Dokumentations- oder Navigationszwecken aufzeichnen. Diese Anwendungen nutzen ausschließlich die Sensorik des Smartphones (#gls("GPS"), Beschleunigungssensoren), liefern aber in der Regel *keine* explizite Fahrstilanalyse oder Fahrerbewertung.

Ein Beispiel ist die App *Geo Tracker – GPS Tracker*. Sie zeichnet Routen #gls("GPS")-basiert auf, arbeitet auch offline und stellt detaillierte Statistiken wie Streckenlänge, Aufzeichnungsdauer, maximale und durchschnittliche Geschwindigkeit, Höhenunterschiede und Steigung bereit (@geoTracker; @geoTrackerStore). Der Fokus liegt auf der präzisen Aufzeichnung von Bewegungsdaten und der Anzeige von Geschwindigkeits- und Höhenprofilen, etwa für Outdoor-Aktivitäten wie Wandern oder Radfahren, nicht auf der sicherheitsorientierten Bewertung des Fahrstils.

Die App *Driversnote* adressiert vor allem das Führen eines digitalen Fahrtenbuchs. Fahrten können automatisch oder manuell über das #gls("GPS") des Smartphones getrackt und anschließend steuerkonform dokumentiert werden (@driversnoteTracking). Im Vordergrund stehen Funktionen wie automatische Fahrtenerkennung, nachträgliche Erfassung von Fahrten und die Erstellung detaillierter Fahrtenbücher für Erstattungen und steuerliche Abzüge, nicht jedoch die Analyse von Beschleunigungs- oder Bremsmustern zur Einstufung des Fahrverhaltens (@driversnoteTracking).

Eine weitere Kategorie stellen Apps dar, die Geschwindigkeit und G-Kräfte visualisieren. Die Android-App *Speedometer with G-FORCE meter* kombiniert beispielsweise einen #gls("GPS")-Tachometer mit einem G-Kraftmessgerät und nutzt den Beschleunigungssensor des Smartphones, um Geschwindigkeit sowie Beschleunigungs- und Querkräfte in Echtzeit darzustellen (@speedometerGforce). Ziel ist die Visualisierung von Geschwindigkeit und G-Kräften für unterschiedliche Fahr- und Bewegungs­kontexte (z. B. Auto, Motorrad, Boot), nicht jedoch eine umfassende, regelbasierte Bewertung des Fahrverhaltens im Sinne von „sicher" oder „risikoreich" (@speedometerGforce).

Diese Beispiele zeigen, dass viele bestehende smartphonebasierte Lösungen zwar Fahrten und relevante physikalische Größen wie Geschwindigkeit, Beschleunigung und G-Kräfte erfassen, aber überwiegend auf die Darstellung von Rohdaten und einfachen Statistiken fokussiert sind. Eine systematische Fahrstilanalyse mit qualitativer Bewertung (z. B. Fahrscores, Kategorien wie „defensiv", „moderat", „aggressiv") ist in diesen Anwendungen typischerweise nicht vorgesehen (@geoTracker; @driversnoteTracking; @speedometerGforce).

== Einordnung der eigenen Lösung

Im Vergleich zu den betrachteten Systemen positioniert sich die in dieser Studienarbeit entwickelte App wie folgt:

- *Sensorik und Infrastruktur:*  
  Die App nutzt ausschließlich die im Smartphone integrierten Sensoren (#gls("GPS"), Beschleunigungs- und ggf. Gyroskopsensoren) und kommt ohne zusätzliche Telematik-Hardware oder #gls("OBD")-Schnittstelle aus. Damit folgt sie technisch den smartphonebasierten Tracking-Ansätzen (@geoTracker; @driversnoteTracking), vermeidet aber die Notwendigkeit externer Sensoren, wie sie bei klassischen Versicherungs-Telematiktarifen zum Einsatz kommen (@huk24TelematikPlus).

- *Funktionsumfang:*  
  Ähnlich zu bestehenden Tracking-Apps werden Fahrten mit Parametern wie Strecke, Dauer, Geschwindigkeitsprofil und G-Kräften erfasst (@geoTracker; @speedometerGforce). Darüber hinaus zielt die App explizit auf die Auswertung von Fahrverhalten (z. B. starkes Beschleunigen, abruptes Bremsen, hohe Querbeschleunigung) und die Ableitung eines Fahrstils ab. Damit nähert sie sich funktional den telematikbasierten Versicherungslösungen an, bleibt aber technisch auf die Smartphone-Sensorik beschränkt.

- *Zweck und Nutzerfokus:*  
  Während Telematik-Tarife wie *Telematik Plus* vorrangig auf risikobasierte Prämiengestaltung und Bonus-Modelle ausgerichtet sind (@naicUBI2017; @huk24TelematikPlus; @cevolini2025), verfolgt die hier entworfene App einen nutzerzentrierten Ansatz: Der Schwerpunkt liegt auf Transparenz, Selbstreflexion und einer eigenverantwortlichen Verbesserung des Fahrstils. Die Fahrdaten verbleiben zunächst lokal auf dem Gerät und werden primär zur individuellen Analyse und Visualisierung genutzt.

- *Potenzial im Kontext Sicherheit und Nachhaltigkeit:*  
  Die Literatur zu Fahrzeugtelematik weist darauf hin, dass telematikbasierte Systeme einen Beitrag zu mehr Verkehrssicherheit und geringeren Emissionen leisten können, insbesondere wenn Fahrende kontinuierliches Feedback zu ihrem Fahrverhalten erhalten (@ghaffarpasand2022; @cevolini2025). Die entwickelte App knüpft an diese Erkenntnisse an, indem sie auf Basis der Smartphone-Daten Hinweise zu sicherem und effizientem Fahren geben soll, ohne den Umweg über Versicherungsprodukte oder zusätzliche Hardware zu gehen.

Insgesamt zeigt das Benchmarking, dass es bereits etablierte Lösungen zur Fahrtenaufzeichnung und telematikbasierte Versicherungstarife mit umfassender Fahrstilanalyse gibt. Eine Lücke besteht jedoch bei Anwendungen, die *allein mit Smartphone-Sensorik* sowohl Fahrten aufzeichnen als auch eine *qualitative Fahrstilanalyse* durchführen und dabei *konsequent nutzerzentriert* (statt versicherungszentriert) ausgestaltet sind. Genau in diesem Spannungsfeld positioniert sich die in dieser Studienarbeit entwickelte Fahrstilanalyse-App.

= Entwicklung
== Prototyping mit #gls("Figma") <sec-prototypingFigma>

Vor der Implementierung der Fahrstilanalyse-App wurde ein vollständiger #gls("UX")-Prototyp in #gls("Figma") erstellt. Prototyping ermöglicht es, Aufbau, Navigation und Interaktionsabläufe einer Anwendung bereits in einer frühen Phase zu planen und zu evaluieren, ohne dafür Entwicklungsressourcen in Form von Code zu binden (@figmaSpringer2024; @figmaAmbient). Durch klickbare Prototypen können typische Nutzungsszenarien – etwa Login, Start und Stopp einer Fahrt, Einsicht in Fahrtdetails oder das Anzeigen von Auswertungen und Gamification-Elementen – realitätsnah durchgespielt und iterativ verbessert werden. Auf diese Weise lassen sich Inkonsistenzen im Layout, fehlende Funktionen oder umständliche Nutzerwege frühzeitig erkennen und beheben, was Entwicklungsaufwand in späteren Phasen reduziert (@figmaSpringer2024).

Bei der Konzeption des Prototyps wurde darauf geachtet, dass alle zuvor definierten fachlichen Mindestanforderungen der App im #gls("UX")-Design berücksichtigt sind. Dazu zählen insbesondere das Tracken von Fahrten, die Anzeige einer Fahrtenhistorie, detaillierte Fahrtauswertungen mit Kennzahlen und Fahrfehlern, Live-Feedback zur aktuellen Fahrt sowie grundlegende Konto- und Profileinstellungen. Diese Anforderungen wurden in #gls("Figma") modelliert, sodass überprüft werden konnte, ob alle notwendigen Informationen und Aktionen über die Oberfläche erreichbar sind, ohne den Nutzer zu überfordern.

Ein zentraler Aspekt des Prototypings war die Gestaltung einer nutzerfreundlichen und zugleich fahrtauglichen App. Wie in @sec-fahrverhaltenAblenkung dargestellt, stellen mobile Endgeräte während der Fahrt eine relevante Ablenkungsquelle dar. Daher wurde das #gls("UX")-Konzept so ausgelegt, dass der Großteil der Interaktion vor oder nach der Fahrt stattfindet. Während der Fahrt soll die App möglichst passiv im Hintergrund laufen: Die Aufzeichnung wird über wenige, klar gestaltete Bedienelemente gestartet, oder wird automatisch gestartet beziehungsweise beendet, detaillierte Analysen, Diagramme und Texte sind hingegen der Nachbetrachtung vorbehalten. Im Prototyp wurde geprüft, ob diese Trennung konsequent eingehalten wird und ob potenziell ablenkende Elemente (z. B. komplexe Menüs, lange Texte, kleine Bedienelemente) während der Fahrt vermieden werden.

Die Startseite der App (@fig-startseite) bildet den Einstieg in den Prototyp. Sie zeigt den aktuellen DriveWise-Score, einen prominent platzierten Button zum Starten des Trackings sowie eine kompakte Übersicht zur aktuellen Fahrt (Fahrfehler, Distanz, Dauer). Damit wird der Nutzer direkt zu den zentralen Funktionen der App geführt, ohne dass eine aufwändige Navigation erforderlich ist.

#figure(
  image("../../assets/figma/Startseite-Screen-Figma.png", width: 60%),
  caption: [Startseite des #gls("Figma")-Prototyps mit DriveWise-Score, Einstieg in das Fahrttracking und Übersicht zur aktuellen Fahrt.]
) <fig-startseite>

Die Fahrtenübersicht (@fig-fahrten) stellt alle aufgezeichneten Fahrten chronologisch dar. Für jede Fahrt werden Start- und Zielort, Datum, Uhrzeit, Distanz und Dauer angezeigt. Die Gestaltung ist bewusst schlicht gehalten, um einen schnellen Überblick zu ermöglichen und die Auswahl einer Fahrt für die Detailansicht zu erleichtern.

#figure(
  image("../../assets/figma/Fahrten-Screen-Figma.png", width: 60%),
  caption: [Fahrtenübersicht mit chronologischer Liste aller aufgezeichneten Fahrten.]
) <fig-fahrten>

In der Detailansicht (@fig-fahrdetails) werden eine Kartenansicht der gefahrenen Strecke und die wichtigsten Kennzahlen zur Fahrt kombiniert. Neben Durchschnitts- und Höchstgeschwindigkeit werden unter anderem die maximale Beschleunigung in G-Kräften sowie die Anzahl der erkannten Fahrfehler (Bremsen, Lenken, Beschleunigen) angezeigt. Dadurch kann der Nutzer sein Fahrverhalten für eine konkrete Fahrt im Nachgang nachvollziehen und gezielt Verbesserungspotenziale identifizieren.

#figure(
  image("../../assets/figma/Fahrdetails-Screen-Figma.png", width: 60%),
  caption: [Detailansicht einer Fahrt mit Kartenansicht, Fahrfehlern und zentralen Kennzahlen.]
) <fig-fahrdetails>

Zusätzlich wurde eine Achievements-Ansicht mit Level- und Quest-System (@fig-achievements) entworfen, die den Gamification-Ansatz der App abbildet. Nutzer erhalten Erfahrungspunkte (XP) für gefahrene Kilometer und können durch das Erreichen bestimmter Ziele (z. B. Gesamtdistanz oder fehlerfreie Fahrten) Quests abschließen. Diese Elemente sollen die langfristige Nutzung der App unterstützen und ein positives, motivationsförderndes Nutzungserlebnis schaffen.

#figure(
  image("../../assets/figma/Achievements-Screen-Figma.png", width: 60%),
  caption: [Achievements-Ansicht mit Level-System und Quests zur langfristigen Motivation eines defensiven Fahrstils.]
) <fig-achievements>

Der in #gls("Figma") erstellte Prototyp diente somit nicht nur als visuelle Grundlage für die spätere Implementierung in #gls("SwiftUI"), sondern auch als Werkzeug zur Überprüfung, ob alle Mindestanforderungen funktional abgedeckt sind, die App in ihrer Struktur nachvollziehbar bleibt und gleichzeitig die Ablenkung des Fahrers während der Fahrt auf ein Minimum reduziert wird.

Eine vollständige Übersicht aller im Prototyp enthaltenen Screens befindet sich im Anhang @anhang-UXPrototypFigma.


== Umsetzung des #gls("UX")-Prototyps in #gls("SwiftUI")

Nachdem das visuelle Design der Fahrstilanalyse-App in #gls("Figma") ausgearbeitet worden waren, wurde das dort definierte User Interface im nächsten Schritt mit #gls("SwiftUI") umgesetzt. Ziel dieser Phase war zunächst, das in #gls("Figma") entworfene #gls("UX")-Design so genau wie möglich „1:1" nachzubilden – bewusst zunächst ohne vollständige fachliche Funktionalität. Auf diese Weise konnte die Navigationsstruktur, das visuelle Erscheinungsbild und die Informationshierarchie der App in einer lauffähigen #gls("iOS")-App überprüft werden, bevor Messlogik und Datenanbindung integriert wurden (@swiftLang2023; @swiftuiApple2024).

=== Navigationsstruktur mit TabView

Die globale Navigation der App entspricht der in #gls("Figma") definierten Tab-Bar mit fünf Hauptbereichen: *Erfolge*, *Statistiken*, *Startseite*, *Fahrten* und *Profil*. In #gls("SwiftUI") wurde diese Struktur mit einer `TabView` umgesetzt, die über eine interne `Tab`-Enum gesteuert wird:

```swift
enum Tab: Hashable {
    case achievements, statistics, startseite, fahrten, profil
}

@State private var selection: Tab = .startseite

var body: some View {
    TabView(selection: $selection) {
        // ...
    }
}
```

Jeder Tab ist in einen eigenen NavigationStack eingebettet. Dies ermöglicht es, innerhalb eines Bereichs (z. B. von der Fahrtenliste in die Fahrtdetails) eigene Navigationshierarchien aufzubauen, ohne die globale Tab-Navigation zu beeinflussen. Die gemeinsame Applogik, etwa der aktuelle Fahrstatus und die Liste aller aufgezeichneten Fahrten, wird über ein zentrales DriveManager-Objekt als ```@StateObject``` in ContentView erzeugt und mittels ```.environmentObject(driveManager)``` an alle Unter-Views weitergereicht. Dadurch bleibt die Zustandsverwaltung klar getrennt von der reinen #gls("UI")-Definition.

Für den mittleren Tab (Startseite) wurde – analog zum #gls("Figma")-Entwurf – anstelle eines Standard-SF-Symbols ein eigenes App-Icon verwendet. In #gls("SwiftUI") wird hierzu geprüft, ob das Asset ```center_icon``` vorhanden ist; falls nicht, fällt die Implementierung auf ein System-Icon zurück. Dies erhöht die visuelle Wiedererkennbarkeit der zentralen Startansicht.

#figure(
image("../../assets/emulator/Startseite-Screen.png", width: 60%),
caption: [Startseite in der #gls("SwiftUI")-Implementierung mit DriveWise-Score, Tracking-Button und Übersicht zur aktuellen Fahrt.]
) <fig-swiftui-startseite>

=== Startseite: Mapping des #gls("Figma")-Layouts nach #gls("SwiftUI")

Die Startseite wurde in #gls("SwiftUI") so umgesetzt, dass Aufbau und Gestaltungslogik dem #gls("Figma")-Prototyp möglichst genau entsprechen. Die View StartseiteView verwendet einen ZStack für den farbigen Hintergrund und einen ScrollView für den vertikal scrollbaren Inhalt. Die in #gls("Figma") definierten Karten und Bereiche (Score-Karte, Track-Button, aktuelle Fahrt, Status-Karte) sind jeweils als VStack-Blöcke mit abgerundeten Rechtecken (RoundedRectangle) und projektspezifischen Farbkonstanten realisiert.

Der Titel „Drive Wise“ und der „Mein DriveWise Score“-Block bilden die visuelle Einstiegsfläche. Darunter folgt ein großer, vollflächiger Button zum Starten bzw. Beenden der Fahrt. In der ersten Iteration wurde dieser Button lediglich als #gls("UI")-Element umgesetzt; in einem späteren Schritt wurde die Tap-Action an den DriveManager angebunden, um tatsächlich Messdaten zu erfassen. Die Statuskarte am unteren Bildschirmrand wurde über eine Picker-Komponente realisiert, die zwischen verschiedenen farbigen Zuständen (z. B. Grün/Gelb/Rot) umschalten kann. Diese Struktur orientiert sich eng an den im Prototyp definierten #gls("UX")-Prinzipien: zentrale Funktion im Fokus, klare Lesbarkeit und minimale visuelle Ablenkung während der Fahrt.

=== Fahrtenübersicht und Fahrtdetails

Die Fahrtenübersicht wurde in der Implementierung als eigene View (FahrtenListView) umgesetzt und in die TabView integriert. Inhaltlich und visuell entspricht sie der in #gls("Figma") modellierten Liste: Pro Fahrt werden Startort, Zielort, Distanz, Uhrzeit und Datum angezeigt. Die Einträge werden gruppiert nach Datum dargestellt, sodass der Nutzer vergangene Fahrten schnell einordnen kann.

#figure(
image("../../assets/emulator/AlleFahrten-Screen.png", width: 60%),
caption: [Fahrtenübersicht in #gls("SwiftUI") mit gruppierter Darstellung aller aufgezeichneten Fahrten.]
) <fig-swiftui-fahrten>

Wählt der Nutzer eine Fahrt aus der Liste aus, navigiert die App in die FahrtDetailView. Diese View wurde bewusst so gestaltet, dass sie die im #gls("Figma")-Prototyp angelegte Struktur übernimmt: Eine Kopfkarte mit Datum, Start- und Zielort sowie Distanz und Dauer, gefolgt von einem Bereich für die Kartenansicht der Route (zunächst als Platzhalter) und einer Fehlerübersicht. Die Fehlerübersicht besteht aus einer Karte mit vier Spalten (gesamt, Bremsen, Lenken, Beschleunigen) und nutzt SF-Symbole (z. B. steeringwheel oder rocket.fill) zur visuellen Unterstützung.

Darunter folgen Kennzahl-Karten für Durchschnittsgeschwindigkeit, Höchstgeschwindigkeit und maximale Beschleunigung. Jede dieser Karten ist als eigene Zeile (metricRow) umgesetzt, bestehend aus Icon, Titel und Wert. Damit orientiert sich die Implementierung eng an der im #gls("Figma")-Prototyp definierten Informationshierarchie: Zunächst kontextuelle Metadaten zur Fahrt, dann sicherheitsrelevante Ereignisse, anschließend aggregierte Kennzahlen.

#figure(
image("../../assets/emulator/Fahrdetails-Screen.png", width: 60%),
caption: [Fahrtdetailansicht mit Kopfkarte, Kartenplatzhalter, Fehlerübersicht und Kennzahlkarten.]
) <fig-swiftui-fahrdetails>

=== Statistik- und Erfolgsansichten

Die im #gls("Figma")-Prototyp vorgesehenen Auswertungsbereiche wurden in #gls("SwiftUI") als separate Tabs umgesetzt. Die Statistik-Ansicht (Statistiken) fasst die Fahrten einer Woche oder eines Monats zusammen und zeigt unter anderem die mittlere Geschwindigkeit, die Anzahl der Fahrten und Fahrfehler sowie die Gesamtdistanz. Im aktuellen Implementierungsstand sind Balkendiagramme als Platzhalter vorgesehen, die später durch konkrete Diagrammkomponenten ersetzt werden sollen. Struktur und Layout der Statistik-Screen entsprechen bereits dem #gls("Figma")-Design, sodass die spätere Integration realer Daten hauptsächlich die Inhalte betrifft.

#figure(
image("../../assets/emulator/Statistiken-Screen.png", width: 60%),
caption: [Statistik-Ansicht mit Wochen-/Monatsumschaltung und Kennzahlenübersicht.]
) <fig-swiftui-statistiken>

Die Erfolge-Ansicht (Erfolge) visualisiert das Gamification-Konzept der App. Sie zeigt das aktuelle Level, eine Fortschrittsleiste zum nächsten Level und eine Liste von Quests, bei denen der Nutzer für das Erreichen bestimmter Distanzen Erfahrungspunkte erhält. In #gls("SwiftUI") wurde dieser Bereich als scrollbare Liste von Karten umgesetzt, die in Aufbau und Farbgebung an die #gls("Figma")-Vorlage angelehnt sind. Die Inhalte sind zunächst statisch; die dynamische Berechnung von XP und Leveln kann in einer späteren Ausbaustufe über das zentrale Zustandsobjekt ergänzt werden.

#figure(
image("../../assets/emulator/Erfolge-Screen.png", width: 60%),
caption: [Erfolge-Ansicht mit Levelanzeige, Fortschrittsbalken und Quest-Liste.]
) <fig-swiftui-erfolge>

=== Zwischenfazit zur #gls("UI")-Implementierung

Die Umsetzung des #gls("Figma")-#gls("UX")-Prototyps in #gls("SwiftUI") diente als wichtiger Zwischenschritt zwischen konzeptionellem Design und funktionsfähiger Anwendung. Durch die Konzentration auf Layout, Navigationsstruktur und Informationsdarstellung konnte sichergestellt werden, dass 
- die im Grundlagenkapitel definierten #gls("UX")-Ziele (Nutzerfreundlichkeit, Verständlichkeit, Reduktion von Ablenkung während der Fahrt) eingehalten werden, 
- alle fachlichen Mindestanforderungen bereits in der Oberfläche sichtbar angelegt sind, 
- und spätere Implementierungsschritte (Anbindung der Sensorik, Berechnung der Fahrfehler, Darstellung realer Statistiken) in eine konsistente #gls("UI") integriert werden können.
Damit bildet die #gls("SwiftUI")-Implementierung des #gls("UX") ein stabiles Fundament, auf dem die weitere technische Umsetzung der Fahrstilanalyse aufbauen kann.



= Code
== Features einbauen
  - CoreMotion für Bewegungssensoren
  - MapKit für Kartenanzeige
  - CoreData für lokale Speicherung
  - HealthKit für Health Daten (Geschwindigkeit)
  - Algorithmen zur Fahrverhaltensanalyse
   
- CoreData für lokale Speicherung (Lokal oder iCloud)


= Anlysen (Joscha, Max)
- Algorithmen zur Fahrverhaltensanalyse
  - Beschleunigung
  - Bremsverhalten
  - Kurvenverhalten
  - Geschwindigkeit

= Gamification (Joscha)
- Punkte System
- Levels
- Belohnungen 
- Benachrichtigungen

= Testen
