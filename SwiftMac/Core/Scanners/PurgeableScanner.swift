import Foundation

struct PurgeableScanner: ScannerProtocol {
    func scan() async throws -> [FileItem] {
        let output = try runCommand(path: "/usr/bin/tmutil", arguments: ["listlocalsnapshots", "/"])
        let snapshots = output
            .split(whereSeparator: \.isNewline)
            .map(String.init)
            .filter { $0.hasPrefix("com.apple.TimeMachine") }

        return snapshots.map { snapshot in
            let snapshotURL = resolveSnapshotURL(snapshot)
            let measuredSize = measureSnapshotSize(at: snapshotURL)
            return FileItem(url: snapshotURL, size: measuredSize, modifiedDate: nil)
        }
    }

    private func resolveSnapshotURL(_ snapshot: String) -> URL {
        let host = ProcessInfo.processInfo.hostName
        let datePart = snapshotDate(from: snapshot)
        let candidates = [
            "/Volumes/com.apple.TimeMachine.localsnapshots/Backups.backupdb/\(host)/\(datePart)",
            "/System/Volumes/Data/.MobileBackups/\(datePart)",
        ]

        for path in candidates where FileManager.default.fileExists(atPath: path) {
            return URL(fileURLWithPath: path)
        }

        return URL(fileURLWithPath: "/Volumes/\(snapshot)")
    }

    private func snapshotDate(from snapshot: String) -> String {
        var value = snapshot
        let prefix = "com.apple.TimeMachine."
        let suffix = ".local"

        if value.hasPrefix(prefix) {
            value.removeFirst(prefix.count)
        }
        if value.hasSuffix(suffix) {
            value.removeLast(suffix.count)
        }
        return value
    }

    private func measureSnapshotSize(at url: URL) -> Int64 {
        guard FileManager.default.fileExists(atPath: url.path) else { return 0 }

        if let output = try? runCommand(path: "/usr/bin/du", arguments: ["-sk", url.path]),
              let first = output.split(whereSeparator: \.isWhitespace).first,
              let kilobytes = Int64(String(first)) {
            return kilobytes * 1024
        }

        return FileManager.default.directorySize(at: url)
    }

    private func runCommand(path: String, arguments: [String]) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments

        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe

        try process.run()
        process.waitUntilExit()

        let outputData = outPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

        guard process.terminationStatus == 0 else {
            throw NSError(
                domain: "PurgeableScanner",
                code: Int(process.terminationStatus),
                userInfo: [NSLocalizedDescriptionKey: errorOutput.isEmpty ? output : errorOutput]
            )
        }

        return output
    }
}
