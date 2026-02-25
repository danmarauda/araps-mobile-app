import SwiftUI
import SwiftData

struct CleaningAlertFormView: View {
    var prefilledLocation: String? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var issueType: AlertIssueType = .cleaning
    @State private var urgency: AlertUrgency = .high
    @State private var description = ""
    @State private var reporterName = ""
    @State private var reporterContact = ""
    @State private var locationName = ""

    init(prefilledLocation: String? = nil) {
        self.prefilledLocation = prefilledLocation
        _locationName = State(initialValue: prefilledLocation ?? "")
    }

    private var isValid: Bool {
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        !reporterContact.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Location") {
                    TextField("Location name", text: $locationName)
                }

                Section("Issue Type") {
                    Picker("Issue Type", selection: $issueType) {
                        ForEach(AlertIssueType.allCases, id: \.self) { type in
                            Label(type.label, systemImage: type.systemImage).tag(type)
                        }
                    }
                }

                Section("Urgency") {
                    Picker("Urgency", selection: $urgency) {
                        ForEach(AlertUrgency.allCases, id: \.self) { u in
                            Text(u.label).tag(u)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 80)
                }

                Section("Reporter Info") {
                    TextField("Your name", text: $reporterName)
                    TextField("Contact (email or phone)", text: $reporterContact)
                        .keyboardType(.emailAddress)
                }
            }
            .navigationTitle("Report Alert")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        let alertId = "ALERT-\(Int(Date.now.timeIntervalSince1970))"
                        let alert = CleaningAlert(
                            alertId: alertId,
                            locationName: locationName.isEmpty ? "Unknown Location" : locationName,
                            issueType: issueType,
                            urgency: urgency,
                            alertDescription: description,
                            reporterName: reporterName,
                            reporterContact: reporterContact
                        )
                        modelContext.insert(alert)
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
