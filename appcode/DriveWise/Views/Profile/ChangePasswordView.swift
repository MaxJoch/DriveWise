import SwiftUI
#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

struct ChangePasswordView: View {
    @EnvironmentObject var authVM: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State private var currentPassword: String = ""
    @State private var password: String = ""
    @State private var confirm: String = ""
    @State private var message: String? = nil
    @State private var isError = false

    var body: some View {
        ZStack {
            Color.bgFigma.ignoresSafeArea()

            VStack(spacing: 20) {
                HStack { Spacer() }

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Aktuelles Passwort")
                            .foregroundColor(.textSecondary)
                            .font(.caption)
                        SecureField("", text: $currentPassword)
                            .foregroundColor(.textPrimary)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.cardBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Neues Passwort")
                            .foregroundColor(.textSecondary)
                            .font(.caption)
                        SecureField("", text: $password)
                            .foregroundColor(.textPrimary)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.cardBorder)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Passwort bestätigen")
                            .foregroundColor(.textSecondary)
                            .font(.caption)
                        SecureField("", text: $confirm)
                            .foregroundColor(.textPrimary)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.cardBorder)
                    }
                }
                .padding(.horizontal, 28)

                Button(action: changePassword) {
                    HStack {
                        Image(systemName: "lock.fill")
                        Text("Passwort ändern")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentFigma)
                    .cornerRadius(12)
                    .padding(.horizontal, 28)
                }

                if let msg = message {
                    Text(msg)
                        .foregroundColor(isError ? .red : .green)
                        .font(.footnote)
                }

                Spacer()
            }
        }
        .navigationTitle("Passwort ändern")
    }

    private func changePassword() {
        message = nil
        guard !currentPassword.isEmpty else { message = "Bitte aktuelles Passwort eingeben"; isError = true; return }
        guard !password.isEmpty, password == confirm else { message = "Passwörter stimmen nicht überein"; isError = true; return }

        // First reauthenticate inline using the provided current password
        authVM.reauthenticate(currentPassword: currentPassword) { reauthRes in
            switch reauthRes {
            case .failure(let err):
                DispatchQueue.main.async {
                    message = "Authentifizierung fehlgeschlagen: \(err.localizedDescription)"
                    isError = true
                }
            case .success:
                // Now update the password
                authVM.updatePassword(password) { result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            message = "Passwort aktualisiert. Du wirst jetzt abgemeldet."
                            isError = false
                            // Sign out automatically so the user logs in again with new credentials
                            authVM.signOut()
                        }
                    case .failure(let err):
                        DispatchQueue.main.async {
                            message = err.localizedDescription
                            isError = true
                        }
                    }
                }
            }
        }
    }


}

#Preview {
    ChangePasswordView()
        .environmentObject(AuthenticationViewModel())
}
