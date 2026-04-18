import Testing
import Foundation
@testable import SwiftMac

@Suite("Engine Tests")
struct EngineTests {
    @Test("Clean engine handles empty input")
    func cleanEmptyInput() async {
        let result = await CleanEngine.shared.clean(items: []) { _, _ in }
        #expect(result.cleaned == 0)
        #expect(result.failed == 0)
        #expect(result.bytesFreed == 0)
    }

    @Test("Clean engine removes selected files only")
    func cleanSelectedFiles() async throws {
        let sandbox = try TestSandbox()
        defer { try? sandbox.remove() }

        let removable = try sandbox.makeFile(named: "remove.tmp", bytes: 12)
        let keep = try sandbox.makeFile(named: "keep.tmp", bytes: 7)

        let items = [
            FileItem(url: removable, size: 12, modifiedDate: nil, isSelected: true),
            FileItem(url: keep, size: 7, modifiedDate: nil, isSelected: false),
        ]

        let result = await CleanEngine.shared.clean(items: items) { _, _ in }

        #expect(result.cleaned == 1)
        #expect(result.failed == 0)
        #expect(result.bytesFreed == 12)
        #expect(!FileManager.default.fileExists(atPath: removable.path))
        #expect(FileManager.default.fileExists(atPath: keep.path))
    }
}
