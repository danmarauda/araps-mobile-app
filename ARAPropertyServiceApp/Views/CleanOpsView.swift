import SwiftUI
import SwiftData

struct CleanOpsView: View {
    @Query(sort: \CleaningAlert.reportedAt, order: .reverse) private var alerts: [CleaningAlert]
    @State private var showScanner = false
    @State private var showAlertForm = false
    @State private var scannedFacilityCode: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    scannerBanner

                    quickActionsGrid

                    alertsSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("CleanOps")
            .sheet(isPresented: $showAlertForm) {
                CleaningAlertFormView(prefilledLocation: scannedFacilityCode)
            }
            .sheet(isPresented: $showScanner) {
                BarcodeScannerSheet { code in
                    showScanner = false
                    scannedFacilityCode = code
                    showAlertForm = true
                }
            }
        }
    }

    private var scannerBanner: some View {
        VStack(spacing: 16) {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 48))
                .foregroundStyle(ARATheme.primaryBlue)
                .symbolEffect(.pulse)

            Text("Scan QR Code")
                .font(.headline)

            Text("Scan a location QR code to check in,\nlog a visit, or report an issue.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showScanner = true
            } label: {
                Label("Open Scanner", systemImage: "camera.fill")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(ARATheme.primaryBlue)
            .controlSize(.large)
        }
        .padding(24)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 20))
    }

    private var quickActionsGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]

        return LazyVGrid(columns: columns, spacing: 12) {
            CleanOpsActionCard(icon: "exclamationmark.triangle.fill", title: "Report Alert", color: .orange) {
                scannedFacilityCode = nil
                showAlertForm = true
            }
            CleanOpsActionCard(icon: "qrcode.viewfinder", title: "Scan QR", color: ARATheme.primaryBlue) {
                showScanner = true
            }
            CleanOpsActionCard(icon: "list.clipboard.fill", title: "My Alerts", color: .green) {
                // Shows in the alerts section below
            }
            CleanOpsActionCard(icon: "questionmark.circle.fill", title: "Help", color: .secondary) {}
        }
    }

    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Alerts")
                .font(.headline)

            if alerts.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.green)
                        Text("No active alerts")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 32)
                    Spacer()
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 14))
            } else {
                ForEach(alerts) { alert in
                    AlertCardView(alert: alert)
                }
            }
        }
    }
}

struct BarcodeScannerSheet: View {
    let onScan: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if BarcodeScannerService.isAvailable {
                    BarcodeScannerView { result in
                        onScan(result)
                    }
                } else {
                    unavailableView
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var unavailableView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.slash.fill")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)

            Text("Scanner Unavailable")
                .font(.title2.bold())

            Text("The data scanner is not available on this device. Please use a device with a camera.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

struct CleanOpsActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
    }
}

struct AlertCardView: View {
    let alert: CleaningAlert

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: alert.issueType.systemImage)
                    .foregroundStyle(ARATheme.alertUrgencyColor(alert.urgency))

                Text(alert.locationName)
                    .font(.subheadline.bold())

                Spacer()

                StatusBadge(text: alert.alertStatus.label, color: alertStatusColor)
            }

            Text(alert.alertDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                Label(alert.issueType.label, systemImage: alert.issueType.systemImage)
                Spacer()
                Text(alert.reportedAt, style: .relative)
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var alertStatusColor: Color {
        switch alert.alertStatus {
        case .pending: return .orange
        case .acknowledged: return .blue
        case .inProgress: return .purple
        case .resolved: return .green
        case .closed: return .secondary
        }
    }
}
