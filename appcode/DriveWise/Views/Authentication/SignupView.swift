import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authVM: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.bgFigma.ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer().frame(height: 20)

                Image("DriveWiseLogo")
                    .renderingMode(.original)

                Text("Hallo Fahrer!")
                    .foregroundColor(.textPrimary)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 6)

                VStack(spacing: 18) {
                    Group {
                        labeledField(title: "Name", text: $name)
                        labeledField(title: "E‑Mail", text: $email)
                        labeledSecure(title: "Passwort", text: $password)
                        labeledSecure(title: "Passwort bestätigen", text: $confirmPassword)
                    }
                }
                .padding(.horizontal, 28)

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                Button(action: signup) {
                    Text(isLoading ? "Bitte warten..." : "REGISTRIEREN")
                        .appPrimaryButtonStyle()
                        .padding(.horizontal, 28)
                }

                HStack {
                    Text("Schon registriert?")
                        .foregroundColor(.textSecondary)
                        .font(.footnote)
                    Button { dismiss() } label: {
                        Text("Anmelden")
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

    func labeledField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .foregroundColor(.textSecondary)
                .font(.caption)
            TextField("", text: text)
                .foregroundColor(.textPrimary)
                .disableAutocorrection(true)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.cardBorder)
        }
    }

    func labeledSecure(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .foregroundColor(.textSecondary)
                .font(.caption)
            SecureField("", text: text)
                .foregroundColor(.textPrimary)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.cardBorder)
        }
    }

    private func signup() {
        errorMessage = nil
        guard password == confirmPassword else {
            errorMessage = "Passwörter stimmen nicht überein"
            return
        }
        isLoading = true
        authVM.signUp(email: email, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    // set display name if provided
                    if !name.isEmpty {
                        authVM.updateDisplayName(name) { _ in }
                    }
                    dismiss()
                case .failure(let err):
                    errorMessage = err.localizedDescription
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignupView()
            .environmentObject(AuthenticationViewModel())
    }
}
