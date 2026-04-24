//
//  ErrorAlertModifier.swift
//  DriveWise
//
//  Unified error display
//

import SwiftUI

struct ErrorAlertModifier: ViewModifier {
    @Binding var error: DriveWiseError?
    
    func body(content: Content) -> some View {
        content
            .alert("Fehler", isPresented: .constant(error != nil)) {
                Button("OK", role: .cancel) {
                    error = nil
                }
            } message: {
                if let error = error {
                    Text(error.errorDescription ?? "Unbekannter Fehler")
                }
            }
    }
}

extension View {
    func errorAlert(_ error: Binding<DriveWiseError?>) -> some View {
        modifier(ErrorAlertModifier(error: error))
    }
}

struct ErrorToastView: View {
    let error: DriveWiseError
    @State private var isVisible = true
    
    var body: some View {
        if isVisible {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(.red)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Fehler")
                            .font(.headline)
                        Text(error.errorDescription ?? "Unbekannter Fehler")
                            .font(.caption)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Button(action: { isVisible = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding()
            .transition(.move(edge: .top).combined(with: .opacity))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation {
                        isVisible = false
                    }
                }
            }
        }
    }
}
