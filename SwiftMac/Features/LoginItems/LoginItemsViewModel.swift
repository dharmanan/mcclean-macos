import AppKit
import Foundation
import SwiftUI

struct LoginItem: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    var isEnabled: Bool
    let icon: NSImage?
}

@MainActor
final class LoginItemsViewModel: ObservableObject {
    @Published var items: [LoginItem] = []

    func load() async {
        let agentsURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/LaunchAgents")
        guard let contents = try? FileManager.default.contentsOfDirectory(at: agentsURL, includingPropertiesForKeys: nil) else {
            items = []
            return
        }

        items = contents
            .filter { $0.pathExtension == "plist" }
            .map { url in
                LoginItem(
                    name: url.fileNameWithoutExtension,
                    path: url.path,
                    isEnabled: true,
                    icon: NSWorkspace.shared.icon(forFile: url.path)
                )
            }
    }

    func setEnabled(_ enabled: Bool, for item: LoginItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isEnabled = enabled
    }
}
