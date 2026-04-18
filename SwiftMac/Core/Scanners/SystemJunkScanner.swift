import Foundation

struct SystemJunkScanner: ScannerProtocol {
    func scan() async throws -> [FileItem] {
        let paths = [
            "/Library/Caches", "/Library/Logs", "/Library/Application Support/CrashReporter",
            "/tmp", "/private/var/log", "/private/tmp", "/cores",
            "~/Library/Logs", "~/Library/Application Support/CrashReporter",
            "~/Library/Saved Application State", "~/Library/Caches/TemporaryItems",
        ]
        var items: [FileItem] = []
        for rawPath in paths {
            let path = (rawPath as NSString).expandingTildeInPath
            let url = URL(fileURLWithPath: path)
            guard FileManager.default.fileExists(atPath: path) else { continue }
            guard let contents = try? FileManager.default.contentsOfDirectory(
                at: url, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]) else { continue }
            for f in contents {
                let v = try? f.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
                items.append(FileItem(url: f, size: Int64(v?.fileSize ?? 0), modifiedDate: v?.contentModificationDate))
            }
        }
        return items
    }
}
