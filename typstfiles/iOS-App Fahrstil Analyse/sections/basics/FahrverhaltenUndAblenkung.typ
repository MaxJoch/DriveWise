#import "../setup.typ": gls

= Fahrverhalten und Ablenkung <sec-fahrverhaltenAblenkung>

== Analyseverfahren für Fahrstildaten

Die Analyse von Fahrstildaten dient der objektiven Bewertung des Fahrverhaltens auf Basis messbarer Größen. Durch die systematische Auswertung von Sensordaten können Rückschlüsse auf Sicherheit, Effizienz und Umweltverträglichkeit gezogen werden. Hierzu werden sowohl klassische statistische Kennzahlen als auch segmentierte und maschinell ausgewertete Datensätze eingesetzt.

=== Statistische Kennzahlen

Zu den grundlegenden Metriken zählen Durchschnitts- und Spitzengeschwindigkeit, Beschleunigungs- und Bremsvorgänge, Dauer einzelner Fahrten sowie G-Kraft-Spitzen während Kurven-, Beschleunigungs- oder Bremsmanövern. Diese Parameter erlauben eine quantitative Einschätzung des Fahrverhaltens in Bezug auf Fahrdynamik und Verkehrssicherheit (@yellowfox2025).

Nach Angaben der YellowFox GmbH werden insbesondere starke Beschleunigungs- und Bremsvorgänge, abrupte Lenkmanöver sowie Geschwindigkeitsüberschreitungen als Indikatoren für einen „aggressiven" Fahrstil gewertet (@yellowfox2025). Auch in wissenschaftlichen Ansätzen werden solche Schwellenwerte herangezogen, um Fahrverhalten zu kategorisieren – beispielsweise die Häufigkeit starker Querbeschleunigungen oder die Varianz der Geschwindigkeit (@saiprasert2013).

Neben der Ermittlung von Einzelwerten erfolgt häufig eine Normierung der Messgrößen über die gesamte Strecke, um verschiedene Fahrten vergleichbar zu machen. Eine hohe Varianz in der Beschleunigung deutet auf ein inkonsistentes Fahrverhalten hin, während gleichmäßige Werte auf defensive Fahrweise schließen lassen (@yao2024drivingPatternsHtml).

=== Segmentierung der Strecke

Für eine differenzierte Bewertung werden Fahrten häufig in Teilsegmente unterteilt, die jeweils ein homogenes Fahrverhalten aufweisen. Diese Segmentierung kann zeit- oder distanzbasiert erfolgen, etwa in Abschnitten von Sekunden oder Metern. Je kleiner die Segmente, desto präziser kann das Fahrverhalten analysiert werden. Alternativ kann die Segmentierung auch auf Veränderungen in Geschwindigkeit, Richtung oder Beschleunigung basieren, um Phasen gleichartigen Fahrverhaltens zu identifizieren (@moosavi2016).

Die Technische Hochschule Ingolstadt beschreibt im Projekt Fahrerverhaltens-Schätzer, dass durch Segmentierung auffällige Fahrabschnitte automatisch erkannt und klassifiziert werden können, etwa starkes Beschleunigen vor Kurven oder abrupte Bremsungen vor Ampeln (@thi2025). Solche Methoden erlauben eine gezielte Auswertung einzelner Situationen anstatt nur summarischer Werte über die gesamte Fahrt.

=== Relevante Kennzahlen in der Fahrstilanalyse

Zur objektiven Bewertung des Fahrverhaltens werden in der Praxis und Forschung typischerweise folgende Kennzahlen erhoben:

- *Durchschnittsgeschwindigkeit (v̄):* misst das generelle Fahrtempo über die Strecke.  
- *Spitzengeschwindigkeit (v_max):* identifiziert Geschwindigkeitsüberschreitungen und risikoreiches Verhalten.  
- *Beschleunigung (a):* erfasst Längsdynamik, etwa starkes Beschleunigen oder Abbremsen.  
- *Bremsintensität (a_neg):* starke negative Beschleunigung als Indikator für abruptes Bremsen.  
- *Querbeschleunigung (a_lat):* misst Kurvendynamik und Stabilität bei Richtungswechseln.  
- *G-Kraft-Spitzen:* charakterisieren dynamische Manöver (z. B. schnelle Kurvenfahrt).  
- *Fahrzeit / Stillstandszeit:* zeigt Anteil aktiver Fahrphasen und Leerlauf.  
- *Fahrdistanz:* zur Relativierung anderer Kennzahlen.  
- *Varianz der Geschwindigkeit und Beschleunigung:* Indikator für gleichmäßiges oder hektisches Fahrverhalten.  
- *Fahrerevents:* Anzahl harter Bremsungen, Beschleunigungen oder Kurvenvorgänge pro Kilometer.  

Diese Kennzahlen bilden die Grundlage für die algorithmische Bewertung des Fahrstils und sind Voraussetzung für weiterführende Analysen, etwa Klassifikation oder Feedback-Systeme (@yellowfox2025).

== Ablenkung von Autofahrern durch mobile Endgeräte und ihre Auswirkungen auf DriveWise Live-Feedback

Smartphones werden heutzutage für eine Vielzahl von Anwendungszwecken während der Fahrt genutzt, sei es zum Hören von Musik oder zur Nutzung eines Navigationssystems, aber auch zum Telefonieren. Diese Nutzung stellt laut #gls("WHO") ein zunehmend ernstzunehmendes Problem dar. Laut eigener Aussage verwenden 60% bis 70% der Autofahrer ein Smartphone zu irgendeinem Zeitpunkt während der Fahrt (@who2011 S.15). Die Wahrscheinlichkeit in einen Unfall verwickelt zu sein, wird durch die Nutzung eines Smartphones rund um das vierfache erhöht. Hierbei zählt sogar das Nutzen einer Freisprechanlage zu den Verursachern und nicht nur das direkte halten und benutzen des Smartphones mit den Händen (@who2011 S. 3-4). Dies liegt vorallem daran, dass zur Hauptaufgabe des Fahrens eine sekundäre Aufgabe hinzukommt, nämlich das Verwenden des Smartphones in beliebiger Art und Weise. Die Aufmerksamkeit des Fahrers steht also nicht mehr uneingeschränkt für die Hauptaufgabe zur Verfügung sondern wird sich mit der sekundären Aufgabe geteilt und beeinflusst somit das Ausführen der Hauptaufgabe (@who2011 S. 7).

Hierbei wird in der Wissenschaft zwischen verschiedenen Arten der Ablenkung unterschieden (@strayer2013 S. 4):

- *Visuelle Ablenkung* liegt vor, wenn der Fahrer die Augen von der Straße entfernt, beispielsweise um eine Nachricht auf seinem Handy zu lesen, die auf dem Display erscheint.
- Bei der *Manuellen Ablenkung* nimmt der Fahrer seine Hände vom Lenkrad um direkt mit dem Smartphone zu interagieren, um beispielsweise auf eine Textnachricht zu antworten.
- *Kognitive Ablenkung* beschreibt das bereits zuvor beschriebene Phänomen, dass die Aufmerksamkeit des Fahrers auf eine sekundäre Aufgabe gelenkt wird, die in vielfältigen Variationen durch das Smartphone auftreten können. Der Fahrer kann hierbei noch auf die Straße schauen und auch die Hände am Lenkrad haben, verwendet jedoch nicht mehr die volle Aufmerksamkeit für das Fahren. Hierzu kann zum Beispiel das Verwenden einer Freisprechanlage sein, da der Fahrer sich auf das Gespräch konzentriert.

Da unser Live-Feedback den Fahrer während der Fahrt auf seine aktuelle Fahrweise aufmerksam machen soll, gilt es, die oben gennanten Ablenkungen zu minimieren, um eine optimale Sicherheit zu gewährleisten. Im Folgenden wird erläutert, durch welche Maßnahmen die drei Ablenkungsarten minimiert werden sollen.

- Um die *Visuelle Ablenkung* zu reduzieren haben wir uns dazu entschieden, eine reine farbliche Darstellung zu verwenden. Der Nutzer bekommt keine ausformulierten Sätze oder Diagramme während der Fahrt angezeigt, sondern lediglich eine farbliche Einordnung seiner aktuellen Fahrweise. Gleichzeitig muss der Nutzer nicht aktiv auf sein Handy schauen, da er die aktuelle Farbe aus dem Augenwinkel bereits sehen kann.
- Die *Manuelle Ablenkung* wollen wir reduzieren, indem wir dem Kunden durch das Live-Feedback keine Möglichkeiten zur Interaktion geben. Das Feature wird nicht anklickbar sein, sondern nur eine Anzeige darstellen. Auch blockieren wir während eine Fahrt getrackt wird alle anderen Interaktionen mit der App, um dem Nutzer so gut es geht die Möglichkeit zu nehmen während der Fahrt aktiv mit unserer App zu interagieren.
- Die *Kognitive Ablenkung* versuchen wir durch ein einfaches Ampelsystem zu minimieren. Der Nutzer sieht im Augenwinkel einen grünen, gelben oder roten Bildschirm, je nach aktueller Fahrweise. Die Farbkodierung am Beispiel einer Verkehrsampel ist bei Autofahrern bereits angelernt und erfordert somit eine kleinstmögliche koginitive Leistung. Der Nutzer erhält sofort die Information anhand der aktuellen Farbe und muss dafür nicht nachdenken oder eine eigene Einschätzung durchlaufen.