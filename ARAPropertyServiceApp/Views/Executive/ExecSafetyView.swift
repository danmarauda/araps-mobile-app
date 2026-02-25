import SwiftUI
import SwiftData

struct ExecSafetyView: View {
    let onBack: () -> Void
    @State private var appeared: Bool = false

    @Query(sort: \CleaningAlert.reportedAt, order: .reverse) private var allAlerts: [CleaningAlert]

    private var unresolved: [CleaningAlert] {
        allAlerts.filter { $0.alertStatus != .resolved && $0.alertStatus != .closed }
    }

    private var resolved: [CleaningAlert] {
        allAlerts.filter { $0.alertStatus == .resolved || $0.alertStatus == .closed }
    }

    var body: some View {
        ExecScreenWrapper(title: "Safety Alerts", onBack: onBack) {
            if allAlerts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(araGreen)
                    Text("No alerts on record")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                    Text("All facilities are operating normally")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.35))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .glassCard()
                .clipShape(.rect(cornerRadius: 16))
            } else {
                if !unresolved.isEmpty {
                    sectionHeader("Active (\(unresolved.count))")
                    ForEach(Array(unresolved.enumerated()), id: \.element.id) { index, alert in
                        alertCard(alert, index: index)
                    }
                }

                if !resolved.isEmpty {
                    sectionHeader("Resolved")
                        .padding(.top, 8)
                    ForEach(Array(resolved.enumerated()), id: \.element.id) { index, alert in
                        resolvedCard(alert, index: unresolved.count + index)
                    }
                }
            }
        }
        .onAppear { appeared = true }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(.white.opacity(0.35))
            .textCase(.uppercase)
            .tracking(1)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func alertCard(_ alert: CleaningAlert, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(severityDotColor(alert.urgency))
                        .frame(width: 7, height: 7)
                        .overlay {
                            if alert.urgency == .critical {
                                Circle()
                                    .fill(severityDotColor(alert.urgency))
                                    .frame(width: 7, height: 7)
                                    .symbolEffect(.pulse)
                            }
                        }
                    Text(alert.locationName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                }
                Spacer()
                Text(urgencyLabel(alert.urgency))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(severityTextColor(alert.urgency))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background {
                        Capsule()
                            .fill(severityTextColor(alert.urgency).opacity(0.12))
                            .overlay {
                                Capsule()
                                    .strokeBorder(severityTextColor(alert.urgency).opacity(0.25), lineWidth: 0.5)
                            }
                    }
            }

            Text(alert.alertDescription)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.5))
                .lineSpacing(2)
                .padding(.leading, 13)

            Text(alert.reportedAt, style: .relative)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.3))
                .padding(.leading, 13)
        }
        .padding(14)
        .glassCard()
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.spring(response: 0.4).delay(Double(index) * 0.07), value: appeared)
    }

    private func resolvedCard(_ alert: CleaningAlert, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(araGreen)
                    Text(alert.locationName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
                Text(alert.reportedAt, style: .relative)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.3))
            }
            Text(alert.alertDescription)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.4))
                .lineSpacing(2)
                .padding(.leading, 18)
        }
        .padding(14)
        .mutedGlassCard()
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 0.6 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.spring(response: 0.4).delay(Double(index) * 0.07), value: appeared)
    }

    private func urgencyLabel(_ urgency: AlertUrgency) -> String {
        switch urgency {
        case .critical: return "Critical"
        case .high: return "Warning"
        case .low: return "Info"
        }
    }

    private func severityDotColor(_ urgency: AlertUrgency) -> Color {
        switch urgency {
        case .critical: return .red
        case .high: return .orange
        case .low: return .blue
        }
    }

    private func severityTextColor(_ urgency: AlertUrgency) -> Color {
        switch urgency {
        case .critical: return .red
        case .high: return .orange
        case .low: return .blue
        }
    }
}
