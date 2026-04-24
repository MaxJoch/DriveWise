import SwiftUI
import CoreLocation
import UIKit
import UserNotifications

struct AppSettingsView: View {
    private let locationManager = CLLocationManager()
    @EnvironmentObject private var driveManager: DriveManager
    @State private var notificationsEnabled: Bool = AppSettingDefaults.notificationsEnabled
    @State private var acousticWarningEnabled: Bool = AppSettingDefaults.acousticWarningEnabled
    @State private var keepDisplayAwakeWhileTracking: Bool = AppSettingDefaults.keepDisplayAwakeWhileTracking
    @State private var autoTrackDrives: Bool = AppSettingDefaults.autoTrackDrives
    @State private var cloudSyncEnabled: Bool = AppSettingDefaults.cloudSyncEnabled
    @State private var routeCloudSyncEnabled: Bool = AppSettingDefaults.routeCloudSyncEnabled
    @State private var authorizationStatus: CLAuthorizationStatus = .notDetermined

    var body: some View {
        ZStack {
            Color.bgFigma.ignoresSafeArea()

            List {
                Section("Tracking bei gesperrtem Bildschirm") {
                    HStack {
                        Text("Standortberechtigung")
                        Spacer()
                        Text(locationAuthorizationText)
                            .foregroundStyle(locationAuthorizationColor)
                    }

                    Text("Für zuverlässiges Hintergrund-Tracking sollte in iOS für DriveWise \"Immer\" aktiviert sein.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button("iPhone Einstellungen öffnen") {
                        openAppSettings()
                    }
                }

                Section("Benachrichtigungen") {
                    Toggle("Benachrichtigungen aktivieren", isOn: notificationsBinding)

                    Text("Enthält Achievement-Hinweise, gelegentliches Fahrt-Feedback und den Wochenrückblick.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Fahrfehler-Feedback") {
                    Toggle("Akustischer Warnton bei Fehlern", isOn: acousticWarningBinding)

                    Text("Bei aktivierter Option gibt es bei Fahrfehlern einen Signalton. Im Stummmodus wird stattdessen vibriert.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Display") {
                    Toggle("Display beim Tracking anlassen", isOn: keepDisplayAwakeBinding)

                    Text("Verhindert das automatische Sperren während einer Fahrt. Hinweis: höherer Akkuverbrauch.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Automatisierung") {
                    Toggle("Fahrten automatisch erkennen", isOn: autoTrackBinding)

                    Text("Startet Tracking automatisch, wenn eine Fahrt erkannt wird, und beendet es bei längerem Stillstand. Du bekommst dazu eine Benachrichtigung.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Section("Cloud-Synchronisierung") {
                    Toggle("Daten in der Cloud speichern", isOn: cloudSyncBinding)
                    Toggle("Routen in die Cloud speichern", isOn: routeCloudSyncBinding)

                    Text("Synchronisiert deine Fahrten und Einstellungen mit der Cloud. Routen kannst du separat ein- oder ausschalten.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("Deaktivieren von Cloud-Sync speichert Daten nur lokal. Der Routen-Schalter steuert, ob Fahrtrouten mit übertragen werden.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.bgFigma)
            .listStyle(.insetGrouped)
            .environment(\.defaultMinListHeaderHeight, 14)
            .environment(\.defaultMinListRowHeight, 38)
        }
        .navigationTitle("Einstellungen")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            authorizationStatus = locationManager.authorizationStatus
            notificationsEnabled = AppUserDefaults.bool(for: AppSettingKeys.notificationsEnabled, default: AppSettingDefaults.notificationsEnabled)
            acousticWarningEnabled = AppUserDefaults.bool(for: AppSettingKeys.acousticWarningEnabled, default: AppSettingDefaults.acousticWarningEnabled)
            keepDisplayAwakeWhileTracking = AppUserDefaults.bool(for: AppSettingKeys.keepDisplayAwakeWhileTracking, default: AppSettingDefaults.keepDisplayAwakeWhileTracking)
            autoTrackDrives = AppUserDefaults.bool(for: AppSettingKeys.autoTrackDrives, default: AppSettingDefaults.autoTrackDrives)
            cloudSyncEnabled = AppUserDefaults.bool(for: AppSettingKeys.cloudSyncEnabled, default: AppSettingDefaults.cloudSyncEnabled)
            routeCloudSyncEnabled = AppUserDefaults.bool(for: AppSettingKeys.routeCloudSyncEnabled, default: AppSettingDefaults.routeCloudSyncEnabled)
        }
        .onChange(of: notificationsEnabled) { _, enabled in
            guard enabled else { return }
            DriveNotificationService.shared.requestAuthorizationIfNeeded(force: true)
        }
    }

    private var locationAuthorizationText: String {
        switch authorizationStatus {
        case .authorizedAlways:
            return "Immer erlaubt"
        case .authorizedWhenInUse:
            return "Nur bei Nutzung"
        case .denied:
            return "Abgelehnt"
        case .restricted:
            return "Eingeschränkt"
        case .notDetermined:
            return "Nicht gesetzt"
        @unknown default:
            return "Unbekannt"
        }
    }

    private var locationAuthorizationColor: Color {
        switch authorizationStatus {
        case .authorizedAlways:
            return .green
        case .authorizedWhenInUse:
            return .yellow
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .gray
        @unknown default:
            return .gray
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private var notificationsBinding: Binding<Bool> {
        Binding(
            get: { notificationsEnabled },
            set: { newValue in
                notificationsEnabled = newValue
                AppUserDefaults.set(newValue, for: AppSettingKeys.notificationsEnabled)
                FirebaseSyncService.shared.schedulePushCurrentSettings(for: SessionUserContext.activeUserIdentifier)
            }
        )
    }

    private var acousticWarningBinding: Binding<Bool> {
        Binding(
            get: { acousticWarningEnabled },
            set: { newValue in
                acousticWarningEnabled = newValue
                AppUserDefaults.set(newValue, for: AppSettingKeys.acousticWarningEnabled)
                FirebaseSyncService.shared.schedulePushCurrentSettings(for: SessionUserContext.activeUserIdentifier)
            }
        )
    }

    private var keepDisplayAwakeBinding: Binding<Bool> {
        Binding(
            get: { keepDisplayAwakeWhileTracking },
            set: { newValue in
                keepDisplayAwakeWhileTracking = newValue
                AppUserDefaults.set(newValue, for: AppSettingKeys.keepDisplayAwakeWhileTracking)
                driveManager.refreshIdleTimerPolicy()
                FirebaseSyncService.shared.schedulePushCurrentSettings(for: SessionUserContext.activeUserIdentifier)
            }
        )
    }

    private var autoTrackBinding: Binding<Bool> {
        Binding(
            get: { autoTrackDrives },
            set: { newValue in
                autoTrackDrives = newValue
                AppUserDefaults.set(newValue, for: AppSettingKeys.autoTrackDrives)
                FirebaseSyncService.shared.schedulePushCurrentSettings(for: SessionUserContext.activeUserIdentifier)
            }
        )
    }
    
    var cloudSyncBinding: Binding<Bool> {
        Binding(
            get: { cloudSyncEnabled },
            set: { newValue in
                cloudSyncEnabled = newValue
                AppUserDefaults.set(newValue, for: AppSettingKeys.cloudSyncEnabled)
                // Only push settings if cloud sync is now enabled
                if newValue {
                    FirebaseSyncService.shared.schedulePushCurrentSettings(for: SessionUserContext.activeUserIdentifier)
                    driveManager.synchronizeFromFirebaseAfterEnablingCloudSync()
                }
            }
        )
    }

    private var routeCloudSyncBinding: Binding<Bool> {
        Binding(
            get: { routeCloudSyncEnabled },
            set: { newValue in
                routeCloudSyncEnabled = newValue
                AppUserDefaults.set(newValue, for: AppSettingKeys.routeCloudSyncEnabled)
                FirebaseSyncService.shared.schedulePushCurrentSettings(for: SessionUserContext.activeUserIdentifier)
            }
        )
    }
}

#Preview {
    NavigationStack {
        AppSettingsView()
    }
}