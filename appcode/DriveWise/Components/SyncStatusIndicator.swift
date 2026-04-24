import SwiftUI

struct SyncErrorBanner: View {
    @EnvironmentObject var driveManager: DriveManager
    
    var body: some View {
        if let errorMessage = driveManager.lastSyncError {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 16))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Synchronisierungsfehler")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                        
                        Text(errorMessage)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SyncErrorBanner()
            .environmentObject(DriveManager())
        
        Spacer()
    }
    .padding()
}

