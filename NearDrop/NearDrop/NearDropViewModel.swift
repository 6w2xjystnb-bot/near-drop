import SwiftUI
import Combine

class NearDropViewModel: ObservableObject {
    @Published var isVisible = false
    @Published var discoveredDevices: [RemoteDeviceInfo] = []
    @Published var incomingTransfer: TransferRequest? = nil
    @Published var transferProgress: Double = 0
    @Published var transferFinished = false
    @Published var lastError: String? = nil
    @Published var statusMessage = "Tap to make visible to Android devices"
    
    private var manager: NearbyConnectionManager { NearbyConnectionManager.shared }
    
    struct TransferRequest {
        let id: String
        let deviceName: String
        let pinCode: String
        let files: [FileMetadata]
        let textDescription: String?
    }
    
    init() {
        manager.mainAppDelegate = self
    }
    
    func toggleVisibility() {
        if isVisible {
            manager.stopDeviceDiscovery()
            isVisible = false
            statusMessage = "Tap to make visible to Android devices"
        } else {
            manager.becomeVisible()
            manager.startDeviceDiscovery()
            isVisible = true
            statusMessage = "Visible to Android devices on this network"
        }
    }
    
    func acceptTransfer() {
        guard let req = incomingTransfer else { return }
        manager.submitUserConsent(transferID: req.id, accept: true)
        incomingTransfer = nil
    }
    
    func rejectTransfer() {
        guard let req = incomingTransfer else { return }
        manager.submitUserConsent(transferID: req.id, accept: false)
        incomingTransfer = nil
    }
}

extension NearDropViewModel: MainAppDelegate {
    func obtainUserConsent(for transfer: TransferMetadata, from device: RemoteDeviceInfo) {
        DispatchQueue.main.async {
            self.incomingTransfer = TransferRequest(
                id: transfer.id,
                deviceName: device.name,
                pinCode: transfer.pinCode ?? "----",
                files: transfer.files,
                textDescription: transfer.textDescription
            )
            self.transferProgress = 0
            self.transferFinished = false
        }
    }
    
    func incomingTransfer(id: String, didFinishWith error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                self.lastError = error.localizedDescription
            } else {
                self.transferFinished = true
                self.statusMessage = "Transfer completed successfully"
            }
            self.transferProgress = 1.0
        }
    }
}
