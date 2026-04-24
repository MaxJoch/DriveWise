//
//  DebugSettingsView.swift
//  DriveWise
//
//  Debug настройки для тестирования Schwellenwerte
//

import SwiftUI
import Combine

struct DebugSettingsView: View {
    @StateObject private var viewModel = DebugSettingsViewModel()
    @EnvironmentObject var driveManager: DriveManager
    @AppStorage(AppSettingKeys.autoTrackStartSpeedKmh) private var autoTrackStartSpeedKmh: Double = AppSettingDefaults.autoTrackStartSpeedKmh
    @AppStorage(AppSettingKeys.autoTrackStopSpeedKmh) private var autoTrackStopSpeedKmh: Double = AppSettingDefaults.autoTrackStopSpeedKmh
    @AppStorage(AppSettingKeys.autoTrackStartStableSeconds) private var autoTrackStartStableSeconds: Double = AppSettingDefaults.autoTrackStartStableSeconds
    @AppStorage(AppSettingKeys.autoTrackStopStableSeconds) private var autoTrackStopStableSeconds: Double = AppSettingDefaults.autoTrackStopStableSeconds
    @Environment(\.dismiss) var dismiss
    
    @State private var countdown: Int = 0
    @State private var timer: Timer?
    @State private var showMotionDebugDetails: Bool = AppUserDefaults.bool(for: AppSettingKeys.showMotionDebugDetails, default: AppSettingDefaults.showMotionDebugDetails)

    var body: some View {
        NavigationStack {
            List {
                Section("Algorithmus Test") {
                    Button(action: {
                        startTestCountdown()
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text(countdown > 0 ? "Test startet in \(countdown)s..." : "Algorithmus-Test starten")
                                    .fontWeight(.semibold)
                                Text("5s Vorlauf (Zeit zum Wechseln zur Startseite)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .disabled(countdown > 0 || !driveManager.isDriving)
                    
                    if !driveManager.isDriving {
                        Text("⚠️ Bitte erst eine Fahrt auf der Startseite starten")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }

                Section("Startseite Debug-Anzeige") {
                    Toggle("Forward-Achse & Algorithmus einblenden", isOn: $showMotionDebugDetails)

                    Text("Wenn aktiviert, zeigt die G-Kräfte-Karte auf der Startseite zusätzliche Debugdetails zur Achse und Algorithmus-Entscheidung.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Beschleunigung & Bremsen") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Harte Beschleunigung")
                            Spacer()
                            Text(String(format: "%.1f m/s²", viewModel.settings.hardAccelThresholdMS2))
                                .foregroundStyle(.blue)
                                .monospacedDigit()
                        }
                        Slider(
                            value: $viewModel.settings.hardAccelThresholdMS2,
                            in: 1.0...6.0,
                            step: 0.1
                        )
                        .onChange(of: viewModel.settings.hardAccelThresholdMS2) { _, _ in
                            viewModel.saveSettings()
                        }
                        Text("Standard: 2.9 m/s²")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Sehr harte Beschleunigung")
                            Spacer()
                            Text(String(format: "%.1f m/s²", viewModel.settings.veryHardAccelThresholdMS2))
                                .foregroundStyle(.red)
                                .monospacedDigit()
                        }
                        Slider(
                            value: $viewModel.settings.veryHardAccelThresholdMS2,
                            in: 2.0...8.0,
                            step: 0.1
                        )
                        .onChange(of: viewModel.settings.veryHardAccelThresholdMS2) { _, _ in
                            viewModel.saveSettings()
                        }
                        Text("Standard: 3.5 m/s²")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Harte Bremsung")
                            Spacer()
                            Text(String(format: "%.1f m/s²", viewModel.settings.hardBrakeThresholdMS2))
                                .foregroundStyle(.red)
                                .monospacedDigit()
                        }
                        Slider(
                            value: $viewModel.settings.hardBrakeThresholdMS2,
                            in: 1.0...6.0,
                            step: 0.1
                        )
                        .onChange(of: viewModel.settings.hardBrakeThresholdMS2) { _, _ in
                            viewModel.saveSettings()
                        }
                        Text("Standard: 2.9 m/s²")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Sehr harte Bremsung")
                            Spacer()
                            Text(String(format: "%.1f m/s²", viewModel.settings.veryHardBrakeThresholdMS2))
                                .foregroundStyle(.red)
                                .monospacedDigit()
                        }
                        Slider(
                            value: $viewModel.settings.veryHardBrakeThresholdMS2,
                            in: 2.0...8.0,
                            step: 0.1
                        )
                        .onChange(of: viewModel.settings.veryHardBrakeThresholdMS2) { _, _ in
                            viewModel.saveSettings()
                        }
                        Text("Standard: 4.0 m/s²")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
                
                Section("Kurvenfahrt") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Scharfe Kurve (Drehrate)")
                            Spacer()
                            Text(String(format: "%.2f rad/s", viewModel.settings.sharpTurnYawRateThreshold))
                                .foregroundStyle(.orange)
                                .monospacedDigit()
                        }
                        Slider(
                            value: $viewModel.settings.sharpTurnYawRateThreshold,
                            in: 0.2...3.0,
                            step: 0.1
                        )
                        .onChange(of: viewModel.settings.sharpTurnYawRateThreshold) { _, _ in
                            viewModel.saveSettings()
                        }
                        Text("Standard: 1.3 rad/s")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Sehr scharfe Kurve (Drehrate)")
                            Spacer()
                            Text(String(format: "%.2f rad/s", viewModel.settings.verySharpTurnYawRateThreshold))
                                .foregroundStyle(.red)
                                .monospacedDigit()
                        }
                        Slider(
                            value: $viewModel.settings.verySharpTurnYawRateThreshold,
                            in: 1.0...5.0,
                            step: 0.1
                        )
                        .onChange(of: viewModel.settings.verySharpTurnYawRateThreshold) { _, _ in
                            viewModel.saveSettings()
                        }
                        Text("Standard: 2.0 rad/s")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Scharfe Kurve (Seitbeschleunigung)")
                            Spacer()
                            Text(String(format: "%.1f m/s²", viewModel.settings.sharpTurnLateralThresholdMS2))
                                .foregroundStyle(.orange)
                                .monospacedDigit()
                        }
                        Slider(
                            value: $viewModel.settings.sharpTurnLateralThresholdMS2,
                            in: 1.0...6.0,
                            step: 0.1
                        )
                        .onChange(of: viewModel.settings.sharpTurnLateralThresholdMS2) { _, _ in
                            viewModel.saveSettings()
                        }
                        Text("Standard: 2,7 m/s²")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
                
                Section("GPS & Filterung") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Speeding Schwelle")
                            Spacer()
                            Text(String(format: "%.0f km/h", viewModel.settings.speedingThresholdKmh))
                                .foregroundStyle(.red)
                                .monospacedDigit()
                        }
                        Slider(
                            value: $viewModel.settings.speedingThresholdKmh,
                            in: 100.0...150.0,
                            step: 1.0
                        )
                        .onChange(of: viewModel.settings.speedingThresholdKmh) { _, _ in
                            viewModel.saveSettings()
                        }
                        Text("Speeding oberhalb dieser Geschwindigkeit (Standard: 130 km/h)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Signal-Glättung (α)")
                            Spacer()
                            Text(String(format: "%.2f", viewModel.settings.signalSmoothingAlpha))
                                .foregroundStyle(.green)
                                .monospacedDigit()
                        }
                        Slider(
                            value: $viewModel.settings.signalSmoothingAlpha,
                            in: 0.05...0.6,
                            step: 0.01
                        )
                        .onChange(of: viewModel.settings.signalSmoothingAlpha) { _, _ in
                            viewModel.saveSettings()
                        }
                        Text("Niedriger = stärker geglättet (Standard: 0.20)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Min. Eventdauer")
                            Spacer()
                            Text(String(format: "%.2f s", viewModel.settings.minEventDurationSeconds))
                                .foregroundStyle(.purple)
                                .monospacedDigit()
                        }
                        Slider(
                            value: $viewModel.settings.minEventDurationSeconds,
                            in: 0.05...0.8,
                            step: 0.05
                        )
                        .onChange(of: viewModel.settings.minEventDurationSeconds) { _, _ in
                            viewModel.saveSettings()
                        }
                        Text("Kurze Peaks unterdrücken (Standard: 0.15s)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Hysterese-Release")
                            Spacer()
                            Text(String(format: "%.2f", viewModel.settings.hysteresisReleaseFactor))
                                .foregroundStyle(.purple)
                                .monospacedDigit()
                        }
                        Slider(
                            value: $viewModel.settings.hysteresisReleaseFactor,
                            in: 0.4...0.9,
                            step: 0.05
                        )
                        .onChange(of: viewModel.settings.hysteresisReleaseFactor) { _, _ in
                            viewModel.saveSettings()
                        }
                        Text("Abfallfaktor zum Beenden eines Manövers (Standard: 0.50)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Min. Geschwindigkeit")
                            Spacer()
                            Text(String(format: "%.0f km/h", viewModel.settings.minEventSpeedKmh))
                                .foregroundStyle(.orange)
                                .monospacedDigit()
                        }
                        Slider(
                            value: $viewModel.settings.minEventSpeedKmh,
                            in: 5.0...40.0,
                            step: 1.0
                        )
                        .onChange(of: viewModel.settings.minEventSpeedKmh) { _, _ in
                            viewModel.saveSettings()
                        }
                        Text("Unterhalb dieser Geschwindigkeit keine Fahrfehler (Standard: 10 km/h)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("GPS Blending (α)")
                            Spacer()
                            Text(String(format: "%.2f", viewModel.settings.gpsBlendAlpha))
                                .foregroundStyle(.green)
                                .monospacedDigit()
                        }
                        Slider(
                            value: $viewModel.settings.gpsBlendAlpha,
                            in: 0.0...1.0,
                            step: 0.05
                        )
                        .onChange(of: viewModel.settings.gpsBlendAlpha) { _, _ in
                            viewModel.saveSettings()
                        }
                        Text("0.25 = 25% GPS, 75% Motion (Standard)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Event Cooldown")
                            Spacer()
                            Text(String(format: "%.1f s", viewModel.settings.eventCooldownSeconds))
                                .foregroundStyle(.purple)
                                .monospacedDigit()
                        }
                        Slider(
                            value: $viewModel.settings.eventCooldownSeconds,
                            in: 0.1...3.0,
                            step: 0.1
                        )
                        .onChange(of: viewModel.settings.eventCooldownSeconds) { _, _ in
                            viewModel.saveSettings()
                        }
                        Text("Min. Zeit zwischen Events gleiches Typ (Standard: 1.5s)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }

                Section("Auto-Tracking") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Auto-Start Geschwindigkeit")
                            Spacer()
                            Text(String(format: "%.0f km/h", autoTrackStartSpeedKmh))
                                .foregroundStyle(.blue)
                                .monospacedDigit()
                        }
                        Slider(
                            value: $autoTrackStartSpeedKmh,
                            in: 8.0...35.0,
                            step: 1.0
                        )
                        Text("Ab dieser Geschwindigkeit startet Auto-Tracking (Standard: 15 km/h)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Auto-Start Dauer")
                            Spacer()
                            Text(String(format: "%.0f s", autoTrackStartStableSeconds))
                                .foregroundStyle(.blue)
                                .monospacedDigit()
                        }
                        Slider(
                            value: $autoTrackStartStableSeconds,
                            in: 5.0...30.0,
                            step: 1.0
                        )
                        Text("So lange muss die Geschwindigkeit stabil ueber der Startschwelle liegen (Standard: 12s)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Auto-Stopp Geschwindigkeit")
                            Spacer()
                            Text(String(format: "%.0f km/h", autoTrackStopSpeedKmh))
                                .foregroundStyle(.orange)
                                .monospacedDigit()
                        }
                        Slider(
                            value: $autoTrackStopSpeedKmh,
                            in: 0.0...10.0,
                            step: 1.0
                        )
                        Text("Unter dieser Geschwindigkeit wird auf Fahrtende geprueft (Standard: 4 km/h)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Auto-Stopp Dauer")
                            Spacer()
                            Text(String(format: "%.0f s", autoTrackStopStableSeconds))
                                .foregroundStyle(.orange)
                                .monospacedDigit()
                        }
                        Slider(
                            value: $autoTrackStopStableSeconds,
                            in: 30.0...300.0,
                            step: 5.0
                        )
                        Text("So lange muss die Geschwindigkeit unter der Stopp-Schwelle bleiben (Standard: 120s)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        viewModel.resetToDefaults()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Auf Standard zurücksetzen")
                        }
                    }
                }
            }
            .navigationTitle("⚙️ Debug Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: autoTrackStartSpeedKmh) { _, newValue in
                AppUserDefaults.set(newValue, for: AppSettingKeys.autoTrackStartSpeedKmh)
                FirebaseSyncService.shared.schedulePushCurrentSettings(for: SessionUserContext.activeUserIdentifier)
            }
            .onChange(of: showMotionDebugDetails) { _, newValue in
                AppUserDefaults.set(newValue, for: AppSettingKeys.showMotionDebugDetails)
            }
            .onChange(of: autoTrackStopSpeedKmh) { _, newValue in
                AppUserDefaults.set(newValue, for: AppSettingKeys.autoTrackStopSpeedKmh)
                FirebaseSyncService.shared.schedulePushCurrentSettings(for: SessionUserContext.activeUserIdentifier)
            }
            .onChange(of: autoTrackStartStableSeconds) { _, newValue in
                AppUserDefaults.set(newValue, for: AppSettingKeys.autoTrackStartStableSeconds)
                FirebaseSyncService.shared.schedulePushCurrentSettings(for: SessionUserContext.activeUserIdentifier)
            }
            .onChange(of: autoTrackStopStableSeconds) { _, newValue in
                AppUserDefaults.set(newValue, for: AppSettingKeys.autoTrackStopStableSeconds)
                FirebaseSyncService.shared.schedulePushCurrentSettings(for: SessionUserContext.activeUserIdentifier)
            }
        }
    }

    private func startTestCountdown() {
        countdown = 5
        driveManager.runAlgorithmTest()
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
}

@MainActor
class DebugSettingsViewModel: ObservableObject {
    @Published var settings: MotionSettings
    
    init() {
        self.settings = MotionSettings.load()
    }
    
    func saveSettings() {
        settings.save()
    }
    
    func resetToDefaults() {
        settings = .default
        settings.save()

        UserDefaults.standard.set(AppSettingDefaults.autoTrackStartSpeedKmh, forKey: AppSettingKeys.autoTrackStartSpeedKmh)
        UserDefaults.standard.set(AppSettingDefaults.autoTrackStopSpeedKmh, forKey: AppSettingKeys.autoTrackStopSpeedKmh)
        UserDefaults.standard.set(AppSettingDefaults.autoTrackStartStableSeconds, forKey: AppSettingKeys.autoTrackStartStableSeconds)
        UserDefaults.standard.set(AppSettingDefaults.autoTrackStopStableSeconds, forKey: AppSettingKeys.autoTrackStopStableSeconds)
        AppUserDefaults.set(AppSettingDefaults.autoTrackStartSpeedKmh, for: AppSettingKeys.autoTrackStartSpeedKmh)
        AppUserDefaults.set(AppSettingDefaults.autoTrackStopSpeedKmh, for: AppSettingKeys.autoTrackStopSpeedKmh)
        AppUserDefaults.set(AppSettingDefaults.autoTrackStartStableSeconds, for: AppSettingKeys.autoTrackStartStableSeconds)
        AppUserDefaults.set(AppSettingDefaults.autoTrackStopStableSeconds, for: AppSettingKeys.autoTrackStopStableSeconds)
        FirebaseSyncService.shared.schedulePushCurrentSettings(for: SessionUserContext.activeUserIdentifier)
    }
}

#Preview {
    DebugSettingsView()
}
