import SwiftUI
import SwiftData

struct ExecRevenueView: View {
    let onBack: () -> Void
    @State private var appeared: Bool = false

    @Query private var facilities: [Facility]
    @Query private var tasks: [FieldTask]
    @Query private var issues: [Issue]
    @Query private var alerts: [CleaningAlert]

    private var completedTasks: Int { tasks.filter { $0.taskStatus == .completed }.count }
    private var totalTasks: Int { tasks.count }
    private var openIssues: Int { issues.filter { $0.status == .open || $0.status == .inProgress }.count }
    private var resolvedIssues: Int { issues.filter { $0.status == .resolved }.count }
    private var avgCompliance: Double {
        facilities.isEmpty ? 0 : facilities.reduce(0) { $0 + $1.complianceRating } / Double(facilities.count)
    }
    private var criticalAlerts: Int {
        alerts.filter { $0.urgency == .critical && $0.alertStatus != .resolved && $0.alertStatus != .closed }.count
    }

    var body: some View {
        ExecScreenWrapper(title: "Operations Overview", onBack: onBack) {
            operationsSummaryCard

            Text("Facility Performance")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.35))
                .textCase(.uppercase)
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(Array(facilities.prefix(5).enumerated()), id: \.element.id) { index, facility in
                facilityCard(facility, index: index)
            }

            if facilities.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "building.2")
                        .font(.system(size: 28))
                        .foregroundStyle(.white.opacity(0.3))
                    Text("No facilities in the system yet")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .glassCard()
                .clipShape(.rect(cornerRadius: 16))
            }
        }
        .onAppear { appeared = true }
    }

    private var operationsSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Operations Summary")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.4))
                .textCase(.uppercase)
                .tracking(0.5)

            HStack(spacing: 0) {
                OperationsStat(
                    value: "\(facilities.count)",
                    label: "Sites",
                    color: araGreen
                )
                OperationsStat(
                    value: "\(completedTasks)/\(totalTasks)",
                    label: "Tasks",
                    color: .blue
                )
                OperationsStat(
                    value: "\(openIssues)",
                    label: "Issues",
                    color: openIssues > 0 ? .orange : araGreen
                )
                OperationsStat(
                    value: facilities.isEmpty ? "—" : "\(Int(avgCompliance))%",
                    label: "Compliance",
                    color: avgCompliance >= 90 ? araGreen : .orange
                )
            }

            if criticalAlerts > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.red)
                    Text("\(criticalAlerts) critical alert\(criticalAlerts > 1 ? "s" : "") require attention")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.red.opacity(0.85))
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .glassCard()
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4), value: appeared)
    }

    private func facilityCard(_ facility: Facility, index: Int) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(facility.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                Text("\(facility.suburb), \(facility.state) · \(facility.clientName)")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
                    .lineLimit(1)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.08))
                        Capsule()
                            .fill(facility.complianceRating >= 90 ? araGreen : Color.orange)
                            .frame(width: appeared ? geo.size.width * (facility.complianceRating / 100) : 0)
                            .animation(.easeOut(duration: 0.6).delay(0.3 + Double(index) * 0.08), value: appeared)
                    }
                }
                .frame(height: 4)
            }

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(facility.complianceRating))%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(facility.complianceRating >= 90 ? araGreen : .orange)
                Text("compliance")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.35))
            }
            .frame(width: 70)
        }
        .padding(14)
        .glassCard()
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -10)
        .animation(.spring(response: 0.4).delay(0.2 + Double(index) * 0.07), value: appeared)
    }
}

private struct OperationsStat: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }
}
