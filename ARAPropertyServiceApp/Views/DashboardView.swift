import SwiftUI
import SwiftData

struct DashboardView: View {
    let authVM: AuthViewModel
    @Query(sort: \Issue.reportedAt, order: .reverse) private var issues: [Issue]
    @Query(sort: \FieldTask.scheduledStart) private var tasks: [FieldTask]
    @Query private var facilities: [Facility]
    @Query private var alerts: [CleaningAlert]
    @Query(filter: #Predicate<AppNotification> { !$0.isRead }) private var unreadNotifications: [AppNotification]

    @State private var showNotifications = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    welcomeBanner
                    organizationBanner
                    quickActions
                    kpiGrid
                    recentIssuesSection
                    todayTasksSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNotifications = true
                    } label: {
                        Image(systemName: "bell.fill")
                            .symbolRenderingMode(.hierarchical)
                            .overlay(alignment: .topTrailing) {
                                if !unreadNotifications.isEmpty {
                                    Circle()
                                        .fill(.red)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 2, y: -2)
                                }
                            }
                    }
                }
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
            }
        }
    }

    private var welcomeBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Good \(greetingTime), \(authVM.currentUser?.firstName ?? "there")")
                .font(.title2.bold())
            Text("ARA Property Services")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var organizationBanner: some View {
        if let org = authVM.currentOrganization {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ARATheme.primaryBlue.opacity(0.1))
                        .frame(width: 36, height: 36)

                    Image(systemName: "building.2.fill")
                        .font(.caption)
                        .foregroundStyle(ARATheme.primaryBlue)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(org.name)
                        .font(.subheadline.weight(.semibold))
                    Text(org.tier.label)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            QuickActionButton(
                title: "Ask ARA",
                icon: "message.fill",
                color: ARATheme.primaryBlue
            )

            QuickActionButton(
                title: "Report Issue",
                icon: "exclamationmark.triangle.fill",
                color: ARATheme.accentOrange
            )

            QuickActionButton(
                title: "Scan QR",
                icon: "qrcode.viewfinder",
                color: ARATheme.highlightGreen
            )
        }
    }

    private var kpiGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
        ]

        return LazyVGrid(columns: columns, spacing: 12) {
            KPICardView(
                title: "Active Locations",
                value: "\(facilities.count * 24 + 2)",
                icon: "building.2.fill",
                color: ARATheme.primaryBlue,
                trend: "+3"
            )
            KPICardView(
                title: "Scheduled Today",
                value: "\(todayTasks.count)",
                icon: "calendar.badge.clock",
                color: .green
            )
            KPICardView(
                title: "Open Issues",
                value: "\(openIssues.count)",
                icon: "exclamationmark.bubble.fill",
                color: .orange,
                trend: openIssues.count > 3 ? "+2" : nil
            )
            KPICardView(
                title: "Active Alerts",
                value: "\(pendingAlerts.count)",
                icon: "bell.badge.fill",
                color: .red
            )
            KPICardView(
                title: "Compliance",
                value: "\(avgCompliance)%",
                icon: "checkmark.shield.fill",
                color: avgCompliance >= 90 ? .green : .orange
            )
            KPICardView(
                title: "Staff on Duty",
                value: "12",
                icon: "person.2.fill",
                color: ARATheme.primaryBlue
            )
        }
    }

    private var recentIssuesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Issues")
                    .font(.headline)
                Spacer()
                NavigationLink {
                    IssuesListView()
                } label: {
                    Text("See All")
                        .font(.subheadline)
                }
            }

            if issues.isEmpty {
                ContentUnavailableView("No Issues", systemImage: "checkmark.circle", description: Text("Everything looks good"))
                    .frame(height: 150)
            } else {
                ForEach(Array(issues.prefix(3))) { issue in
                    NavigationLink {
                        IssueDetailView(issue: issue)
                    } label: {
                        IssueCardView(issue: issue)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var todayTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Tasks")
                    .font(.headline)
                Spacer()
                NavigationLink {
                    TasksListView()
                } label: {
                    Text("See All")
                        .font(.subheadline)
                }
            }

            if todayTasks.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No tasks scheduled for today")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 24)
                    Spacer()
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 14))
            } else {
                ForEach(Array(todayTasks.prefix(3))) { task in
                    NavigationLink {
                        TaskDetailView(task: task)
                    } label: {
                        TaskRowView(task: task)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var greetingTime: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 0..<12: return "Morning"
        case 12..<17: return "Afternoon"
        default: return "Evening"
        }
    }

    private var openIssues: [Issue] {
        issues.filter { $0.status == .open || $0.status == .inProgress }
    }

    private var todayTasks: [FieldTask] {
        tasks.filter { Calendar.current.isDateInToday($0.scheduledStart) }
    }

    private var pendingAlerts: [CleaningAlert] {
        alerts.filter { $0.alertStatus == .pending || $0.alertStatus == .acknowledged }
    }

    private var avgCompliance: Int {
        guard !facilities.isEmpty else { return 0 }
        let avg = facilities.reduce(0.0) { $0 + $1.complianceRating } / Double(facilities.count)
        return Int(avg)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}
