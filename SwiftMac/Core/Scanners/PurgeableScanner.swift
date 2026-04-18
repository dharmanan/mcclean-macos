import Foundation

struct PurgeableScanner: ScannerProtocol {
    func scan() async throws -> [FileItem] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tmutil")
        process.arguments = ["listlocalsnapshots", "/"]
        let pipe = Pipe()
        process.standardOutput = pipe
        try process.run(); process.waitUntilExit()
        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        return output.components(separatedBy: "\n")
            .filter { $0.hasPrefix("com.apple.TimeMachine") }
            .map { snapshot in
                FileItem(url: URL(fileURLWithPath: "/Volumes/\(snapshot)"),
                         size: 500 * 1024 * 1024, modifiedDate: nil)
            }
    }
}
