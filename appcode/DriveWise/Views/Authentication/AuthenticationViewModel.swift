import Foundation
import SwiftUI
import Combine

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

final class AuthenticationViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var userEmail: String? = nil
    @Published var userDisplayName: String? = nil
    @Published var userIdentifier: String? = nil

    private enum MockKeys {
        static let signedIn = "mockSignedIn"
        static let userEmail = "mockUserEmail"
        static let userDisplayName = "mockUserDisplayName"
    }

    init() {
#if canImport(FirebaseAuth)
        if let user = Auth.auth().currentUser {
            applySignedInState(email: user.email, displayName: user.displayName, identifier: user.uid)
        } else {
            clearSignedInState()
        }
#else
        // Fallback for builds without Firebase: read simple flag
        let flag = UserDefaults.standard.bool(forKey: MockKeys.signedIn)
        self.isSignedIn = flag
        if flag {
            self.userEmail = UserDefaults.standard.string(forKey: MockKeys.userEmail)
            self.userDisplayName = UserDefaults.standard.string(forKey: MockKeys.userDisplayName)
            self.userIdentifier = Self.mockIdentifier(fromEmail: self.userEmail)
            SessionUserContext.setActiveUserIdentifier(self.userIdentifier)
        }
#endif
    }

    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
#if canImport(FirebaseAuth)
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            DispatchQueue.main.async {
                self.applySignedInState(email: result?.user.email, displayName: result?.user.displayName, identifier: result?.user.uid)
                completion(.success(()))
            }
        }
#else
        // Mock sign in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.persistMockSignedInState(email: email, displayName: "Benutzer")
            self.applySignedInState(email: email, displayName: "Benutzer", identifier: Self.mockIdentifier(fromEmail: email))
            completion(.success(()))
        }
#endif
    }

    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
#if canImport(FirebaseAuth)
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            DispatchQueue.main.async {
                self.applySignedInState(email: result?.user.email, displayName: result?.user.displayName, identifier: result?.user.uid)
                completion(.success(()))
            }
        }
#else
        // Mock sign up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.persistMockSignedInState(email: email, displayName: "Benutzer")
            self.applySignedInState(email: email, displayName: "Benutzer", identifier: Self.mockIdentifier(fromEmail: email))
            completion(.success(()))
        }
#endif
    }

    func signOut() {
#if canImport(FirebaseAuth)
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.clearSignedInState()
            }
        } catch {
            print("Sign out error: \(error)")
        }
#else
        clearMockState()
        clearSignedInState()
#endif
    }

    func sendPasswordReset(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
#if canImport(FirebaseAuth)
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error {
                completion(.failure(error))
                return
            }
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }
#else
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion(.success(()))
        }
#endif
    }

    // Update display name
    func updateDisplayName(_ name: String, completion: @escaping (Result<Void, Error>) -> Void) {
#if canImport(FirebaseAuth)
        guard let user = Auth.auth().currentUser else {
            completion(.failure(authNotSignedInError()))
            return
        }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        changeRequest.commitChanges { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            DispatchQueue.main.async {
                self.userDisplayName = name
                completion(.success(()))
            }
        }
#else
        UserDefaults.standard.set(name, forKey: MockKeys.userDisplayName)
        DispatchQueue.main.async {
            self.userDisplayName = name
            completion(.success(()))
        }
#endif
    }

    // Update email
    func updateEmail(_ newEmail: String, completion: @escaping (Result<Void, Error>) -> Void) {
#if canImport(FirebaseAuth)
        guard let user = Auth.auth().currentUser else {
            completion(.failure(authNotSignedInError()))
            return
        }
        // Recommended flow: send a verification to the new email address. The
        // Firebase SDK will finalize the update when the user follows the link.
        user.sendEmailVerification(beforeUpdatingEmail: newEmail) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            DispatchQueue.main.async {
                // Do not update local `userEmail` yet — it will change after
                // the user confirms via the verification link.
                completion(.success(()))
            }
        }
#else
        UserDefaults.standard.set(newEmail, forKey: MockKeys.userEmail)
        DispatchQueue.main.async {
            self.userEmail = newEmail
            completion(.success(()))
        }
#endif
    }

    // Update password
    func updatePassword(_ newPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
#if canImport(FirebaseAuth)
        guard let user = Auth.auth().currentUser else {
            completion(.failure(authNotSignedInError()))
            return
        }
        user.updatePassword(to: newPassword) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }
#else
        // Mock doesn't store password
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion(.success(()))
        }
#endif
    }

    // Reauthenticate user with current password (needed for sensitive actions)
    func reauthenticate(currentPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
#if canImport(FirebaseAuth)
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion(.failure(authNotSignedInError()))
            return
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            DispatchQueue.main.async { completion(.success(())) }
        }
#else
        // In mock mode accept any password after small delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion(.success(()))
        }
#endif
    }

    // Refresh local cached user information from Firebase (or mock storage)
    func refreshUser() {
#if canImport(FirebaseAuth)
        guard let user = Auth.auth().currentUser else {
            DispatchQueue.main.async {
                self.clearSignedInState()
            }
            return
        }
        user.reload { _ in
            DispatchQueue.main.async {
                let currentUser = Auth.auth().currentUser
                if let currentUser {
                    self.applySignedInState(email: currentUser.email, displayName: currentUser.displayName, identifier: currentUser.uid)
                } else {
                    self.clearSignedInState()
                }
            }
        }
#else
        let flag = UserDefaults.standard.bool(forKey: MockKeys.signedIn)
        DispatchQueue.main.async {
            self.isSignedIn = flag
            self.userEmail = flag ? UserDefaults.standard.string(forKey: MockKeys.userEmail) : nil
            self.userDisplayName = flag ? UserDefaults.standard.string(forKey: MockKeys.userDisplayName) : nil
            self.userIdentifier = flag ? Self.mockIdentifier(fromEmail: self.userEmail) : nil
            SessionUserContext.setActiveUserIdentifier(self.userIdentifier)
        }
#endif
    }

    private func applySignedInState(email: String?, displayName: String?, identifier: String?) {
        isSignedIn = true
        userEmail = email
        userDisplayName = displayName
        userIdentifier = identifier ?? Self.mockIdentifier(fromEmail: email)
        SessionUserContext.setActiveUserIdentifier(userIdentifier)
    }

    private func clearSignedInState() {
        isSignedIn = false
        userEmail = nil
        userDisplayName = nil
        userIdentifier = nil
        SessionUserContext.setActiveUserIdentifier(nil)
    }

    private func persistMockSignedInState(email: String, displayName: String) {
        UserDefaults.standard.set(true, forKey: MockKeys.signedIn)
        UserDefaults.standard.set(email, forKey: MockKeys.userEmail)
        UserDefaults.standard.set(displayName, forKey: MockKeys.userDisplayName)
    }

    private func clearMockState() {
        UserDefaults.standard.set(false, forKey: MockKeys.signedIn)
        UserDefaults.standard.removeObject(forKey: MockKeys.userEmail)
        UserDefaults.standard.removeObject(forKey: MockKeys.userDisplayName)
    }

    private func authNotSignedInError() -> NSError {
        NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kein angemeldeter Nutzer"])
    }

    private static func mockIdentifier(fromEmail email: String?) -> String? {
        guard let email, !email.isEmpty else { return nil }
        return email.lowercased()
    }
}

