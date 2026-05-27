import SwiftUI

struct ContentView: View {
    @EnvironmentObject var peerService: PeerService
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case 0:
                    DiscoveryView()
                case 1:
                    NavigationView {
                        ChatsListView()
                    }
                case 2:
                    SettingsView()
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            TabBar(selectedTab: $selectedTab, peerService: peerService)
        }
        .onAppear {
            // Trigger permission after the window is fully ready.
            // init() is too early and can suppress the system dialog.
            LocalNetworkTrigger.requestPermission()
        }
    }
}

struct TabBar: View {
    @Binding var selectedTab: Int
    @ObservedObject var peerService: PeerService

    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: "antenna.radiowaves.left.and.right",
                label: "Scan",
                tag: 0,
                selectedTab: $selectedTab
            )

            TabBarButton(
                icon: "message.fill",
                label: "Msgs",
                tag: 1,
                selectedTab: $selectedTab,
                badge: peerService.connectedPeers.isEmpty ? nil : peerService.connectedPeers.count
            )

            TabBarButton(
                icon: "gearshape.fill",
                label: "Sys",
                tag: 2,
                selectedTab: $selectedTab
            )
        }
        .padding(.top, 6)
        .padding(.bottom, max(6, 0))
        .background(
            Theme.Colors.surface
                .overlay(
                    Rectangle()
                        .fill(Theme.Colors.divider)
                        .frame(height: 0.5)
                        .frame(maxHeight: .infinity, alignment: .top)
                )
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let tag: Int
    @Binding var selectedTab: Int
    var badge: Int? = nil

    var isSelected: Bool { selectedTab == tag }

    var body: some View {
        Button(action: { selectedTab = tag }) {
            VStack(spacing: 2) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? Theme.Colors.primary : Theme.Colors.textTertiary)

                    if let badge, badge > 0 {
                        Text("\(badge)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(minWidth: 14, minHeight: 14)
                            .background(Theme.Colors.danger)
                            .clipShape(Capsule())
                            .offset(x: 8, y: -6)
                    }
                }

                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? Theme.Colors.primary : Theme.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PeerService())
}
