import Foundation

struct MailAttachmentScanner: ScannerProtocol {
    func scan() async throws -> [FileItem] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let paths = [
            home.appendingPathComponent("Library/Mail Downloads"),
            home.appendingPathComponent("Library/Containers/com.apple.mail/Data/Library/Mail Downloads"),
        ]
        var items: [FileItem] = []
        for url in paths {
            guard FileManager.default.fileExists(atPath: url.path),
                  let e = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey]) else { continue }
            for case let f as URL in e {
                let v = try? f.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
                guard v?.isRegularFile == true else { continue }
                items.append(FileItem(url: f, size: Int64(v?.fileSize ?? 0), modifiedDate: nil))
            }
        }
        return items
    }
}
