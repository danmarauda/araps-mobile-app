import SwiftUI
import SwiftData

struct ExecKPIsView: View {
    let onBack: () -> Void
    @State private var appeared: Bool = false

    @Query private var issues: [Issue]
    @Query private var tasks: [FieldTask]
    @Query private var facilities: [Facility]
    @Query private var alerts: [CleaningAlert]
    @Query private var contacts: [Contact]

    private struct KPIItem {
        let label: String
        let value: String
        let sub: String
        let trend: TrendDirection
        let trendValue: String
        let good: Bool
    }

    private var computedKPIs: [KPIItem] {
        let openIssues = issues.filter { $0.status == .open || $0.status == .inProgress }.count
        let totalIssues = max(issues.count, 1)

        let completedTasks = tasks.filter { $0.taskStatus == .completed }.count
        let totalTasks = max(tasks.count, 1)
        let taskRate = Int(Double(completedTasks) / Double(totalTasks) * 100)

        let unresolvedAlerts = alerts.filter {
            $0.alertStatus != .resolved && $0.alertStatus != .closed
        }.count
        let criticalAlerts = alerts.filter {
            $0.urgency == .critical && $0.alertStatus != .resolved && $0.alertStatus != .closed
        }.count

        let avgCompliance = facilities.isEmpty ? 0.0
            : facilities.reduce(0.0) { $0 + $1.complianceRating } / Double(facilities.count)

        let activeContacts = contacts.filter { $0.isActive }.count

        return [
            KPIItem(
                label: "Open Issues",
                value: "\(openIssues)",
                sub: "\(totalIssues) total reported",
                trend: openIssues == 0 ? .up : .down,
                trendValue: openIssues == 0 ? "All resolved" : "\(openIssues) active",
                good: openIssues == 0
            ),
            KPIItem(
                label: "Task Completion",
                value: "\(taskRate)%",
                sub: "\(completedTasks) of \(tasks.count) tasks done",
                trend: taskRate >= 80 ? .up : .down,
                trendValue: taskRate >= 80 ? "+\(taskRate)%" : "\(taskRate)%",
                good: taskRate >= 80
            ),
            KPIItem(
                label: "Active Facilities",
                value: "\(facilities.count)",
                sub: "Managed sites",
                trend: .up,
                trendValue: "\(facilities.count) sites",
                good: true
            ),
            KPIItem(
                label: "Safety Alerts",
                value: unresolvedAlerts == 0 ? "All clear" : "\(unresolvedAlerts) open",
                sub: criticalAlerts > 0 ? "\(criticalAlerts) critical" : "No critical issues",
                trend: unresolvedAlerts == 0 ? .up : .down,
                trendValue: unresolvedAlerts == 0 ? "Clear" : "\(unresolvedAlerts) open",
                good: unresolvedAlerts == 0
            ),
            KPIItem(
                label: "Avg Compliance",
                value: facilities.isEmpty ? "—" : "\(Int(avgCompliance))%",
                sub: "\(facilities.count) facilities rated",
                trend: avgCompliance >= 85 ? .up : .down,
                trendValue: facilities.isEmpty ? "No data" : "\(Int(avgCompliance))%",
                good: avgCompliance >= 85
            ),
            KPIItem(
                label: "Active Contacts",
                value: "\(activeContacts)",
                sub: "Team directory",
                trend: .up,
                trendValue: "\(activeContacts) active",
                good: true
            ),
        ]
    }

    var body: some View {
        ExecScreenWrapper(title: "Key Performance Indicators", onBack: onBack) {
            Text("Current — \(monthYearString)")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.35))
                .textCase(.uppercase)
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(Array(computedKPIs.enumerated()), id: \.offset) { index, kpi in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(kpi.label)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.45))
                        Text(kpi.value)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                        Text(kpi.sub)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: kpi.trend == .up ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 12))
                        Text(kpi.trendValue)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(kpi.good ? araGreen : .red)
                }
                .padding(16)
                .glassCard()
                .clipShape(.rect(cornerRadius: 16))
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.spring(response: 0.4).delay(Double(index) * 0.06), value: appeared)
            }
        }
        .onAppear { appeared = true }
    }

    private var monthYearString: String { ARAFormatters.monthYearAU.string(from: .now) }
}
