import SwiftUI
import SwiftData

struct ReportIssueView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var description = ""
    @State private var location = ""
    @State private var selectedPriority: IssuePriority = .medium
    @State private var selectedCategory: IssueCategory = .cleaning

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Issue Details") {
                    TextField("Title", text: $title)
                    TextField("Location", text: $location)
                }

                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }

                Section("Priority") {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(IssuePriority.allCases, id: \.self) { priority in
                            Label(priority.label, systemImage: priority.systemImage)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(IssueCategory.allCases, id: \.self) { category in
                            Label(category.label, systemImage: category.systemImage)
                                .tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Report Issue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        let issue = Issue(
                            title: title,
                            issueDescription: description,
                            priority: selectedPriority,
                            category: selectedCategory,
                            location: location.isEmpty ? "Not specified" : location,
                            reportedBy: "Current User"
                        )
                        modelContext.insert(issue)
                        try? modelContext.save()
                        dismiss()
                    }
                    .bold()
                    .disabled(!isValid)
                }
            }
        }
    }
}
