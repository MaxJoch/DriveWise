import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthenticationViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var infoMessage: String?
    @State private var failedLoginAttempts = 0

    var body: some View {
        ZStack {
            Color.bgFigma.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer().frame(height: 36)

                Image("DriveWiseLogo")
                    .renderingMode(.original)
                
                Text("Hallo Fahrer!")
                    .foregroundColor(.textPrimary)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 6)

                VStack(spacing: 22) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("E‑Mail")
                            .foregroundColor(.textSecondary)
                            .font(.caption)
                        TextField("", text: $email)
                            .foregroundColor(.textPrimary)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.cardBorder)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Passwort")
                            .foregroundColor(.textSecondary)
                            .font(.caption)
                        SecureField("", text: $password)
                            .foregroundColor(.textPrimary)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.cardBorder)
                    }

                    if failedLoginAttempts >= 3 {
                        HStack {
                            Spacer()
                            Button(action: forgotPassword) {
                                Text("Passwort vergessen?")
                                    .foregroundColor(.red)
                                    .font(.footnote)
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 28)

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                if let info = infoMessage {
                    Text(info)
                        .foregroundColor(.green)
                        .font(.footnote)
                }

                Button(action: login) {
                    Text(isLoading ? "Bitte warten..." : "ANMELDEN")
                        .appPrimaryButtonStyle()
                        .padding(.horizontal, 28)
                }

                HStack {
                    Text("Noch kein Konto?")
                        .foregroundColor(.textSecondary)
                        .font(.footnote)
                    NavigationLink(destination: SignupView().environmentObject(authVM)) {
                        Text("Registrieren")
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }

                Spacer()
            }
            .padding(.vertical)
        }
        .navigationBarHidden(true)
    }

    private func login() {
        errorMessage = nil
        infoMessage = nil
        isLoading = true
        authVM.signIn(email: email, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    failedLoginAttempts = 0
                    break
                case .failure(let err):
                    failedLoginAttempts += 1
                    errorMessage = err.localizedDescription
                }
            }
        }
    }

    private func forgotPassword() {
        errorMessage = nil
        infoMessage = nil

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Bitte gib zuerst deine E-Mail ein."
            return
        }

        authVM.sendPasswordReset(email: trimmedEmail) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    infoMessage = "Passwort-Reset wurde gesendet. Bitte prüfe dein Postfach."
                case .failure(let err):
                    errorMessage = err.localizedDescription
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AuthenticationViewModel())
    }
}
