# E-Commerce Operations & Customer Experience Analysis

**PostgreSQL | SQL | Power BI | Business Analytics**

## Über das Projekt

Wie zuverlässig werden Online-Bestellungen geliefert? Und welchen Einfluss haben verspätete Lieferungen auf die Zufriedenheit der Kunden?

Mit diesen Fragen habe ich mich in diesem Projekt beschäftigt. Dafür habe ich **99.441 Bestellungen** aus dem öffentlich verfügbaren E-Commerce-Datensatz von Olist untersucht.

Mein Ziel war es, nicht nur Kennzahlen zu berechnen, sondern auch herauszufinden, wo konkrete Probleme im Lieferprozess auftreten, welche Kundengruppen besonders betroffen sind und welche Verbesserungsmaßnahmen sich aus den Daten ableiten lassen.

Die Daten habe ich mit PostgreSQL und SQL aufbereitet und analysiert. Anschließend habe ich die wichtigsten Ergebnisse in einem interaktiven Power-BI-Dashboard dargestellt.

## Vorgehensweise

Zu Beginn habe ich die verschiedenen Datentabellen miteinander verknüpft und für die Analyse vorbereitet. Eine besondere Herausforderung bestand darin, dass einzelne Bestellungen mehrere Produkte, Zahlungen oder Bewertungen enthalten können. Deshalb habe ich die Daten zunächst auf Bestellungsebene zusammengeführt, um doppelte Zählungen zu vermeiden.

Außerdem habe ich die Lieferzeitstempel überprüft und unplausible Zeitangaben bei den entsprechenden Berechnungen ausgeschlossen.

Darauf aufbauend habe ich die Analyse in drei Themenbereiche unterteilt: Lieferperformance, Kundenzufriedenheit sowie regionale und produktbezogene Unterschiede.

## Was ich herausgefunden habe

### 1. Lieferverzögerungen sind ein relevantes Problem

Von den insgesamt 99.441 Bestellungen wurden 96.478 erfolgreich zugestellt. Bei 96.470 Bestellungen konnte ich die Lieferpünktlichkeit zuverlässig bewerten.

**6.534 Bestellungen kamen zu spät an.** Das entspricht einer Verspätungsquote von **6,77 %**.

Besonders auffällig fand ich, dass es sich dabei häufig nicht nur um kurze Verzögerungen handelt. **43,80 % der verspäteten Bestellungen** wurden mindestens acht Tage nach dem angekündigten Liefertermin zugestellt.

Deshalb habe ich mir genauer angesehen, in welcher Phase des Lieferprozesses die größten zeitlichen Unterschiede auftreten.

Bei schwerwiegend verspäteten Bestellungen dauerte die Phase zwischen der Übergabe an den Transportdienstleister und der tatsächlichen Zustellung durchschnittlich **47,59 Tage**. Bei pünktlichen Bestellungen waren es nur **7,98 Tage**.

Der Unterschied von **39,61 Tagen** zeigt, warum gerade diese Phase bei einer weiteren Untersuchung im Mittelpunkt stehen sollte.

### 2. Verspätete Lieferungen gehen mit deutlich schlechteren Bewertungen einher

Eines der deutlichsten Ergebnisse betrifft die Kundenzufriedenheit.

Pünktlich gelieferte Bestellungen erhielten durchschnittlich **4,29 von 5 Punkten**. Bei verspäteten Lieferungen lag die Bewertung dagegen nur bei **2,27 Punkten**.

Auch der Anteil negativer Bewertungen unterscheidet sich erheblich:

- **9,23 %** bei pünktlichen Lieferungen
- **62,36 %** bei verspäteten Lieferungen

Interessant ist außerdem, wie stark sich die Bewertungen bereits bei einer Verzögerung von wenigen Tagen verändern.

Während bei einer Verspätung von ein bis drei Tagen 32,18 % der bewerteten Bestellungen eine negative Bewertung erhielten, stieg dieser Anteil bei vier bis sieben Tagen auf **67,56 %**.

Für mich war das ein wichtiger Hinweis darauf, dass Unternehmen gefährdete Bestellungen möglichst früh erkennen sollten, anstatt erst bei längeren Verzögerungen zu reagieren.

### 3. Nicht jede Region hat dasselbe Problem

Bei der regionalen Analyse habe ich festgestellt, dass die Anzahl verspäteter Bestellungen und die Verspätungsquote zu unterschiedlichen Prioritäten führen.

**São Paulo** verzeichnete mit **1.820** die meisten verspäteten Bestellungen. Die Verspätungsquote lag dort allerdings bei **4,49 %**.

In **Rio de Janeiro** kamen zwar weniger Bestellungen zu spät (**1.495**), die Verspätungsquote war mit **12,11 %** jedoch deutlich höher.

Deshalb würde ich die beiden Regionen unterschiedlich priorisieren: In Rio de Janeiro steht die Verbesserung der Lieferzuverlässigkeit im Vordergrund, während in São Paulo vor allem die hohe absolute Anzahl betroffener Bestellungen relevant ist.

Bei der Kombination aus Region und Produktkategorie fiel mir besonders **Rio de Janeiro × bed_bath_table** auf. In diesem Segment wurden **202 von 1.357 Bestellungen verspätet geliefert**, was einer Quote von **14,89 %** entspricht.

Dieses Segment eignet sich daher als konkreter Ausgangspunkt, um Verkäufer, Transportverbindungen und Zustellprozesse genauer zu untersuchen.

## Welche Maßnahmen ich empfehlen würde

Aus der Analyse habe ich drei Empfehlungen abgeleitet.

**Zuerst würde ich die Transportprozesse genauer untersuchen.** Vor allem in Rio de Janeiro und bei der Produktkategorie `bed_bath_table` sollten auffällige Transportverbindungen identifiziert und die einzelnen Prozessschritte überprüft werden.

**Außerdem halte ich eine frühzeitige Kundeninformation für sinnvoll.** Wenn eine Bestellung voraussichtlich verspätet ankommt, könnte eine rechtzeitige und transparente Benachrichtigung die Unsicherheit der Kunden reduzieren. Ob dadurch tatsächlich bessere Bewertungen erzielt werden, müsste zunächst getestet werden.

**Schließlich sollten regionale Maßnahmen unterschiedlich ausgerichtet werden.** Während in Rio de Janeiro die hohe Verspätungsquote im Mittelpunkt steht, würde ich in São Paulo zunächst die Transportverbindungen mit den meisten verspäteten Bestellungen untersuchen.

Diese Empfehlungen beruhen auf den Ergebnissen der Datenanalyse. Sie wurden nicht in einem realen Unternehmen umgesetzt.

## Power-BI-Dashboard

Um die Ergebnisse übersichtlich darzustellen, habe ich ein Dashboard mit vier Seiten erstellt.

| Seite | Inhalt |
|---|---|
| Executive Overview | Überblick über Bestellungen, Lieferpünktlichkeit und Kundenbewertungen |
| Delivery Performance | Analyse der Verspätungsschwere und der einzelnen Lieferphasen |
| Customer Satisfaction | Vergleich negativer Bewertungen nach Lieferstatus und Verzögerungsdauer |
| Regional & Product Analysis | Identifikation auffälliger Regionen und Produktkategorien |

Die Visualisierungen basieren auf den mit PostgreSQL aufbereiteten Daten und lassen sich über verschiedene Filter interaktiv untersuchen.

## Verwendete Tools

**PostgreSQL & SQL**

Für die Datenaufbereitung und Analyse habe ich unter anderem Joins, CTEs, Aggregationen und Views verwendet. Zusätzlich habe ich die Datenqualität überprüft und die wichtigsten Kennzahlen mit den Ausgangsdaten abgeglichen.

**Power BI**

Mit Power BI habe ich die Analyseergebnisse in interaktive Visualisierungen übertragen. Dabei habe ich mit Power Query, Datenmodellierung, DAX Measures und verschiedenen Diagrammtypen gearbeitet.

## Was ich aus dem Projekt mitgenommen habe

Das Projekt hat mir gezeigt, dass eine Datenanalyse nicht mit der Berechnung von Kennzahlen endet.

Besonders wichtig fand ich, unterschiedliche Perspektiven miteinander zu verbinden. Eine Region mit vielen verspäteten Bestellungen ist beispielsweise nicht automatisch die Region mit dem höchsten Verspätungsrisiko. Erst durch den Vergleich von absoluten Zahlen, Quoten und Kundenbewertungen lassen sich sinnvolle Prioritäten setzen.

Außerdem habe ich gelernt, wie wichtig die Datenqualität für verlässliche Ergebnisse ist. Schon kleine Unterschiede bei der Definition einer Kennzahl oder beim Zusammenführen von Tabellen können die Interpretation verändern.

Am wertvollsten war für mich deshalb der Schritt von der technischen Datenanalyse zu konkreten geschäftlichen Fragestellungen: **Was zeigen die Ergebnisse, warum sind sie relevant und welche Entscheidung lässt sich daraus ableiten?**

## Datenquelle

Brazilian E-Commerce Public Dataset by Olist – Kaggle

Die Analyse basiert auf historischen Daten. Die festgestellten Zusammenhänge sind nicht automatisch als kausale Wirkungen zu interpretieren. Die vorgeschlagenen Maßnahmen sind Empfehlungen und wurden nicht praktisch umgesetzt.
