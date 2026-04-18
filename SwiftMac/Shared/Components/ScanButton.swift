import SwiftUI

struct ScanButton: View {
    let state: DashboardViewModel.ScanState
    let action: () -> Void

    var title: String {
        switch state {
        case .idle: return "Smart Scan"
        case .scanning: return "Scanning..."
        case .done: return "Scan Again"
        case .cleaning: return "Cleaning..."
        }
    }

    var icon: String {
        switch state {
        case .cleaning: return "trash"
        default: return "sparkles"
        }
    }

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
        }
        .buttonStyle(.borderedProminent)
        .disabled(state == .scanning || state == .cleaning)
    }
}
