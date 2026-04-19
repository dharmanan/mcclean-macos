import Foundation

actor CleanEngine {
    static let shared = CleanEngine()

    private static let allowedRoots: [String] = {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let temp = FileManager.default.temporaryDirectory.resolvingSymlinksInPath().standardizedFileURL.path
        return [
            home + "/Applications",
            home + "/Desktop",
            home + "/Documents",
            home + "/Downloads",
            home + "/Movies",
            home + "/Pictures",
            home + "/.Trash",
            home + "/.npm",
            home + "/.yarn",
            home + "/.pip",
            home + "/.cache",
            home + "/Library",
            temp,
            "/Applications",
            "/Library/Caches",
            "/Library/Logs",
            "/Library/Application Support/CrashReporter",
            "/tmp",
            "/private/tmp",
            "/private/var/log",
            "/cores",
            "/opt/homebrew/var/cache",
            "/usr/local/var/cache",
            "/System/Volumes/Data/.MobileBackups",
            "/Volumes/com.apple.TimeMachine.localsnapshots",
        ]
    }()

    private func isAllowedPath(_ url: URL) -> Bool {
        let normalizedPath = url.resolvingSymlinksInPath().standardizedFileURL.path
        return Self.allowedRoots.contains { root in
            normalizedPath == root || normalizedPath.hasPrefix(root + "/")
        }
    }

    func clean(
        items: [FileItem],
        progress: @escaping @Sendable (FileItem, Bool) -> Void
    ) async -> (cleaned: Int, failed: Int, bytesFreed: Int64) {
        var cleaned = 0; var failed = 0; var bytesFreed: Int64 = 0
        for item in items where item.isSelected {
            guard isAllowedPath(item.url) else {
                failed += 1
                await MainActor.run { progress(item, false) }
                continue
            }
            guard FileManager.default.fileExists(atPath: item.url.path) else { continue }
            do {
                try FileManager.default.removeItem(at: item.url)
                cleaned += 1; bytesFreed += item.size
                await MainActor.run { progress(item, true) }
            } catch {
                failed += 1
                await MainActor.run { progress(item, false) }
            }
        }
        return (cleaned, failed, bytesFreed)
    }

    func moveToTrash(items: [FileItem]) async -> Int64 {
        var freed: Int64 = 0
        for item in items where item.isSelected {
            guard isAllowedPath(item.url), FileManager.default.fileExists(atPath: item.url.path) else { continue }
            do {
                try FileManager.default.trashItem(at: item.url, resultingItemURL: nil)
                freed += item.size
            } catch {
                continue
            }
        }
        return freed
    }
}
