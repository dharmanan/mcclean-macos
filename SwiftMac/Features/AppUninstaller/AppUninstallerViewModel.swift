import Foundation
import SwiftUI

@MainActor
final class AppUninstallerViewModel: ObservableObject {
    @Published var apps: [AppItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadApps() async {
        guard !isLoading else { return }
        isLoading = true
        apps = await AppScanner.shared.scanInstalledApps()
        isLoading = false
    }

    func uninstall(_ app: AppItem) async {
        do {
            try await AppScanner.shared.uninstall(app)
            apps.removeAll { $0.id == app.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
