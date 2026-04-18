import Foundation

struct PrivacyScanner: ScannerProtocol {
    let targetPaths: [URL]

    init(targetPaths: [URL]? = nil) {
        let home = FileManager.default.homeDirectoryForCurrentUser
        self.targetPaths = targetPaths ?? [
            home.appendingPathComponent("Library/Safari/History.db"),
            home.appendingPathComponent("Library/Safari/Downloads.plist"),
            home.appendingPathComponent("Library/Cookies/Cookies.binarycookies"),
            home.appendingPathComponent("Library/Application Support/Google/Chrome/Default/History"),
            home.appendingPathComponent("Library/Application Support/Google/Chrome/Default/Cookies"),
            home.appendingPathComponent("Library/Application Support/Firefox/Profiles"),
            home.appendingPathComponent("Library/Application Support/com.apple.sharedfilelist"),
        ]
    }

    func scan() async throws -> [FileItem] {
        return targetPaths.compactMap { url -> FileItem? in
            guard FileManager.default.fileExists(atPath: url.path) else { return nil }
            let v = try? url.resourceValues(forKeys: [.fileSizeKey])
            return FileItem(url: url, size: Int64(v?.fileSize ?? 0), modifiedDate: nil)
        }
    }
}
