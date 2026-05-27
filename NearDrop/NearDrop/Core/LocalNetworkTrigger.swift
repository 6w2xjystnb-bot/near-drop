import Foundation
import MultipeerConnectivity

/// Triggers the iOS Local Network Privacy permission dialog on first launch.
/// Uses MCNearbyServiceBrowser because it is the most reliable way to force
/// the system alert — MultipeerConnectivity is what the app actually needs.
struct LocalNetworkTrigger {
    static func requestPermission() {
        let peerID = MCPeerID(displayName: "trigger-\(UUID().uuidString.prefix(4))")
        let browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "neardrop")
        browser.startBrowsingForPeers()

        // Keep browsing alive long enough for the OS to present the alert.
        // Cancelling too early can suppress the dialog.
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            browser.stopBrowsingForPeers()
        }
    }
}
