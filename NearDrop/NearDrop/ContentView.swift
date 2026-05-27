import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = NearDropViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Visibility toggle
                VStack(spacing: 12) {
                    Image(systemName: viewModel.isVisible ? "antenna.radiowaves.left.and.right.circle.fill" : "antenna.radiowaves.left.and.right.circle")
                        .font(.system(size: 64))
                        .foregroundColor(viewModel.isVisible ? .green : .gray)
                    
                    Text(viewModel.isVisible ? "Visible" : "Not Visible")
                        .font(.title2.bold())
                    
                    Text(viewModel.statusMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: { viewModel.toggleVisibility() }) {
                        Text(viewModel.isVisible ? "Stop" : "Make Visible")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isVisible ? Color.red : Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Discovered devices
                if !viewModel.discoveredDevices.isEmpty {
                    List {
                        Section(header: Text("Nearby Devices")) {
                            ForEach(viewModel.discoveredDevices, id: \.id) { device in
                                HStack {
                                    Image(systemName: device.type == .phone ? "iphone" : "ipad")
                                    Text(device.name)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                
                Spacer()
                
                // Info footer
                Text("Files received from Android will be saved to the Documents folder")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top)
            .navigationTitle("NearDrop")
        }
        .sheet(item: $viewModel.incomingTransfer) { request in
            IncomingTransferSheet(request: request, viewModel: viewModel)
        }
        .alert("Transfer Complete", isPresented: $viewModel.transferFinished) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("File saved to Documents folder")
        }
    }
}

struct IncomingTransferSheet: View {
    let request: NearDropViewModel.TransferRequest
    @ObservedObject var viewModel: NearDropViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.blue)
                    
                    Text("Incoming Transfer")
                        .font(.title2.bold())
                    
                    Text("From: \(request.deviceName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 12) {
                    Text("PIN Code")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text(request.pinCode)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                if let desc = request.textDescription {
                    Text(desc)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                if !request.files.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Files")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ForEach(request.files, id: \.name) { file in
                            HStack {
                                Image(systemName: "doc")
                                VStack(alignment: .leading) {
                                    Text(file.name)
                                        .font(.subheadline)
                                    Text("\(ByteCountFormatter.string(fromByteCount: file.size, countStyle: .file))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.rejectTransfer()
                        dismiss()
                    }) {
                        Text("Decline")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        viewModel.acceptTransfer()
                        dismiss()
                    }) {
                        Text("Accept")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
            .navigationTitle("Receive File")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension NearDropViewModel.TransferRequest: Identifiable {}
