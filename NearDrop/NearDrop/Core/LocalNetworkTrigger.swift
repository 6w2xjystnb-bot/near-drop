import Foundation
import Network

/// Triggers the iOS Local Network Privacy permission dialog on first launch.
/// MultipeerConnectivity's Bonjour usage alone may delay the prompt until
/// browsing/advertising starts. This helper forces the system alert early.
struct LocalNetworkTrigger {
    static func requestPermission() {
        // NWBrowser with Bonjour will trigger the local-network alert
        let browser = NWBrowser(for: .bonjour(type: "_neardrop._tcp", domain: nil), using: .tcp)
        browser.stateUpdateHandler = { state in
            if case .failed = state {
                browser.cancel()
            }
        }
        browser.start(queue: .main)
        // Cancel after a short delay — we only need the prompt, not actual browsing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            browser.cancel()
        }
    }
}
