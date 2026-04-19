import Foundation
import Darwin
import Security

final class HelperDelegate: NSObject, NSXPCListenerDelegate {
	private static let allowedClientBundleIdentifier = "com.dharmanan.swiftmac"

	private func requirement() -> SecRequirement? {
		let requirementString = "identifier \"\(Self.allowedClientBundleIdentifier)\" and anchor apple generic"
		var requirement: SecRequirement?
		let status = SecRequirementCreateWithString(requirementString as CFString, SecCSFlags(), &requirement)
		guard status == errSecSuccess else { return nil }
		return requirement
	}

	private func secCode(for connection: NSXPCConnection) -> SecCode? {
		var guestCode: SecCode?

		// Prefer audit-token lookup to avoid PID reuse races.
		var auditToken = connection.auditToken
		let tokenData = Data(bytes: &auditToken, count: MemoryLayout.size(ofValue: auditToken))
		let auditAttributes = [kSecGuestAttributeAudit: tokenData] as CFDictionary
		let auditStatus = SecCodeCopyGuestWithAttributes(nil, auditAttributes, SecCSFlags(), &guestCode)
		if auditStatus == errSecSuccess, let guestCode {
			return guestCode
		}

		let pidAttributes = [kSecGuestAttributePid: NSNumber(value: connection.processIdentifier)] as CFDictionary
		let pidStatus = SecCodeCopyGuestWithAttributes(nil, pidAttributes, SecCSFlags(), &guestCode)
		guard pidStatus == errSecSuccess else { return nil }
		return guestCode
	}

	private func isTrustedClient(_ connection: NSXPCConnection) -> Bool {
		guard connection.effectiveUserIdentifier == getuid() else { return false }
		guard let guestCode = secCode(for: connection),
			  let requirement = requirement() else { return false }
		return SecCodeCheckValidity(guestCode, SecCSFlags(), requirement) == errSecSuccess
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
