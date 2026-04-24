import SwiftUI
import CoreData

struct StatisticsView: View {
    @EnvironmentObject var driveManager: DriveManager
    @StateObject private var viewModel: StatisticsViewModel
    @State private var pullOffset: CGFloat = 0
    private let progressCardsHeight: CGFloat = 300
    
    init() {
        // Temporäres ViewModel für Preview
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(context: context))
    }
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(context: context))
    }
    
    var body: some View {
        ZStack {
            Color.bgFigma.ignoresSafeArea()

            VStack(spacing: 0) {
                // Pull-to-Refresh indicator
                if driveManager.isSyncing || pullOffset > 0 {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                            .opacity(pullOffset > 0 || driveManager.isSyncing ? 1 : 0)
                        Text(pullOffset > 50 ? "Loslassen zum Aktualisieren..." : "Nach unten ziehen...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .opacity(pullOffset > 0 ? 1 : 0)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .frame(height: max(0, pullOffset))
                    .clipped()
                }
                
                ScrollView {
                    VStack(spacing: AppLayout.pageSpacing) {
                        Text("Statistiken")
                            .appPageTitleStyle()
                            .padding(.top)

                        // Sync Error Banner
                        SyncErrorBanner()
                            .padding(.horizontal)

                        // Zeitraum Picker
                        periodPickerView
                        
                        if hasEnoughDrivesForSelectedPeriod {
                            baseInsightsSection
                        safetySection
                        trendSection
                        reflectionMetricsCard
                    } else {
                        emptyStateView
                    }

                    HStack {
                        Spacer()
                        DrivingCriteriaInfoView()
                        Spacer()
                    }
                    .padding(.vertical, 12)

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, AppLayout.horizontalPadding)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 0 && pullOffset == 0 {
                            pullOffset = min(value.translation.height, 100)
                        }
                    }
                    .onEnded { value in
                        if pullOffset > 50 && !driveManager.isSyncing {
                            withAnimation {
                                driveManager.synchronizeFromPullToRefresh()
                            }
                        }
                        withAnimation(.easeOut) {
                            pullOffset = 0
                        }
                    }
            )
            }
        }
        .onChange(of: viewModel.selectedPeriod) { _, _ in
            viewModel.loadStatistics()
        }
        .onChange(of: driveManager.isSyncing) { _, syncing in
            if !syncing {
                withAnimation {
                    pullOffset = 0
                }
                viewModel.refreshStatistics()
            }
        }
    }

    private var baseInsightsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Fahrleistung")
                .font(.headline)
                .foregroundColor(.textSecondary)

            overviewCard
            scoreCard
            speedCard
            distanceByWeekdayCard
        }
    }

    private var safetySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Sicherheit")
                .font(.headline)
                .foregroundColor(.textSecondary)

            errorOverviewCard
            errorDetailsCard
        }
    }

    @ViewBuilder
    private var trendSection: some View {
        if !isDayPeriod {
            VStack(alignment: .leading, spacing: 14) {
                Text("Verlauf")
                    .font(.headline)
                    .foregroundColor(.textSecondary)

                if hasProgressCharts {
                    TabView {
                        if !viewModel.statistics.scoreOverTime.isEmpty {
                            scoreProgressCard
                                .padding(.horizontal, 6)
                        }

                        if !viewModel.statistics.errorsOverTime.isEmpty {
                            errorProgressCard
                                .padding(.horizontal, 6)
                        }

                        if !viewModel.statistics.errorBreakdownOverTime.isEmpty {
                            errorBreakdownCard
                                .padding(.horizontal, 6)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    .frame(height: progressCardsHeight)
                } else {
                    insufficientTrendDataCard
                }
            }
        }
    }

    private var hasProgressCharts: Bool {
        !viewModel.statistics.scoreOverTime.isEmpty ||
        !viewModel.statistics.errorsOverTime.isEmpty ||
        !viewModel.statistics.errorBreakdownOverTime.isEmpty
    }

    private var isDayPeriod: Bool {
        viewModel.selectedPeriod == .day
    }

    private var hasEnoughDrivesForSelectedPeriod: Bool {
        return viewModel.statistics.totalDrives > 0
    }

    private var hasEnoughScoreTrendData: Bool {
        if viewModel.selectedPeriod == .day {
            return viewModel.statistics.totalDrives >= 2
        }
        return viewModel.statistics.scoreOverTime.count >= 2
    }

    private var hasEnoughErrorTrendData: Bool {
        if viewModel.selectedPeriod == .day {
            return viewModel.statistics.totalDrives >= 2
        }
        return viewModel.statistics.errorsOverTime.count >= 2
    }

    private var hasEnoughErrorBreakdownTrendData: Bool {
        if viewModel.selectedPeriod == .day {
            return viewModel.statistics.totalDrives >= 2
        }
        return viewModel.statistics.errorBreakdownOverTime.count >= 2
    }

    private var trendMinimumHint: String {
        if viewModel.selectedPeriod == .day {
            return "mind. 2 Fahrten benötigt"
        }
        return "mind. 2 Tage benötigt"
    }

    private var emptyStateTitle: String {
        if viewModel.selectedPeriod == .day {
            return "Heute noch keine Daten"
        }
        return "Keine Daten verfügbar"
    }

    private var emptyStateSubtitle: String {
        if viewModel.selectedPeriod == .day {
            return "Für den Zeitraum Tag sind noch nicht genug Fahrten vorhanden. Starte eine Fahrt, dann werden hier Werte angezeigt."
        }
        return "Starte eine Fahrt, um Statistiken zu sehen"
    }

    // MARK: - Period Picker
    private var periodPickerView: some View {
        Picker("Zeitraum", selection: $viewModel.selectedPeriod) {
            ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                Text(period.rawValue)
                    .tag(period)
            }
        }
        .pickerStyle(.segmented)
        .tint(.white)
        .environment(\.colorScheme, .dark)
        .padding(6)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    // MARK: - Overview Card
    private var overviewCard: some View {
        StatisticsOverviewCard(
            totalDrives: viewModel.statistics.totalDrives,
            totalDistance: viewModel.statistics.totalDistance,
            totalDurationText: viewModel.formattedDuration(viewModel.statistics.totalDuration),
            averageDistance: viewModel.statistics.averageDistance
        )
    }
    
    // MARK: - Score Card
    private var scoreCard: some View {
        StatisticsScoreCard(averageScore: viewModel.statistics.averageScore)
    }
    
    // MARK: - Speed Card
    private var speedCard: some View {
        StatisticsSpeedCard(
            averageSpeed: viewModel.statistics.averageSpeed,
            maxSpeed: viewModel.statistics.maxSpeed,
            speedingKm: viewModel.statistics.speedingKm
        )
    }
    
    // MARK: - Distance by Weekday Card
    private var distanceByWeekdayCard: some View {
        StatisticsDistanceByWeekdayCard(
            distanceByWeekday: viewModel.statistics.distanceByWeekday,
            weekdayName: viewModel.weekdayName(for:),
            selectedPeriod: viewModel.selectedPeriod
        )
    }
    
    // MARK: - Error Overview Card
    private var errorOverviewCard: some View {
        StatisticsErrorOverviewCard(
            totalErrors: viewModel.statistics.totalErrors,
            totalDrives: viewModel.statistics.totalDrives
        )
    }
    
    // MARK: - Error Details Card
    private var errorDetailsCard: some View {
        StatisticsErrorDetailsCard(
            hardBrakes: viewModel.statistics.hardBrakes,
            veryHardBrakes: viewModel.statistics.veryHardBrakes,
            hardAccelerations: viewModel.statistics.hardAccelerations,
            veryHardAccelerations: viewModel.statistics.veryHardAccelerations,
            sharpTurns: viewModel.statistics.sharpTurns,
            verySharpTurns: viewModel.statistics.verySharpTurns,
            selectedPeriod: viewModel.selectedPeriod,
            errorBreakdownOverTime: viewModel.statistics.errorBreakdownOverTime,
            allTimeErrorBreakdownOverTime: viewModel.allTimeErrorBreakdownOverTime
        )
    }

    private var reflectionMetricsCard: some View {
        StatisticsReflectionMetricsCard(
            errorsPer100Km: viewModel.statistics.errorsPer100Km,
            errorsPer100KmInterpretation: viewModel.errorsPer100KmInterpretation(viewModel.statistics.errorsPer100Km),
            cleanDriveRatePercent: viewModel.statistics.cleanDriveRatePercent,
            cleanDriveRateInterpretation: viewModel.cleanDriveRateInterpretation(viewModel.statistics.cleanDriveRatePercent),
            brakeToAccelerationRatio: viewModel.statistics.brakeToAccelerationRatio,
            brakeToAccelerationInterpretation: viewModel.brakeToAccelerationRatioInterpretation(viewModel.statistics.brakeToAccelerationRatio),
            improvementStreak: viewModel.statistics.improvementStreak,
            improvementStreakInterpretation: viewModel.improvementStreakInterpretation(viewModel.statistics.improvementStreak),
            severeEventRatioPercent: viewModel.statistics.severeEventRatioPercent,
            severeEventRatioInterpretation: viewModel.severeEventRatioInterpretation(viewModel.statistics.severeEventRatioPercent)
        )
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        StatisticsEmptyStateCard(title: emptyStateTitle, subtitle: emptyStateSubtitle)
    }

    private var insufficientTrendDataCard: some View {
        StatisticsInsufficientTrendDataCard()
    }
    
    // MARK: - Score Progress Card
    private var scoreProgressCard: some View {
        StatisticsScoreProgressCard(
            scoreOverTime: viewModel.statistics.scoreOverTime,
            trend: viewModel.statistics.scoreTrend,
            hasEnoughData: hasEnoughScoreTrendData,
            trendMinimumHint: trendMinimumHint
        )
    }
    
    // MARK: - Error Progress Card
    private var errorProgressCard: some View {
        StatisticsErrorProgressCard(
            errorsOverTime: viewModel.statistics.errorsOverTime,
            trend: viewModel.statistics.errorTrend,
            hasEnoughData: hasEnoughErrorTrendData,
            trendMinimumHint: trendMinimumHint
        )
    }
    
    // MARK: - Error Breakdown Card
    private var errorBreakdownCard: some View {
        StatisticsErrorBreakdownProgressCard(
            errorBreakdownOverTime: viewModel.statistics.errorBreakdownOverTime,
            hasEnoughData: hasEnoughErrorBreakdownTrendData,
            trendMinimumHint: trendMinimumHint
        )
    }
}

#Preview {
    StatisticsView()
}
