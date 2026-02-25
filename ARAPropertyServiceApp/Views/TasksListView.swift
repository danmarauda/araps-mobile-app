import SwiftUI
import SwiftData

struct TasksListView: View {
    @Query(sort: \FieldTask.scheduledStart) private var tasks: [FieldTask]
    @State private var searchText = ""
    @State private var selectedStatus: TaskStatus?

    private var filteredTasks: [FieldTask] {
        tasks.filter { task in
            let matchesSearch = searchText.isEmpty ||
                task.title.localizedStandardContains(searchText) ||
                task.facilityName.localizedStandardContains(searchText)
            let matchesStatus = selectedStatus == nil || task.taskStatus == selectedStatus
            return matchesSearch && matchesStatus
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    statusFilter

                    if tasks.isEmpty {
                        ContentUnavailableView(
                            "No Tasks",
                            systemImage: "checkmark.square",
                            description: Text("Field tasks assigned to your team will appear here.")
                        )
                        .frame(minHeight: 300)
                    } else if filteredTasks.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                            .frame(minHeight: 300)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredTasks) { task in
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
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .refreshable {
                try? await Task.sleep(for: .milliseconds(500))
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Tasks")
            .searchable(text: $searchText, prompt: "Search tasks...")
        }
    }

    private var statusFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: selectedStatus == nil, action: { selectedStatus = nil })
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    FilterChip(title: status.label, isSelected: selectedStatus == status, action: { selectedStatus = status })
                }
            }
            .padding(.vertical, 4)
        }
        .contentMargins(.horizontal, 0)
    }
}

struct TaskRowView: View {
    let task: FieldTask

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(ARATheme.taskStatusColor(task.taskStatus))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.taskNumber)
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Spacer()
                    StatusBadge(text: task.taskStatus.label, color: ARATheme.taskStatusColor(task.taskStatus))
                }

                Text(task.title)
                    .font(.subheadline.bold())
                    .lineLimit(1)

                HStack(spacing: 12) {
                    Label(task.facilityName, systemImage: "building.2")
                    Spacer()
                    Label(task.assignedWorker, systemImage: "person")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text(task.scheduledStart, style: .date)
                    Text("·")
                    Text(task.scheduledStart, style: .time)
                    Text("(\(task.estimatedDuration)min)")
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}
