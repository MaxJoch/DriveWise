#import "../setup.typ": gls

= Smartphone Sensorik

Smartphones verfügen über mehrere integrierte Sensoren, mit denen sich physikalische Größen wie Position, Geschwindigkeit und Beschleunigung erfassen lassen. Diese Sensorik bildet die technische Grundlage vieler Mobilitäts- und Analyseanwendungen. Für eine Fahrstilanalyse sind insbesondere satellitengestützte Positionsdaten sowie Bewegungsdaten aus Beschleunigungs- und Drehsensoren relevant.

== Global Positioning System (#gls("GPS"))

Das Global Positioning System (#gls("GPS")) ist ein satellitengestütztes System zur Positionsbestimmung. Ein Empfänger (z. B. das Smartphone) berechnet seine Position aus Laufzeit- bzw. Zeitdifferenzen von Signalen mehrerer Satelliten. Aus aufeinanderfolgenden Positionen lassen sich Strecke und Geschwindigkeit ableiten (@bangash2021, S. 4 f.). In der Praxis wird die Genauigkeit durch verschiedene Einflüsse begrenzt, etwa Abschattungen, Signalreflexionen und Mehrwegeffekte in „urbanen Schluchten“ sowie atmosphärische Störungen. Dadurch kann die Präzision insbesondere in Städten deutlich sinken und es kommt zu sprunghaften Messwerten (sog. Drift) (@liu2021, S. 15 ff.). Für Anwendungen, die Fahrmanöver erkennen sollen, ist daher eine robuste Verarbeitung (z. B. Glättung, Plausibilitätsprüfungen) notwendig.

== Bewegungssensoren und Fahrzeugdynamik

Neben #gls("GPS") liefern Bewegungssensoren zusätzliche Informationen zur Dynamik. Beschleunigungssensoren messen lineare Beschleunigungen, während Gyroskope Rotationsraten erfassen. Aus diesen Signalen lassen sich Manöver ableiten: Hohe positive Längsbeschleunigungen können auf starkes Beschleunigen, negative Werte auf Bremsvorgänge und erhöhte Querbeschleunigungen auf dynamische Kurvenfahrten hindeuten (@Nidhi2021, S. 1971 ff.). Bewegungsdaten sind jedoch ebenfalls fehlerbehaftet (z. B. Rauschen, Bias). Eine Kombination mehrerer Quellen im Sinne der #gls("Sensorfusion") kann die Robustheit erhöhen, weil Ausfälle oder Messfehler einer Quelle durch die andere teilweise kompensiert werden (@allan2011, S. 37 ff.; @faragher2015, S. 2422).

== Abtastrate und Energieverbrauch

Die Erfassung hochfrequenter Sensorwerte verbessert zwar die zeitliche Auflösung, erhöht jedoch den Energieverbrauch. Für mobile Anwendungen ist daher ein Kompromiss zwischen Messqualität und Batterieverbrauch erforderlich. Untersuchungen zeigen, dass moderate Genauigkeitseinstellungen häufig ein gutes Verhältnis zwischen Energiebedarf und Nutzbarkeit bieten (@bangash2021, S. 4 f.). Für eine spätere Auswertung kann zudem eine Segmentierung der Zeitreihen in kurze Zeitfenster sinnvoll sein, da sie Analyse und Visualisierung erleichtert (@moosavi2016).
