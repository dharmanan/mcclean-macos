import Foundation
import AppKit

actor AppScanner {
    static let shared = AppScanner()

    private static let allowedResidualRoots: [String] = {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return [
            home + "/Library/Application Support",
            home + "/Library/Preferences",
            home + "/Library/Caches",
            home + "/Library/Containers",
            home + "/Library/Saved Application State",
        ]
    }()

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
        await terminateIfRunning(bundleIdentifier: app.bundleIdentifier)
        try FileManager.default.trashItem(at: app.bundleURL, resultingItemURL: nil)
        for r in app.residualFiles where r.isSelected {
            guard isAllowedResidualPath(r.url), FileManager.default.fileExists(atPath: r.url.path) else { continue }
            try? FileManager.default.removeItem(at: r.url)
        }
    }

    private func findResiduals(for bundleId: String) async -> [FileItem] {
        guard isValidBundleIdentifier(bundleId) else { return [] }
        let home = FileManager.default.homeDirectoryForCurrentUser
        let paths = [
            home.appendingPathComponent("Library/Application Support/\(bundleId)"),
            home.appendingPathComponent("Library/Preferences/\(bundleId).plist"),
            home.appendingPathComponent("Library/Caches/\(bundleId)"),
            home.appendingPathComponent("Library/Containers/\(bundleId)"),
            home.appendingPathComponent("Library/Saved Application State/\(bundleId).savedState"),
        ]
        var residuals: [FileItem] = []
        for url in paths {
            guard isAllowedResidualPath(url), FileManager.default.fileExists(atPath: url.path) else { continue }
            let size = await calcSize(url)
            residuals.append(FileItem(url: url, size: size, modifiedDate: nil))
        }
        return residuals
    }

    private func isValidBundleIdentifier(_ bundleId: String) -> Bool {
        guard !bundleId.isEmpty else { return false }
        guard !bundleId.contains("/"), !bundleId.contains("..") else { return false }
        let pattern = "^[A-Za-z0-9](?:[A-Za-z0-9.-]*[A-Za-z0-9])?$"
        return bundleId.range(of: pattern, options: .regularExpression) != nil
    }

    private func isAllowedResidualPath(_ url: URL) -> Bool {
        let normalizedPath = url.resolvingSymlinksInPath().standardizedFileURL.path
        return Self.allowedResidualRoots.contains { root in
            normalizedPath == root || normalizedPath.hasPrefix(root + "/")
        }
    }

    private func calcSize(_ url: URL) async -> Int64 {
        let rootValues = try? url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
        if rootValues?.isRegularFile == true {
            return Int64(rootValues?.fileSize ?? 0)
        }
        guard let e = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey]) else { return 0 }
        var total: Int64 = 0
        for case let f as URL in e {
            let v = try? f.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
            if v?.isRegularFile == true { total += Int64(v?.fileSize ?? 0) }
        }
        return total
    }

    private func terminateIfRunning(bundleIdentifier: String) async {
        guard let running = NSWorkspace.shared.runningApplications
            .first(where: { $0.bundleIdentifier == bundleIdentifier }) else { return }

        running.terminate()

        for _ in 0..<30 {
            if running.isTerminated { return }
            try? await Task.sleep(nanoseconds: 100_000_000)
        }

        if !running.isTerminated {
            running.forceTerminate()
            for _ in 0..<20 {
                if running.isTerminated { return }
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        }
    }
}
