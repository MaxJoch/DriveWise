import SwiftUI
import Charts

struct StatisticsOverviewCard: View {
    let totalDrives: Int
    let totalDistance: Double
    let totalDurationText: String
    let averageDistance: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.accentColor)
                Text("Übersicht")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }

            Divider().background(Color.white.opacity(0.15))

            HStack(spacing: 20) {
                StatisticItem(
                    icon: "car.fill",
                    value: "\(totalDrives)",
                    label: "Fahrten"
                )

                StatisticItem(
                    icon: "location.fill",
                    value: String(format: "%.1f km", totalDistance),
                    label: "Gesamtstrecke"
                )
            }

            HStack(spacing: 20) {
                StatisticItem(
                    icon: "clock.fill",
                    value: totalDurationText,
                    label: "Gesamtzeit"
                )

                StatisticItem(
                    icon: "chart.line.uptrend.xyaxis",
                    value: String(format: "%.1f km", averageDistance),
                    label: "Ø Distanz"
                )
            }
        }
        .padding()
        .appSectionCardStyle(cornerRadius: 16)
    }
}

struct StatisticsScoreCard: View {
    let averageScore: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Durchschnittlicher Score")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }

            Divider().background(Color.white.opacity(0.15))

            HStack {
                Text(String(format: "%.0f", averageScore))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(scoreColor(averageScore))

                Spacer()

                VStack(alignment: .trailing) {
                    scoreIndicator(score: averageScore)
                    Text(scoreText(averageScore))
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding()
        .appSectionCardStyle(cornerRadius: 16)
    }

    private func scoreColor(_ score: Double) -> Color {
        switch score {
        case 95...120: return .green
        case 75..<95: return .yellow
        default: return .red
        }
    }

    private func scoreText(_ score: Double) -> String {
        switch score {
        case 110...120: return "Ausgezeichnet"
        case 95..<110: return "Sehr gut"
        case 80..<95: return "Gut"
        case 65..<80: return "Befriedigend"
        case 50..<65: return "Ausreichend"
        default: return "Verbesserungswürdig"
        }
    }

    private func scoreIndicator(score: Double) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Circle()
                    .fill(Double(index) < score / 24 ? scoreColor(score) : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

struct StatisticsSpeedCard: View {
    let averageSpeed: Double
    let maxSpeed: Double
    let speedingKm: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "speedometer")
                    .foregroundColor(.accentColor)
                Text("Geschwindigkeit")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }

            Divider().background(Color.white.opacity(0.15))

            HStack(spacing: 30) {
                VStack(alignment: .leading) {
                    Text("Durchschnitt")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text(String(format: "%.0f km/h", averageSpeed))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                }

                Spacer()

                VStack(alignment: .leading) {
                    Text("Maximum")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text(String(format: "%.0f km/h", maxSpeed))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                }
            }

            if speedingKm > 0 {
                Divider().background(Color.white.opacity(0.15))
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Über 130 km/h:")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text(String(format: "%.1f km", speedingKm))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .appSectionCardStyle(cornerRadius: 16)
    }
}

struct StatisticsDistanceByWeekdayCard: View {
    let distanceByWeekday: [Int: Double]
    let weekdayName: (Int) -> String
    let selectedPeriod: StatisticsPeriod

    private var titleText: String {
        switch selectedPeriod {
        case .day:
            return "Distanz heute"
        case .week:
            return "Distanz diese Woche nach Wochentag"
        case .month:
            return "Distanz diesen Monat nach Wochentag"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.accentColor)
                Text(titleText)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }

            Divider().background(Color.white.opacity(0.15))

            if !distanceByWeekday.isEmpty {
                let maxDistance = distanceByWeekday.values.max() ?? 1

                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(1...7, id: \.self) { weekday in
                        VStack(spacing: 4) {
                            let distance = distanceByWeekday[weekday] ?? 0
                            let height = maxDistance > 0 ? (distance / maxDistance) * 80 : 0

                            if distance > 0 {
                                Text(String(format: "%.0f", distance))
                                    .font(.caption2)
                                    .foregroundColor(.textSecondary)
                            }

                            Rectangle()
                                .fill(Color.accentColor.opacity(0.8))
                                .frame(height: max(height, 2))
                                .cornerRadius(4)

                            Text(weekdayName(weekday))
                                .font(.caption2)
                                .foregroundColor(.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 120)
            } else {
                Text("Keine Daten verfügbar")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding()
        .appSectionCardStyle(cornerRadius: 16)
    }
}

struct StatisticsErrorOverviewCard: View {
    let totalErrors: Int
    let totalDrives: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text("Fehlerübersicht")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }

            Divider().background(Color.white.opacity(0.15))

            HStack {
                Text("\(totalErrors)")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.red)

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Fehler gesamt")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)

                    if totalDrives > 0 {
                        Text(String(format: "Ø %.1f pro Fahrt", Double(totalErrors) / Double(totalDrives)))
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
        .padding()
        .appSectionCardStyle(cornerRadius: 16)
    }
}

struct StatisticsErrorDetailsCard: View {
    let hardBrakes: Int
    let veryHardBrakes: Int
    let hardAccelerations: Int
    let veryHardAccelerations: Int
    let sharpTurns: Int
    let verySharpTurns: Int
    let selectedPeriod: StatisticsPeriod
    let errorBreakdownOverTime: [ErrorBreakdownDataPoint]
    let allTimeErrorBreakdownOverTime: [ErrorBreakdownDataPoint]

    @State private var selectedCategory: ErrorCategoryType?
    @State private var selectedDetailPage: Int = 0

    private enum ErrorCategoryType: String, Identifiable {
        case brakes
        case accelerations
        case turns

        var id: String { rawValue }

        var title: String {
            switch self {
            case .brakes: return "Bremsen"
            case .accelerations: return "Beschleunigungen"
            case .turns: return "Lenkungen"
            }
        }

        var icon: String {
            switch self {
            case .brakes: return "arrow.down.circle.fill"
            case .accelerations: return "arrow.up.circle.fill"
            case .turns: return "steeringwheel"
            }
        }

        var color: Color {
            switch self {
            case .brakes: return .red
            case .accelerations: return .orange
            case .turns: return .yellow
            }
        }

        var descriptionText: String {
            switch self {
            case .brakes: return "Verlauf harter und sehr harter Bremsereignisse"
            case .accelerations: return "Verlauf harter und sehr harter Beschleunigungsereignisse"
            case .turns: return "Verlauf scharfer und sehr scharfer Lenkereignisse"
            }
        }
    }

    private struct CategorySeriesPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Int
    }

    private enum SeriesScope {
        case selectedPeriod
        case allTime
    }

    private func sourcePoints(for scope: SeriesScope) -> [ErrorBreakdownDataPoint] {
        switch scope {
        case .selectedPeriod:
            return errorBreakdownOverTime
        case .allTime:
            return allTimeErrorBreakdownOverTime
        }
    }

    private func seriesPoints(for category: ErrorCategoryType, scope: SeriesScope) -> [CategorySeriesPoint] {
        sourcePoints(for: scope).map { point in
            let value: Int
            switch category {
            case .brakes:
                value = point.brakes
            case .accelerations:
                value = point.accelerations
            case .turns:
                value = point.turns
            }
            return CategorySeriesPoint(date: point.date, value: value)
        }
        .sorted { $0.date < $1.date }
    }

    private func hasEnoughData(for category: ErrorCategoryType, scope: SeriesScope) -> Bool {
        let points = seriesPoints(for: category, scope: scope)
        guard points.count >= 2 else { return false }
        let distinctTimes = Set(points.map { $0.date.timeIntervalSince1970 })
        return distinctTimes.count >= 2
    }

    private func metricValues(for category: ErrorCategoryType, scope: SeriesScope) -> (avg: Double, max: Int, latest: Int)? {
        let values = seriesPoints(for: category, scope: scope).map { $0.value }
        guard !values.isEmpty else { return nil }
        let average = Double(values.reduce(0, +)) / Double(values.count)
        let maximum = values.max() ?? 0
        let latest = values.last ?? 0
        return (avg: average, max: maximum, latest: latest)
    }

    private var periodSubtitle: String {
        switch selectedPeriod {
        case .day: return "Zeitraum: Heute (pro Fahrt)"
        case .week: return "Zeitraum: Diese Woche (pro Tag)"
        case .month: return "Zeitraum: Dieser Monat (pro Tag)"
        }
    }

    private var xAxisLabelFormat: Date.FormatStyle {
        switch selectedPeriod {
        case .day:
            return .dateTime.hour().minute()
        case .week, .month:
            return .dateTime.day().month(.abbreviated)
        }
    }

    private var allTimeXAxisLabelFormat: Date.FormatStyle {
        .dateTime.day().month(.abbreviated)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(.accentColor)
                Text("Fehlerverteilung")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }

            Divider().background(Color.white.opacity(0.15))

            VStack(spacing: 12) {
                ErrorCategoryRow(
                    icon: "arrow.down.circle.fill",
                    title: "Bremsen",
                    hardCount: hardBrakes,
                    veryHardCount: veryHardBrakes,
                    color: .red,
                    isTappable: true
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedCategory = .brakes
                }

                ErrorCategoryRow(
                    icon: "arrow.up.circle.fill",
                    title: "Beschleunigungen",
                    hardCount: hardAccelerations,
                    veryHardCount: veryHardAccelerations,
                    color: .orange,
                    isTappable: true
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedCategory = .accelerations
                }

                ErrorCategoryRow(
                    icon: "steeringwheel",
                    title: "Lenkungen",
                    hardCount: sharpTurns,
                    veryHardCount: verySharpTurns,
                    color: .yellow,
                    isTappable: true
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedCategory = .turns
                }
            }

            Text("Tippe auf eine Zeile für den Verlauf")
                .font(.caption2)
                .foregroundColor(.textSecondary)
        }
        .padding()
        .appSectionCardStyle(cornerRadius: 16)
        .sheet(item: $selectedCategory) { category in
            NavigationStack {
                VStack(alignment: .leading, spacing: 14) {
                    Text(category.descriptionText)
                        .font(.subheadline)
                        .foregroundColor(.textPrimary)

                    TabView(selection: $selectedDetailPage) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(periodSubtitle)
                                .font(.caption)
                                .foregroundColor(.textSecondary)

                            if let metrics = metricValues(for: category, scope: .selectedPeriod) {
                                HStack(spacing: 8) {
                                    MiniMetricBadge(title: "Ø", value: String(format: "%.1f", metrics.avg))
                                    MiniMetricBadge(title: "Max", value: "\(metrics.max)")
                                    MiniMetricBadge(title: "Letzter", value: "\(metrics.latest)")
                                }
                            }

                            if !hasEnoughData(for: category, scope: .selectedPeriod) {
                                TrendDataHintView(text: "Zu wenig Daten für Verlauf im gewählten Zeitraum")
                            } else {
                                Chart {
                                    ForEach(seriesPoints(for: category, scope: .selectedPeriod)) { point in
                                        LineMark(
                                            x: .value("Zeit", point.date),
                                            y: .value("Anzahl", point.value)
                                        )
                                        .foregroundStyle(category.color.gradient)
                                        .interpolationMethod(.linear)

                                        AreaMark(
                                            x: .value("Zeit", point.date),
                                            y: .value("Anzahl", point.value)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [category.color.opacity(0.28), category.color.opacity(0.06)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .interpolationMethod(.linear)
                                    }
                                }
                                .frame(height: 220)
                                .chartXAxis {
                                    AxisMarks(values: .automatic) { _ in
                                        AxisValueLabel(format: xAxisLabelFormat)
                                            .foregroundStyle(Color.textSecondary)
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks {
                                        AxisValueLabel()
                                            .foregroundStyle(Color.textSecondary)
                                    }
                                }
                            }
                        }
                        .tag(0)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Gesamter Verlauf (alle Fahrten)")
                                .font(.caption)
                                .foregroundColor(.textSecondary)

                            if let metrics = metricValues(for: category, scope: .allTime) {
                                HStack(spacing: 8) {
                                    MiniMetricBadge(title: "Ø", value: String(format: "%.1f", metrics.avg))
                                    MiniMetricBadge(title: "Max", value: "\(metrics.max)")
                                    MiniMetricBadge(title: "Letzter", value: "\(metrics.latest)")
                                }
                            }

                            if !hasEnoughData(for: category, scope: .allTime) {
                                TrendDataHintView(text: "Zu wenig Daten für Gesamtverlauf")
                            } else {
                                Chart {
                                    ForEach(seriesPoints(for: category, scope: .allTime)) { point in
                                        LineMark(
                                            x: .value("Zeit", point.date),
                                            y: .value("Anzahl", point.value)
                                        )
                                        .foregroundStyle(category.color.gradient)
                                        .interpolationMethod(.linear)

                                        AreaMark(
                                            x: .value("Zeit", point.date),
                                            y: .value("Anzahl", point.value)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [category.color.opacity(0.28), category.color.opacity(0.06)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .interpolationMethod(.linear)
                                    }
                                }
                                .frame(height: 220)
                                .chartXAxis {
                                    AxisMarks(values: .automatic) { _ in
                                        AxisValueLabel(format: allTimeXAxisLabelFormat)
                                            .foregroundStyle(Color.textSecondary)
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks {
                                        AxisValueLabel()
                                            .foregroundStyle(Color.textSecondary)
                                    }
                                }
                            }
                        }
                        .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 290)

                    HStack(spacing: 7) {
                        ForEach(0..<2, id: \.self) { index in
                            Circle()
                                .fill(index == selectedDetailPage ? Color.textPrimary : Color.textSecondary.opacity(0.35))
                                .frame(width: 7, height: 7)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 2)

                    Spacer(minLength: 0)
                }
                .padding()
                .navigationTitle(category.title)
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium, .large])
            .onAppear {
                selectedDetailPage = 0
            }
        }
    }
}

struct StatisticsReflectionMetricsCard: View {
    let errorsPer100Km: Double
    let errorsPer100KmInterpretation: String
    let cleanDriveRatePercent: Double
    let cleanDriveRateInterpretation: String
    let brakeToAccelerationRatio: Double
    let brakeToAccelerationInterpretation: String
    let improvementStreak: Int
    let improvementStreakInterpretation: String
    let severeEventRatioPercent: Double
    let severeEventRatioInterpretation: String

    private func errorsStatus(for value: Double) -> (text: String, color: Color) {
        switch value {
        case ..<5: return ("Gut", .green)
        case ..<12: return ("Mittel", .yellow)
        default: return ("Kritisch", .red)
        }
    }

    private func cleanRateStatus(for percent: Double) -> (text: String, color: Color) {
        switch percent {
        case 70...: return ("Sehr gut", .green)
        case 35..<70: return ("Mittel", .yellow)
        default: return ("Niedrig", .red)
        }
    }

    private func ratioStatus(for ratio: Double) -> (text: String, color: Color) {
        switch ratio {
        case 0.8...1.2: return ("Ausgeglichen", .green)
        case 0.6..<0.8, 1.2...1.6: return ("Auffaellig", .yellow)
        default: return ("Deutlich", .red)
        }
    }

    private func streakStatus(for streak: Int) -> (text: String, color: Color) {
        switch streak {
        case 6...: return ("Stark", .green)
        case 3..<6: return ("Positiv", .yellow)
        default: return ("Kurz", .red)
        }
    }

    private func severeStatus(for percent: Double) -> (text: String, color: Color) {
        switch percent {
        case ..<15: return ("Gut", .green)
        case ..<35: return ("Mittel", .yellow)
        default: return ("Kritisch", .red)
        }
    }

    var body: some View {
        let errorsStatus = errorsStatus(for: errorsPer100Km)
        let cleanStatus = cleanRateStatus(for: cleanDriveRatePercent)
        let ratioStatus = ratioStatus(for: brakeToAccelerationRatio)
        let streakStatus = streakStatus(for: improvementStreak)
        let severeStatus = severeStatus(for: severeEventRatioPercent)

        return VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.accentColor)
                Text("Reflexion")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }

            Divider().background(Color.white.opacity(0.15))

            VStack(spacing: 14) {
                ReflectionMetricRow(
                    title: "Fehler pro 100 km",
                    value: String(format: "%.1f / 100 km", errorsPer100Km),
                    statusText: errorsStatus.text,
                    statusColor: errorsStatus.color,
                    interpretation: errorsPer100KmInterpretation
                )

                Divider().background(Color.white.opacity(0.15))

                ReflectionMetricRow(
                    title: "Fehlerfreie Fahrtenquote",
                    value: String(format: "%.0f%%", cleanDriveRatePercent),
                    statusText: cleanStatus.text,
                    statusColor: cleanStatus.color,
                    interpretation: cleanDriveRateInterpretation
                )

                Divider().background(Color.white.opacity(0.15))

                ReflectionMetricRow(
                    title: "Bremsen/Beschleunigen",
                    value: String(format: "%.2f : 1", brakeToAccelerationRatio),
                    statusText: ratioStatus.text,
                    statusColor: ratioStatus.color,
                    interpretation: brakeToAccelerationInterpretation
                )

                Divider().background(Color.white.opacity(0.15))

                ReflectionMetricRow(
                    title: "Verbesserungsserie",
                    value: "\(improvementStreak) Fahrten",
                    statusText: streakStatus.text,
                    statusColor: streakStatus.color,
                    interpretation: improvementStreakInterpretation
                )

                Divider().background(Color.white.opacity(0.15))

                ReflectionMetricRow(
                    title: "Schweregrad-Quote",
                    value: String(format: "%.0f%%", severeEventRatioPercent),
                    statusText: severeStatus.text,
                    statusColor: severeStatus.color,
                    interpretation: severeEventRatioInterpretation
                )
            }
        }
        .padding()
        .appSectionCardStyle(cornerRadius: 16)
    }
}

private struct ReflectionMetricRow: View {
    let title: String
    let value: String
    let statusText: String
    let statusColor: Color
    let interpretation: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text(value)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)

                    Text(statusText)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.14))
                        .clipShape(Capsule())
                }
            }

            Text(interpretation)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color.cardSecondary.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct MiniMetricBadge: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.textSecondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.cardSecondary.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct StatisticsEmptyStateCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)

            Text(title)
                .font(.headline)
                .foregroundColor(.textPrimary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .appSectionCardStyle(cornerRadius: 16)
    }
}

struct StatisticsInsufficientTrendDataCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .foregroundColor(.textSecondary)
                Text("Zu wenig Verlaufsdaten")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }

            Text("Für Verlaufsgrafiken werden mehr Fahrten im gewählten Zeitraum benötigt.")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .appSectionCardStyle(cornerRadius: 16)
    }
}

struct StatisticsScoreProgressCard: View {
    let scoreOverTime: [TimeSeriesDataPoint]
    let trend: TrendDirection
    let hasEnoughData: Bool
    let trendMinimumHint: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.yellow)
                Text("Score-Verlauf")
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: trend.icon)
                        .foregroundColor(trend.color)
                        .font(.caption)
                    Text(trend.text)
                        .font(.caption)
                        .foregroundColor(trend.color)
                }
            }

            Divider().background(Color.white.opacity(0.15))

            if hasEnoughData {
                Chart {
                    ForEach(scoreOverTime) { dataPoint in
                        LineMark(
                            x: .value("Datum", dataPoint.date),
                            y: .value("Score", dataPoint.value)
                        )
                        .foregroundStyle(Color.yellow.gradient)
                        .interpolationMethod(.catmullRom)

                        AreaMark(
                            x: .value("Datum", dataPoint.date),
                            y: .value("Score", dataPoint.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.3), Color.yellow.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 150)
                .chartYScale(domain: 0...120)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                .chartYAxis {
                    AxisMarks {
                        AxisValueLabel()
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            } else {
                TrendDataHintView(text: "Zu wenig Daten für Score-Verlauf (\(trendMinimumHint))")
            }

            Text("Zeigt deinen durchschnittlichen Score pro Tag")
                .font(.caption2)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .appSectionCardStyle(cornerRadius: 16)
    }
}

struct StatisticsErrorProgressCard: View {
    let errorsOverTime: [TimeSeriesDataPoint]
    let trend: TrendDirection
    let hasEnoughData: Bool
    let trendMinimumHint: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.line.downtrend.xyaxis")
                    .foregroundColor(.red)
                Text("Fehler-Verlauf")
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: trend.icon)
                        .foregroundColor(trend.color)
                        .font(.caption)
                    Text(trend.text)
                        .font(.caption)
                        .foregroundColor(trend.color)
                }
            }

            Divider().background(Color.white.opacity(0.15))

            if hasEnoughData {
                Chart {
                    ForEach(errorsOverTime) { dataPoint in
                        LineMark(
                            x: .value("Datum", dataPoint.date),
                            y: .value("Fehler", dataPoint.value)
                        )
                        .foregroundStyle(Color.red.gradient)
                        .interpolationMethod(.catmullRom)

                        AreaMark(
                            x: .value("Datum", dataPoint.date),
                            y: .value("Fehler", dataPoint.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.red.opacity(0.3), Color.red.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 150)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                .chartYAxis {
                    AxisMarks {
                        AxisValueLabel()
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            } else {
                TrendDataHintView(text: "Zu wenig Daten für Fehler-Verlauf (\(trendMinimumHint))")
            }

            Text("Zeigt die Anzahl deiner Fehler pro Tag")
                .font(.caption2)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .appSectionCardStyle(cornerRadius: 16)
    }
}

struct StatisticsErrorBreakdownProgressCard: View {
    let errorBreakdownOverTime: [ErrorBreakdownDataPoint]
    let hasEnoughData: Bool
    let trendMinimumHint: String

    private struct SeriesPoint: Identifiable {
        enum SeriesType: String {
            case brakes = "Bremsen"
            case accelerations = "Beschleunigungen"
            case turns = "Lenkungen"

            var color: Color {
                switch self {
                case .brakes: return .red
                case .accelerations: return .orange
                case .turns: return .yellow
                }
            }

            var dashPattern: [CGFloat] {
                switch self {
                case .brakes: return []
                case .accelerations: return [5, 5]
                case .turns: return [2, 2]
                }
            }
        }

        let id = UUID()
        let date: Date
        let value: Int
        let type: SeriesType
    }

    private var seriesPoints: [SeriesPoint] {
        errorBreakdownOverTime.flatMap { dataPoint in
            [
                SeriesPoint(date: dataPoint.date, value: dataPoint.brakes, type: .brakes),
                SeriesPoint(date: dataPoint.date, value: dataPoint.accelerations, type: .accelerations),
                SeriesPoint(date: dataPoint.date, value: dataPoint.turns, type: .turns)
            ]
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .foregroundColor(.accentColor)
                Text("Fehlertypen-Verlauf")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }

            Divider().background(Color.white.opacity(0.15))

            if hasEnoughData {
                Chart {
                    ForEach(seriesPoints) { dataPoint in
                        LineMark(
                            x: .value("Datum", dataPoint.date),
                            y: .value("Anzahl", dataPoint.value),
                            series: .value("Typ", dataPoint.type.rawValue)
                        )
                        .foregroundStyle(by: .value("Typ", dataPoint.type.rawValue))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: dataPoint.type.dashPattern))
                    }
                }
                .frame(height: 150)
                .chartLegend(.hidden)
                .chartForegroundStyleScale([
                    SeriesPoint.SeriesType.brakes.rawValue: SeriesPoint.SeriesType.brakes.color,
                    SeriesPoint.SeriesType.accelerations.rawValue: SeriesPoint.SeriesType.accelerations.color,
                    SeriesPoint.SeriesType.turns.rawValue: SeriesPoint.SeriesType.turns.color
                ])
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                .chartYAxis {
                    AxisMarks {
                        AxisValueLabel()
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            } else {
                TrendDataHintView(text: "Zu wenig Daten für Fehlertypen-Verlauf (\(trendMinimumHint))")
            }

            HStack(spacing: 14) {
                LegendBadgeView(color: .red, title: "Bremsen")
                LegendBadgeView(color: .orange, title: "Beschleunigungen")
                LegendBadgeView(color: .yellow, title: "Lenkungen")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .appSectionCardStyle(cornerRadius: 16)
    }
}

struct LegendBadgeView: View {
    let color: Color
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }
}

struct TrendDataHintView: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle")
                .foregroundColor(.textSecondary)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
        .padding(.horizontal, 4)
    }
}

struct StatisticItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ErrorCategoryRow: View {
    let icon: String
    let title: String
    let hardCount: Int
    let veryHardCount: Int
    let color: Color
    var isTappable: Bool = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.textPrimary)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if veryHardCount > 0 {
                    HStack(spacing: 4) {
                        Text("Sehr stark:")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                        Text("\(veryHardCount)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(color)
                    }
                }
                HStack(spacing: 4) {
                    Text("Stark:")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                    Text("\(hardCount)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(color.opacity(0.7))
                }
            }
        }
        .padding(.vertical, 4)
    }
}
