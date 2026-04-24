import ActivityKit
import WidgetKit
import SwiftUI
import UIKit

struct DriveTrackingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DriveTrackingActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Aktive Fahrt")
                        .font(.headline)
                    Spacer()
                    StatusPill(status: context.state.status)
                }

                HStack(spacing: 14) {
                    metricColumn(title: "KM", value: distanceKmString(context.state.distanceKm))
                    metricColumn(title: "Zeit", value: durationString(context.state.elapsedSeconds))
                    metricColumn(title: "Fehler", value: "\(context.state.errorCount)")
                }
            }
            .padding(14)
            .activityBackgroundTint(
                Color(
                    UIColor { trait in
                        trait.userInterfaceStyle == .dark
                            ? UIColor(red: 21/255, green: 51/255, blue: 76/255, alpha: 1)
                            : UIColor(red: 244/255, green: 248/255, blue: 253/255, alpha: 1)
                    }
                )
            )
            .activitySystemActionForegroundColor(.primary)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("KM")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(distanceKmString(context.state.distanceKm))
                            .font(.headline)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Fehler")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("\(context.state.errorCount)")
                            .font(.headline)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("Zeit: \(durationString(context.state.elapsedSeconds))")
                            .font(.subheadline)
                        Spacer()
                        StatusPill(status: context.state.status)
                    }
                }
            } compactLeading: {
                Text(statusEmoji(context.state.status))
            } compactTrailing: {
                Text(durationShort(context.state.elapsedSeconds))
                    .font(.caption2)
            } minimal: {
                Text(statusEmoji(context.state.status))
            }
        }
    }

    private func metricColumn(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func durationString(_ elapsedSeconds: Int) -> String {
        let totalMinutes = elapsedSeconds / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return String(format: "%02d:%02d", hours, minutes)
    }

    private func distanceKmString(_ distanceKm: Double) -> String {
        String(format: "%.1f", distanceKm)
    }

    private func durationShort(_ elapsedSeconds: Int) -> String {
        let totalMinutes = elapsedSeconds / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)h"
        }
        return "\(minutes)m"
    }

    private func statusEmoji(_ status: DriveTrackingActivityAttributes.ContentState.Status) -> String {
        switch status {
        case .good:
            return "🟢"
        case .warning:
            return "🟠"
        case .critical:
            return "🔴"
        }
    }
}

private struct StatusPill: View {
    let status: DriveTrackingActivityAttributes.ContentState.Status
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text(status.title)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(pillBackground, in: Capsule())
            .foregroundStyle(pillForeground)
    }

    private var color: Color {
        switch status {
        case .good:
            return .green
        case .warning:
            return .orange
        case .critical:
            return .red
        }
    }

    private var pillBackground: Color {
        colorScheme == .dark ? color.opacity(0.22) : color.opacity(0.28)
    }

    private var pillForeground: Color {
        colorScheme == .dark ? color : color.opacity(0.9)
    }
}
