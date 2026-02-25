import SwiftUI
import SwiftData

struct ContactsListView: View {
    @Query(sort: \Contact.name) private var contacts: [Contact]
    @State private var searchText = ""
    @State private var selectedDepartment: String?

    private var departments: [String] {
        Array(Set(contacts.map(\.department))).sorted()
    }

    private var filteredContacts: [Contact] {
        contacts.filter { contact in
            let matchesSearch = searchText.isEmpty ||
                contact.name.localizedStandardContains(searchText) ||
                contact.role.localizedStandardContains(searchText)
            let matchesDept = selectedDepartment == nil || contact.department == selectedDepartment
            return matchesSearch && matchesDept
        }
    }

    private var groupedContacts: [(String, [Contact])] {
        let grouped = Dictionary(grouping: filteredContacts, by: \.department)
        return grouped.sorted { $0.key < $1.key }
    }

    var body: some View {
        NavigationStack {
            List {
                if groupedContacts.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ForEach(groupedContacts, id: \.0) { department, contactsInDept in
                        Section(department) {
                            ForEach(contactsInDept) { contact in
                                NavigationLink {
                                    ContactDetailView(contact: contact)
                                } label: {
                                    ContactRow(contact: contact)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .refreshable {
                try? await Task.sleep(for: .milliseconds(500))
            }
            .navigationTitle("Contacts")
            .searchable(text: $searchText, prompt: "Search contacts...")
        }
    }
}

struct ContactRow: View {
    let contact: Contact

    var body: some View {
        HStack(spacing: 12) {
            Text(contact.initials)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(ARATheme.primaryBlue)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(.subheadline.bold())
                Text(contact.role)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
