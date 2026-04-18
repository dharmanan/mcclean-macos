import Foundation
import AppKit

actor AppScanner {
    static let shared = AppScanner()

    func scanInstalledApps() async -> [AppItem] {
        let appDirs = [URL(fileURLWithPath: "/Applications"),
                       FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications")]
        var apps: [AppItem] = []
        for dir in appDirs {
            guard let contents = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.fileSizeKey]) else { continue }
            for appURL in contents where appURL.pathExtension == "app" {
                guard let bundle = Bundle(url: appURL) else { continue }
                let bundleId = bundle.bundleIdentifier ?? ""
                let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
                let size = await calcSize(appURL)
                let residuals = await findResiduals(for: bundleId)
                apps.append(AppItem(name: appURL.deletingPathExtension().lastPathComponent,
                                    bundleIdentifier: bundleId, bundleURL: appURL,
                                    version: version, size: size, residualFiles: residuals))
            }
        }
        return apps.sorted { $0.size > $1.size }
    }

    func uninstall(_ app: AppItem) async throws {
        NSWorkspace.shared.runningApplications
            .first { $0.bundleIdentifier == app.bundleIdentifier }?.terminate()
        try await Task.sleep(nanoseconds: 500_000_000)
        try FileManager.default.trashItem(at: app.bundleURL, resultingItemURL: nil)
        for r in app.residualFiles where r.isSelected {
            try? FileManager.default.removeItem(at: r.url)
        }
    }

    private func findResiduals(for bundleId: String) async -> [FileItem] {
        guard !bundleId.isEmpty else { return [] }
        let home = FileManager.default.homeDirectoryForCurrentUser
        let paths = [
            home.appendingPathComponent("Library/Application Support/\(bundleId)"),
            home.appendingPathComponent("Library/Preferences/\(bundleId).plist"),
            home.appendingPathComponent("Library/Caches/\(bundleId)"),
            home.appendingPathComponent("Library/Containers/\(bundleId)"),
            home.appendingPathComponent("Library/Saved Application State/\(bundleId).savedState"),
        ]
        return paths.compactMap { url -> FileItem? in
            guard FileManager.default.fileExists(atPath: url.path) else { return nil }
            return FileItem(url: url, size: 0, modifiedDate: nil)
        }
    }

    private func calcSize(_ url: URL) async -> Int64 {
        guard let e = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey]) else { return 0 }
        var total: Int64 = 0
        for case let f as URL in e {
            let v = try? f.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
            if v?.isRegularFile == true { total += Int64(v?.fileSize ?? 0) }
        }
        return total
    }
}
