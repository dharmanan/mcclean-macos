import Foundation
import Darwin

final class HelperDelegate: NSObject, NSXPCListenerDelegate {
	func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
		guard connection.effectiveUserIdentifier == getuid() else {
			return false
		}

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
