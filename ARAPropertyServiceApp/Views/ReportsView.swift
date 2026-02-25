import SwiftUI
import SwiftData

struct ReportsView: View {
    @Query private var issues: [Issue]
    @Query private var tasks: [FieldTask]
    @Query private var alerts: [CleaningAlert]
    @Query private var facilities: [Facility]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                overviewSection
                issueBreakdown
                taskBreakdown
                complianceSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Reports")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)

            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 12) {
                StatCard(title: "Total Issues", value: "\(issues.count)", icon: "exclamationmark.bubble.fill", color: .orange)
                StatCard(title: "Total Tasks", value: "\(tasks.count)", icon: "checkmark.square.fill", color: ARATheme.primaryBlue)
                StatCard(title: "Active Alerts", value: "\(activeAlerts)", icon: "bell.badge.fill", color: .red)
                StatCard(title: "Facilities", value: "\(facilities.count)", icon: "building.2.fill", color: .green)
            }
        }
    }

    private var issueBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Issues by Status")
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(IssueStatus.allCases, id: \.self) { status in
                    let count = issues.filter { $0.status == status }.count
                    BarRow(label: status.label, value: count, total: max(issues.count, 1), color: ARATheme.statusColor(status))
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private var taskBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tasks by Status")
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    let count = tasks.filter { $0.taskStatus == status }.count
                    BarRow(label: status.label, value: count, total: max(tasks.count, 1), color: ARATheme.taskStatusColor(status))
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private var complianceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Compliance Ratings")
                .font(.headline)

            VStack(spacing: 10) {
                ForEach(facilities) { facility in
                    HStack {
                        Text(facility.name)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                        Text("\(Int(facility.complianceRating))%")
                            .font(.caption.bold())
                            .foregroundStyle(facility.complianceRating >= 90 ? .green : .orange)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.tertiarySystemGroupedBackground))
                            Capsule()
                                .fill(facility.complianceRating >= 90 ? Color.green : Color.orange)
                                .frame(width: geo.size.width * facility.complianceRating / 100)
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private var activeAlerts: Int {
        alerts.filter { $0.alertStatus == .pending || $0.alertStatus == .acknowledged || $0.alertStatus == .inProgress }.count
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}

struct BarRow: View {
    let label: String
    let value: Int
    let total: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                Spacer()
                Text("\(value)")
                    .font(.caption.bold())
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.tertiarySystemGroupedBackground))
                    Capsule()
                        .fill(color)
                        .frame(width: max(geo.size.width * CGFloat(value) / CGFloat(total), 2))
                }
            }
            .frame(height: 6)
        }
    }
}
