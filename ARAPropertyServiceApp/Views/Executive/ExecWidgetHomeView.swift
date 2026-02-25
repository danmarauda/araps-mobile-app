import SwiftUI
import SwiftData

struct ExecWidgetHomeView: View {
    let onNavigate: (ExecScreen) -> Void
    @State private var appeared: Bool = false

    @Query private var cleaningAlerts: [CleaningAlert]
    @Query private var tasks: [FieldTask]
    @Query private var team: [UserAccount]

    private var criticalAlerts: Int {
        cleaningAlerts.filter {
            $0.urgency == .critical &&
            $0.alertStatus != .resolved &&
            $0.alertStatus != .closed
        }.count
    }

    private var allUnresolved: Int {
        cleaningAlerts.filter {
            $0.alertStatus != .resolved && $0.alertStatus != .closed
        }.count
    }

    private var activeJobs: Int {
        tasks.filter { $0.taskStatus == .inProgress }.count
    }

    private var issueJobs: Int {
        tasks.filter { $0.taskStatus == .pending && $0.priority == .critical }.count
    }

    private var completedJobs: Int {
        tasks.filter { $0.taskStatus == .completed }.count
    }

    private var onSiteCount: Int {
        team.filter { $0.isActive }.count
    }

    private var totalTeam: Int {
        team.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerSection
                if criticalAlerts > 0 { criticalBanner }
                kpiGrid
                siteReportCTA
                footerSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .onAppear { withAnimation(.easeOut(duration: 0.5)) { appeared = true } }
    }

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(araGreen.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(araGreen)
                    }
                    Text("ARA Property Services")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
                Text(dateString)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.leading, 40)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(timeString)
                    .font(.system(size: 22, weight: .light, design: .default))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.system(size: 8))
                    Text("Melbourne, AU")
                        .font(.system(size: 10))
                }
                .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.bottom, 4)
    }

    private var criticalBanner: some View {
        Button { onNavigate(.safety) } label: {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
                    .symbolEffect(.pulse)
                Text("\(criticalAlerts) critical safety alert\(criticalAlerts > 1 ? "s" : "") require attention")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.red.opacity(0.9))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundStyle(.red.opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.red.opacity(0.1))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(.red.opacity(0.25), lineWidth: 0.5)
                    }
            }
        }
        .sensoryFeedback(.warning, trigger: criticalAlerts)
    }

    private var kpiGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
        return LazyVGrid(columns: columns, spacing: 10) {
            WidgetTileView(
                icon: "clipboard.fill",
                iconColor: .blue,
                label: "Today's Jobs",
                value: "\(activeJobs) active",
                sub: issueJobs > 0 ? "\(issueJobs) critical pending" : "\(completedJobs) completed",
                hasAlert: issueJobs > 0,
                delay: 0.05,
                appeared: appeared
            ) { onNavigate(.jobs) }

            WidgetTileView(
                icon: "shield.fill",
                iconColor: .red,
                label: "Safety",
                value: allUnresolved > 0 ? "\(allUnresolved) open" : "All clear",
                sub: criticalAlerts > 0 ? "\(criticalAlerts) critical" : "No critical issues",
                hasAlert: criticalAlerts > 0,
                delay: 0.1,
                appeared: appeared
            ) { onNavigate(.safety) }

            WidgetTileView(
                icon: "person.2.fill",
                iconColor: .blue,
                label: "Field Team",
                value: "\(onSiteCount)/\(totalTeam)",
                sub: totalTeam == 0 ? "No team data" : "Active members",
                hasAlert: false,
                delay: 0.15,
                appeared: appeared
            ) { onNavigate(.team) }

            WidgetTileView(
                icon: "star.fill",
                iconColor: .yellow,
                label: "KPIs",
                value: "View All",
                sub: "Performance metrics",
                hasAlert: false,
                delay: 0.2,
                appeared: appeared
            ) { onNavigate(.kpis) }

            WidgetTileView(
                icon: "calendar.badge.clock",
                iconColor: araGreen,
                label: "Schedule",
                value: "View Tasks",
                sub: "Upcoming schedule",
                hasAlert: false,
                delay: 0.25,
                appeared: appeared
            ) { onNavigate(.meetings) }

            WidgetTileView(
                icon: "chart.bar.fill",
                iconColor: araGreen,
                label: "Operations",
                value: "Overview",
                sub: "Facility performance",
                hasAlert: false,
                delay: 0.3,
                appeared: appeared
            ) { onNavigate(.revenue) }
        }
    }

    private var siteReportCTA: some View {
        Button { onNavigate(.report) } label: {
            HStack(spacing: 10) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(araGreen)
                Text("Site Performance Report")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(araGreen)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundStyle(araGreen.opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(araGreen.opacity(0.08))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(araGreen.opacity(0.22), lineWidth: 0.5)
                    }
            }
        }
    }

    private var footerSection: some View {
        HStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(araGreen)
                    .frame(width: 6, height: 6)
                    .symbolEffect(.pulse)
                Text("Live · synced just now")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.4))
            }
            Spacer()
            Button { onNavigate(.kpis) } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 9))
                    Text("Full KPI Report")
                        .font(.system(size: 10))
                }
                .foregroundStyle(.white.opacity(0.35))
            }
        }
        .padding(.top, 8)
    }

    private var timeString: String { ARAFormatters.timeAU.string(from: .now) }
    private var dateString: String { ARAFormatters.dateAU.string(from: .now) }
}
