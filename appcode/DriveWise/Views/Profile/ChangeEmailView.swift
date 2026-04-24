import SwiftUI
#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

struct ChangeEmailView: View {
    @EnvironmentObject var authVM: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State private var currentEmail: String = ""
    @State private var newEmail: String = ""
    @State private var currentPassword: String = ""
    @State private var message: String? = nil
    @State private var isError = false
    @State private var showCheckButton = false

    var body: some View {
        ZStack {
            Color.bgFigma.ignoresSafeArea()

            VStack(spacing: 24) {
                HStack { Spacer() }

                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Aktuelle E‑Mail")
                            .foregroundColor(.textSecondary)
                            .font(.caption)
                        TextField("", text: $currentEmail)
                            .foregroundColor(.textPrimary)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.cardBorder)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Neue E‑Mail")
                            .foregroundColor(.textSecondary)
                            .font(.caption)
                        TextField("", text: $newEmail)
                            .foregroundColor(.textPrimary)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .disableAutocorrection(true)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.cardBorder)
                    }

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
                }
                .padding(.horizontal, 28)

                if let msg = message {
                    Text(msg)
                        .foregroundColor(isError ? .red : .green)
                        .font(.footnote)
                }

                if showCheckButton {
                    Button(action: checkConfirmation) {
                        Text("Prüfen, ob bestätigt")
                            .font(.footnote)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding(.top, 6)
                }

                Button(action: changeEmail) {
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text("E‑Mail ändern")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentFigma)
                    .cornerRadius(12)
                    .padding(.horizontal, 28)
                }

                Spacer()
            }
        }
        .navigationTitle("E‑Mail ändern")
        .onAppear { currentEmail = authVM.userEmail ?? "" }
    }

    private func changeEmail() {
        message = nil
        guard !newEmail.isEmpty else { message = "Bitte neue E‑Mail angeben"; isError = true; return }
        // Require current password to reauthenticate before changing email
        guard !currentPassword.isEmpty else { message = "Bitte aktuelles Passwort eingeben"; isError = true; return }

        authVM.reauthenticate(currentPassword: currentPassword) { reauthRes in
            switch reauthRes {
            case .failure(let err):
                DispatchQueue.main.async {
                    message = "Authentifizierung fehlgeschlagen: \(err.localizedDescription)"
                    isError = true
                }
            case .success:
                authVM.updateEmail(newEmail) { result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            message = "Verifizierungs‑E‑Mail gesendet. Bitte bestätige den Link in deinem Postfach, um die Adresse zu ändern."
                            isError = false
                            showCheckButton = true
                            authVM.refreshUser()
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

    private func checkConfirmation() {
        // Refresh and check whether the user's email has been updated to the new value
        authVM.refreshUser()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if authVM.userEmail == newEmail {
                message = "E‑Mail bestätigt und übernommen."
                isError = false
                // dismiss after short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { dismiss() }
            } else {
                message = "E‑Mail noch nicht bestätigt. Bitte überprüfe dein Postfach."
                isError = true
            }
        }
    }


}

#Preview {
    ChangeEmailView()
        .environmentObject(AuthenticationViewModel())
}
