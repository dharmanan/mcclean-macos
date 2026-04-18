import Foundation

struct XcodeScanner: ScannerProtocol {
    func scan() async throws -> [FileItem] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let lib = home.appendingPathComponent("Library")
        let paths = [
            lib.appendingPathComponent("Developer/Xcode/DerivedData"),
            lib.appendingPathComponent("Developer/Xcode/Archives"),
            lib.appendingPathComponent("Developer/CoreSimulator/Caches"),
            lib.appendingPathComponent("Developer/Xcode/iOS DeviceSupport"),
            lib.appendingPathComponent("Caches/com.apple.dt.Xcode"),
        ]
        var items: [FileItem] = []
        for url in paths {
            guard FileManager.default.fileExists(atPath: url.path) else { continue }
            guard let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]) else { continue }
            for f in contents {
                let v = try? f.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
                items.append(FileItem(url: f, size: Int64(v?.fileSize ?? 0), modifiedDate: v?.contentModificationDate))
            }
        }
        return items
    }
}
