import Foundation

final class HelperImplementation: NSObject, HelperProtocol {
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

    private func isAllowedPath(_ path: String) -> Bool {
        let normalizedPath = URL(fileURLWithPath: path)
            .resolvingSymlinksInPath()
            .standardizedFileURL
            .path
        return Self.allowedRoots.contains { root in
            normalizedPath == root || normalizedPath.hasPrefix(root + "/")
        }
    }

    func removeItem(atPath path: String, withReply reply: @escaping (Bool) -> Void) {
        guard isAllowedPath(path), FileManager.default.fileExists(atPath: path) else {
            reply(false)
            return
        }
        do {
            try FileManager.default.removeItem(atPath: path)
            reply(true)
        } catch {
            reply(false)
        }
    }
}
