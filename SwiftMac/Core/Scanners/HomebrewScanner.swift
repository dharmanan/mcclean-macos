import Foundation

struct HomebrewScanner: ScannerProtocol {
    func scan() async throws -> [FileItem] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let paths = [
            home.appendingPathComponent("Library/Caches/Homebrew"),
            URL(fileURLWithPath: "/opt/homebrew/var/cache"),
            URL(fileURLWithPath: "/usr/local/var/cache"),
        ]
        var items: [FileItem] = []
        for url in paths {
            guard FileManager.default.fileExists(atPath: url.path) else { continue }
            guard let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey]) else { continue }
            for f in contents {
                let v = try? f.resourceValues(forKeys: [.fileSizeKey])
                items.append(FileItem(url: f, size: Int64(v?.fileSize ?? 0), modifiedDate: nil))
            }
        }
        return items
    }
}
