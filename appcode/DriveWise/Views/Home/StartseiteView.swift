import SwiftUI
import UIKit

struct StartseiteView: View {
    @EnvironmentObject var manager: DriveManager

    private let statusPersistenceSeconds: TimeInterval = 1.0

    enum TrackingStatus {
        case good
        case warning
        case critical

        var color: Color {
            switch self {
            case .good:
                return Color(hex: "259833").opacity(0.5)
            case .warning:
                return Color(hex: "D8CC87")
            case .critical:
                return Color(hex: "FF4747")
            }
        }

        var title: String {
            switch self {
            case .good:
                return "Alles gut"
            case .warning:
                return "Achtung: Fahrfehler"
            case .critical:
                return "Warnung: starker Fahrfehler"
            }
        }

        var subtitle: String {
            switch self {
            case .good:
                return "Aktuell ruhiges Fahrverhalten"
            case .warning:
                return "Leichter bis mittlerer Fehler erkannt"
            case .critical:
                return "Sehr starker Fehler erkannt"
            }
        }
    }

    var body: some View {
        ZStack {
            Color.bgFigma.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppLayout.pageSpacing) {
                    // title
                    VStack(spacing: 2) {
                        Text("Drive Wise")
                            .appPageTitleStyle()
                    }
                    .padding(.top)

                    // DEBUG: Error breakdown by type - während Fahrt statt Score
                    if manager.isDriving {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Fehlertypen")
                                    .font(.headline)
                                    .foregroundColor(.textPrimary)
                                Spacer()
                            }

                            HStack(spacing: 12) {
                                VStack(spacing: 4) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "bolt.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                        Text("Beschleu.")
                                            .font(.caption)
                                            .foregroundColor(.textSecondary)
                                    }
                                    Text("\(manager.hardAccelCount + manager.veryHardAccelCount)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.textPrimary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .background(Color.yellow.opacity(0.1))
                                .cornerRadius(8)

                                VStack(spacing: 4) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "hand.raised.fill")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                        Text("Bremsen")
                                            .font(.caption)
                                            .foregroundColor(.textSecondary)
                                    }
                                    Text("\(manager.hardBrakeCount + manager.veryHardBrakeCount)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.textPrimary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)

                                VStack(spacing: 4) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .foregroundColor(.orange)
                                            .font(.caption)
                                        Text("Kurven")
                                            .font(.caption)
                                            .foregroundColor(.textSecondary)
                                    }
                                    Text("\(manager.sharpTurnCount + manager.verySharpTurnCount)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.textPrimary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color.cardSecondary)
                        .cornerRadius(14)
                        .padding(.horizontal, AppLayout.horizontalPadding)

                    } else {
                        // Score card - nur wenn nicht fahrend
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Mein DriveWise Score")
                                .font(.headline)
                                .foregroundColor(.textPrimary)

                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.cardSecondary)
                                    .frame(height: 172)

                                VStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .trim(from: scoreArcStart, to: scoreArcEnd)
                                            .stroke(Color.progressTrack, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                            .frame(width: 125, height: 150)
                                            .rotationEffect(.degrees(90))

                                        Circle()
                                            .trim(from: scoreArcStart, to: scoreArcStart + scoreProgress * scoreArcLength)
                                            .stroke(scoreColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                            .frame(width: 125, height: 150)
                                            .rotationEffect(.degrees(90))

                                        VStack(spacing: 0) {
                                            Text("\(manager.overallScore)")
                                                .font(.system(size: 34, weight: .bold))
                                                .foregroundColor(.textPrimary)
                                        }
                                    }
                                    .padding(.top, 10)

                                    HStack {
                                        Text("0")
                                            .font(.default)
                                            .fontWeight(.medium)
                                            .foregroundColor(.textSecondary)
                                        Spacer()
                                        Text("120")
                                            .font(.default)
                                            .fontWeight(.medium)
                                            .foregroundColor(.textSecondary)
                                    }
                                    .frame(width: 124)
                                    .offset(y: -16)
                                }
                            }
                        }
                        .padding(.horizontal, AppLayout.horizontalPadding)
                    }

                    if manager.isDriving {
                        GeometryReader { geometry in
                            let spacing: CGFloat = 10
                            let totalWidth = geometry.size.width
                            let calibrateWidth = max(84, min(130, (totalWidth - spacing) * 0.25))
                            let stopWidth = max(0, (totalWidth - spacing) - calibrateWidth)

                            HStack(spacing: spacing) {
                                Button(action: {
                                    manager.stopDrive()
                                }) {
                                    HStack(spacing: 12) {
                                        Text("Fahrt beenden")
                                            .font(.headline)
                                    }
                                    .appPrimaryButtonStyle()
                                }
                                .frame(width: stopWidth)
                                .frame(minHeight: 56, maxHeight: 56)

                                Button(action: {
                                    manager.recalibrateSensors()
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "gyroscope")
                                            .font(.subheadline)
                                        Text(manager.isCalibratingSensors ? "Kalibriere..." : "Kalibrieren")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 56, maxHeight: 56)
                                    .background(Color.cardSecondary)
                                    .foregroundColor(.textPrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                                .frame(width: calibrateWidth)
                                .frame(minHeight: 56, maxHeight: 56)
                                .disabled(manager.isCalibratingSensors)
                                .opacity(manager.isCalibratingSensors ? 0.7 : 1)
                            }
                        }
                        .frame(height: 56)
                        .padding(.horizontal, AppLayout.horizontalPadding)
                    } else {
                        Button(action: {
                            manager.startDrive()
                        }) {
                            HStack(spacing: 12) {
                                Text("Fahrt tracken")
                                    .font(.headline)
                            }
                            .appPrimaryButtonStyle()
                            .padding(.horizontal, AppLayout.horizontalPadding)
                        }
                    }

                    // Current drive summary card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Aktuelle Fahrt")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            Spacer()
                        }

                        HStack(spacing: 16) {
                            HStack { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red); Text("Fehler: \(manager.errorCount)").foregroundColor(.textSecondary) }
                            Spacer()
                            HStack { Image(systemName: "location.fill").foregroundColor(.textPrimary); Text(String(format: "%.2f km", manager.distanceKm)).foregroundColor(.textSecondary) }
                            Spacer()
                            HStack { Image(systemName: "clock").foregroundColor(.textPrimary); Text(timeString(seconds: manager.elapsedSeconds)).foregroundColor(.textSecondary) }
                        }
                        .font(.caption)
                    }
                    .padding()
                    .background(Color.cardSecondary)
                    .cornerRadius(14)
                    .padding(.horizontal, AppLayout.horizontalPadding)

                    if manager.isDriving {
                        TabView {
                            liveStatusCard

                            gForceCard
                        }
                        .tabViewStyle(.page(indexDisplayMode: .automatic))
                        .frame(height: trackingSwipeCardsHeight)
                        .padding(.horizontal, AppLayout.horizontalPadding)
                    } else {
                        liveStatusCard
                            .frame(height: 220)
                            .padding(.horizontal, AppLayout.horizontalPadding)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 60)
            }
            .scrollDisabled(true)
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .overlay(alignment: .top) {
            if let error = manager.lastError {
                ErrorToastView(error: error)
                    .padding()
            }
        }
    }

    private var shouldShowMotionDebugDetails: Bool {
        AppUserDefaults.bool(for: AppSettingKeys.showMotionDebugDetails, default: AppSettingDefaults.showMotionDebugDetails)
    }

    private var trackingSwipeCardsHeight: CGFloat {
        shouldShowMotionDebugDetails ? 380 : 300
    }

    private var liveStatusCard: some View {
        TimelineView(.periodic(from: .now, by: 0.2)) { timeline in
            let status = liveTrackingStatus(at: timeline.date)

            VStack(alignment: .leading, spacing: 8) {
                Text("Status")
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                RoundedRectangle(cornerRadius: 12)
                    .fill(status.color)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        VStack(spacing: 8) {
                            Text(status.title)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text(status.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.92))
                        }
                    )
            }
            .padding()
            .background(Color.cardSecondary)
            .cornerRadius(14)
            .padding(.horizontal, 6)
        }
    }

    private var gForceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("G-Kräfte")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                Spacer()
            }

            if shouldShowMotionDebugDetails {
                Text(String(format: "Forward-Achse: x %.2f  y %.2f  z %.2f", manager.currentForwardAxis.x, manager.currentForwardAxis.y, manager.currentForwardAxis.z))
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                let snapshot = manager.motionDebugSnapshot
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text("Algorithmus")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                        Text(snapshot.decision.uppercased())
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(decisionColor(snapshot.decision).opacity(0.18))
                            .foregroundColor(decisionColor(snapshot.decision))
                            .clipShape(Capsule())

                        if snapshot.isCalibrating {
                            Text("Kalibriert")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }

                    Text(String(format: "Turn-Evidenz %.2f | Long-Evidenz %.2f", snapshot.turnEvidence, snapshot.longitudinalEvidence))
                        .font(.caption2)
                        .foregroundColor(.textSecondary)

                    Text(String(format: "A %.2f  B %.2f  yaw %.2f rad/s", snapshot.accelEvidence, snapshot.brakeEvidence, snapshot.yawRate))
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }
                .padding(8)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(8)
            }

            VStack(spacing: 0) {
                VStack(spacing: 2) {
                    Text("↑")
                        .font(.system(size: 36))
                        .foregroundColor(manager.currentForwardAccelG < 0 ? .red : .textSecondary.opacity(0.3))
                    Text(String(format: "%.2f g", max(0, -manager.currentForwardAccelG)))
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)

                HStack(spacing: 0) {
                    VStack(spacing: 2) {
                        Text(String(format: "%.2f g", max(0, manager.currentLateralAccelG)))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                    }
                    .frame(maxWidth: .infinity)

                    ZStack {
                        Circle()
                            .stroke(Color.textSecondary.opacity(0.3), lineWidth: 2)
                            .frame(width: 60, height: 60)

                        Circle()
                            .fill(manager.liveErrorSeverity != nil ? Color.red : Color.blue)
                            .frame(width: 8, height: 8)
                            .offset(x: CGFloat(-manager.currentLateralAccelG * 25), y: CGFloat(manager.currentForwardAccelG * 25))
                    }

                    VStack(spacing: 2) {
                        Text(String(format: "%.2f g", max(0, -manager.currentLateralAccelG)))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 60)

                VStack(spacing: 2) {
                    Text(String(format: "%.2f g", max(0, manager.currentForwardAccelG)))
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    Text("↓")
                        .font(.system(size: 36))
                        .foregroundColor(manager.currentForwardAccelG > 0 ? .green : .textSecondary.opacity(0.3))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
            .frame(height: 160)

            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "speedometer")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Geschwindigkeit")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                        Text(String(format: "%.1f km/h", manager.currentSpeedKmh))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Max")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                    Text(String(format: "%.1f km/h", manager.maxSpeedKmh))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                }
            }
            .padding(8)
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.cardSecondary)
        .cornerRadius(14)
        .padding(.horizontal, 6)
    }

    private func timeString(seconds: Int) -> String {
        AppDateTimeFormatter.durationClock(TimeInterval(seconds))
    }

    private var scoreProgress: CGFloat {
        CGFloat(max(0, min(120, manager.overallScore))) / 120.0
    }

    private var scoreArcStart: CGFloat { 0.12 }
    private var scoreArcEnd: CGFloat { 0.88 }
    private var scoreArcLength: CGFloat { scoreArcEnd - scoreArcStart }

    private var scoreColor: Color {
        if manager.overallScore >= 100 {
            return .green
        } else if manager.overallScore >= 80 {
            return .yellow
        } else if manager.overallScore >= 60 {
            return .orange
        } else {
            return .red
        }
    }

    private func liveTrackingStatus(at now: Date) -> TrackingStatus {
        guard manager.isDriving else {
            return .good
        }

        if manager.liveErrorSeverity == .veryHard {
            return .critical
        }

        if manager.liveErrorSeverity == .hard {
            return .warning
        }

        if let eventDate = manager.lastMotionEventDate,
           let eventSeverity = manager.lastMotionEventSeverity,
           now.timeIntervalSince(eventDate) <= statusPersistenceSeconds {
            return eventSeverity == .veryHard ? .critical : .warning
        }

        return .good
    }

    private func decisionColor(_ decision: String) -> Color {
        switch decision {
        case "turn":
            return .orange
        case "acceleration":
            return .yellow
        case "brake":
            return .red
        case "calibrating":
            return .blue
        case "mixed-long":
            return .purple
        default:
            return .textSecondary
        }
    }
}

#Preview {
    StartseiteView().environmentObject(DriveManager())
}
