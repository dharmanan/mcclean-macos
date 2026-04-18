import Foundation

struct PrivacyScanner: ScannerProtocol {
    func scan() async throws -> [FileItem] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let paths: [URL] = [
            home.appendingPathComponent("Library/Safari/History.db"),
            home.appendingPathComponent("Library/Safari/Downloads.plist"),
            home.appendingPathComponent("Library/Cookies/Cookies.binarycookies"),
            home.appendingPathComponent("Library/Application Support/Google/Chrome/Default/History"),
            home.appendingPathComponent("Library/Application Support/Google/Chrome/Default/Cookies"),
            home.appendingPathComponent("Library/Application Support/Firefox/Profiles"),
            home.appendingPathComponent("Library/Application Support/com.apple.sharedfilelist"),
        ]
        return paths.compactMap { url -> FileItem? in
            guard FileManager.default.fileExists(atPath: url.path) else { return nil }
            let v = try? url.resourceValues(forKeys: [.fileSizeKey])
            return FileItem(url: url, size: Int64(v?.fileSize ?? 0), modifiedDate: nil)
        }
    }
}
