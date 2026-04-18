import Foundation

struct TestSandbox {
    let url: URL

    init() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("SwiftMacTests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        self.url = root
    }

    func makeDirectory(named name: String) throws -> URL {
        let directory = url.appendingPathComponent(name, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    func makeFile(named name: String, bytes: Int) throws -> URL {
        try makeFile(in: url, named: name, contents: Data(repeating: 0x61, count: bytes))
    }

    func makeFile(named name: String, contents: Data) throws -> URL {
        try makeFile(in: url, named: name, contents: contents)
    }

    func makeFile(in directory: URL, named name: String, bytes: Int) throws -> URL {
        try makeFile(in: directory, named: name, contents: Data(repeating: 0x61, count: bytes))
    }

    func makeFile(in directory: URL, named name: String, contents: Data) throws -> URL {
        let fileURL = directory.appendingPathComponent(name)
        FileManager.default.createFile(atPath: fileURL.path, contents: contents)
        return fileURL
    }

    func remove() throws {
        try FileManager.default.removeItem(at: url)
    }
}