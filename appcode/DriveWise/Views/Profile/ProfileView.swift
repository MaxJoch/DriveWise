import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthenticationViewModel
    @State private var activeSheet: Sheet? = nil
    @State private var showDebugSettings: Bool = false
    @State private var showAppSettings: Bool = false
    @State private var showAvatarPicker: Bool = false
    @AppStorage("AvatarStyleKey") private var selectedAvatarStyle: String = "auto"

    enum Sheet: String, Identifiable {
        case name
        case email
        case password

        var id: String { rawValue }
    }

    var body: some View {
        ZStack {
            Color.bgFigma.ignoresSafeArea()

            VStack(spacing: 0) {
                // title
                VStack(spacing: 2) {
                    Text("Profil")
                        .appPageTitleStyle()
                }
                .padding(.top)
                .padding(.bottom, 20)

                ScrollView(showsIndicators: true) {
                    VStack(spacing: 20) {
                        // Avatar + name
                        AvatarView(
                            displayName: authVM.userDisplayName ?? "Benutzer",
                            avatarStyle: selectedAvatarStyle == "auto" ? nil : selectedAvatarStyle,
                            size: 120
                        )
                        .onTapGesture {
                            showAvatarPicker = true
                        }

                        Text(authVM.userDisplayName ?? "Benutzer")
                            .foregroundColor(.textPrimary)
                            .font(.title3)

                        // Card list
                        VStack(spacing: 14) {
                            actionCard(icon: "slider.horizontal.3", title: "Einstellungen", subtitle: "Einheiten und Tracking-Optionen") {
                                showAppSettings = true
                            }

                            actionCard(icon: "pencil", title: "Name ändern", subtitle: "Ändere deinen Anzeigenamen") {
                                activeSheet = .name
                            }

                            actionCard(icon: "envelope", title: "E‑Mail ändern", subtitle: "Ändere deine Login‑E‑Mail") {
                                activeSheet = .email
                            }

                            actionCard(icon: "lock", title: "Passwort ändern", subtitle: "Setze ein neues Passwort") {
                                activeSheet = .password
                            }
                        }
                        .padding(.horizontal, AppLayout.horizontalPadding)

                        // Debug Settings (for testing motion thresholds)
                        Button(action: { showDebugSettings = true }) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.iconChipBackground)
                                        .frame(width: 52, height: 52)
                                    Image(systemName: "gear")
                                        .foregroundColor(.iconChipForeground)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("⚙️ Debug Einstellungen")
                                        .foregroundColor(.textPrimary)
                                        .font(.headline)
                                    Text("Motion Schwellenwerte feinjustieren")
                                        .foregroundColor(.textSecondary)
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.textSecondary)
                            }
                            .padding()
                            .appSectionCardStyle(cornerRadius: 12)
                        }
                        .padding(.horizontal, AppLayout.horizontalPadding)
                        .buttonStyle(PlainButtonStyle())

                        Button(action: { authVM.signOut() }) {
                            Text("Abmelden")
                                .foregroundColor(.red)
                                .padding()
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .onAppear { authVM.refreshUser() }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .name:
                ChangeNameView()
                    .environmentObject(authVM)
            case .email:
                ChangeEmailView()
                    .environmentObject(authVM)
            case .password:
                ChangePasswordView()
                    .environmentObject(authVM)
            }
        }
        .sheet(isPresented: $showDebugSettings) {
            DebugSettingsView()
        }
        .sheet(isPresented: $showAppSettings) {
            NavigationStack {
                AppSettingsView()
            }
        }
        .sheet(isPresented: $showAvatarPicker) {
            AvatarPickerView()
        }
    }

    @ViewBuilder
    func actionCard(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.iconChipBackground)
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .foregroundColor(.iconChipForeground)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .foregroundColor(.textPrimary)
                        .font(.headline)
                    Text(subtitle)
                        .foregroundColor(.textSecondary)
                        .font(.caption)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.textSecondary)
            }
            .padding()
            .appSectionCardStyle(cornerRadius: 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationViewModel())
}
