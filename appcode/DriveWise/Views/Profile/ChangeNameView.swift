import SwiftUI

struct ChangeNameView: View {
    @EnvironmentObject var authVM: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var message: String? = nil
    @State private var isError = false

    var body: some View {
        ZStack {
            Color.bgFigma.ignoresSafeArea()

            VStack(spacing: 24) {
                HStack { Spacer() }

                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Neuer Name")
                            .foregroundColor(.textSecondary)
                            .font(.caption)
                        TextField("", text: $name)
                            .foregroundColor(.textPrimary)
                            .disableAutocorrection(true)
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

                Button(action: save) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Name speichern")
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
        .navigationTitle("Name ändern")
        .onAppear { name = authVM.userDisplayName ?? "" }
    }

    private func save() {
        message = nil
        guard !name.isEmpty else { message = "Bitte Name angeben"; isError = true; return }
        authVM.updateDisplayName(name) { result in
            switch result {
            case .success:
                // Refresh user so profile reflects change immediately
                authVM.refreshUser()
                message = "Name aktualisiert"
                isError = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { dismiss() }
            case .failure(let err):
                message = err.localizedDescription
                isError = true
            }
        }
    }
}

#Preview {
    ChangeNameView()
        .environmentObject(AuthenticationViewModel())
}
