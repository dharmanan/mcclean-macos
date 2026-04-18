import Testing
import Foundation
@testable import SwiftMac

@Suite("Scanner Tests")
struct ScannerTests {
    @Test("Large file scanner respects threshold and sort order")
    func largeFileThreshold() async throws {
        let sandbox = try TestSandbox()
        defer { try? sandbox.remove() }

        _ = try sandbox.makeFile(named: "small.bin", bytes: 5)
        _ = try sandbox.makeFile(named: "medium.bin", bytes: 20)
        _ = try sandbox.makeFile(named: "large.bin", bytes: 50)

        let scanner = LargeFileScanner(searchDirectories: [sandbox.url], minSizeBytes: 10)
        let items = try await scanner.scan()

        #expect(items.count == 2)
        #expect(items.map(\.name) == ["large.bin", "medium.bin"])
        #expect(items.allSatisfy { $0.size >= scanner.minSizeBytes })
    }

    @Test("Duplicate scanner keeps oldest file and returns newer duplicates")
    func duplicateScan() async throws {
        let sandbox = try TestSandbox()
        defer { try? sandbox.remove() }

        let firstDir = try sandbox.makeDirectory(named: "first")
        let secondDir = try sandbox.makeDirectory(named: "second")

        let older = try sandbox.makeFile(in: firstDir, named: "report.txt", contents: Data("same-data".utf8))
        let newer = try sandbox.makeFile(in: secondDir, named: "report-copy.txt", contents: Data("same-data".utf8))
        let unique = try sandbox.makeFile(in: secondDir, named: "unique.txt", contents: Data("unique".utf8))

        try FileManager.default.setAttributes([.modificationDate: Date(timeIntervalSince1970: 1_000)], ofItemAtPath: older.path)
        try FileManager.default.setAttributes([.modificationDate: Date(timeIntervalSince1970: 2_000)], ofItemAtPath: newer.path)
        try FileManager.default.setAttributes([.modificationDate: Date(timeIntervalSince1970: 3_000)], ofItemAtPath: unique.path)

        let scanner = DuplicateScanner(searchDirectories: [firstDir, secondDir])
        let items = try await scanner.scan()

        #expect(items.count == 1)
        #expect(items.first?.name == newer.lastPathComponent)
        #expect(items.first?.modifiedDate == Date(timeIntervalSince1970: 2_000))
    }

    @Test("Trash scanner reads configured trash directory")
    func trashPath() async throws {
        let sandbox = try TestSandbox()
        defer { try? sandbox.remove() }

        let trash = try sandbox.makeDirectory(named: "Trash")
        _ = try sandbox.makeFile(in: trash, named: "old.log", bytes: 10)
        _ = try sandbox.makeFile(in: trash, named: "cache.tmp", bytes: 3)

        let items = try await TrashScanner(trashDirectory: trash).scan()

        #expect(items.count == 2)
        #expect(Set(items.map(\.name)) == ["old.log", "cache.tmp"])
    }

    @Test("Privacy scanner returns only configured existing paths")
    func privacyPaths() async throws {
        let sandbox = try TestSandbox()
        defer { try? sandbox.remove() }

        let existing = try sandbox.makeFile(named: "History.db", bytes: 9)
        let missing = sandbox.url.appendingPathComponent("Missing.cookies")

        let items = try await PrivacyScanner(targetPaths: [existing, missing]).scan()

        #expect(items.count == 1)
        #expect(items.first?.url == existing)
    }
}
