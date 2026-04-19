import Foundation
import Darwin
import AppKit

final class HelperDelegate: NSObject, NSXPCListenerDelegate {
	private static let allowedClientBundleIdentifiers: Set<String> = [
		"com.dharmanan.swiftmac"
	]

	private func isTrustedClient(_ connection: NSXPCConnection) -> Bool {
		guard connection.effectiveUserIdentifier == getuid() else { return false }

		guard let app = NSRunningApplication(processIdentifier: connection.processIdentifier),
			  let bundleIdentifier = app.bundleIdentifier else {
			return false
		}

		return Self.allowedClientBundleIdentifiers.contains(bundleIdentifier)
	}

	func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
		guard isTrustedClient(connection) else { return false }

		connection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
		connection.exportedObject = HelperImplementation()
		connection.resume()
		return true
	}
}

let listener = NSXPCListener.service()
let delegate = HelperDelegate()
listener.delegate = delegate
listener.resume()
RunLoop.main.run()
