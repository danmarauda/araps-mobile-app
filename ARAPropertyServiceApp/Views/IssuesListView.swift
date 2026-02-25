import SwiftUI
import SwiftData

struct IssuesListView: View {
    @Query(sort: \Issue.reportedAt, order: .reverse) private var issues: [Issue]
    @State private var searchText = ""
    @State private var selectedStatus: IssueStatus?
    @State private var selectedPriority: IssuePriority?
    @State private var showCreateIssue = false

    private var filteredIssues: [Issue] {
        issues.filter { issue in
            let matchesSearch = searchText.isEmpty ||
                issue.title.localizedStandardContains(searchText) ||
                issue.location.localizedStandardContains(searchText)
            let matchesStatus = selectedStatus == nil || issue.status == selectedStatus
            let matchesPriority = selectedPriority == nil || issue.priority == selectedPriority
            return matchesSearch && matchesStatus && matchesPriority
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    filterBar

                    if issues.isEmpty {
                        ContentUnavailableView(
                            "No Issues",
                            systemImage: "exclamationmark.bubble",
                            description: Text("Reported issues will appear here. Tap + to report a new issue.")
                        )
                        .frame(minHeight: 300)
                    } else if filteredIssues.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                            .frame(minHeight: 300)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredIssues) { issue in
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
                .padding(.horizontal, 16)
                .padding(.bottom, 80)
            }
            .refreshable {
                try? await Task.sleep(for: .milliseconds(500))
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Issues")
            .searchable(text: $searchText, prompt: "Search issues...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateIssue = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showCreateIssue) {
                ReportIssueView()
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All Status",
                    isSelected: selectedStatus == nil,
                    action: { selectedStatus = nil }
                )
                ForEach(IssueStatus.allCases, id: \.self) { status in
                    FilterChip(
                        title: status.label,
                        isSelected: selectedStatus == status,
                        action: { selectedStatus = status }
                    )
                }

                Divider()
                    .frame(height: 24)

                FilterChip(
                    title: "All Priority",
                    isSelected: selectedPriority == nil,
                    action: { selectedPriority = nil }
                )
                ForEach(IssuePriority.allCases, id: \.self) { priority in
                    FilterChip(
                        title: priority.label,
                        isSelected: selectedPriority == priority,
                        action: { selectedPriority = priority }
                    )
                }
            }
            .padding(.vertical, 4)
        }
        .contentMargins(.horizontal, 0)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(isSelected ? ARATheme.primaryBlue : Color(.tertiarySystemGroupedBackground))
                .clipShape(Capsule())
        }
    }
}
