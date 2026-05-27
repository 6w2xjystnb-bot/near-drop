import SwiftUI

@main
struct NearDropApp: App {
    @StateObject private var peerService = PeerService()

    init() {
        // Trigger the Local Network Privacy dialog as early as possible.
        // The user must grant this for MultipeerConnectivity to work.
        LocalNetworkTrigger.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(peerService)
        }
    }
}
