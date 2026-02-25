import SwiftUI

struct ContactDetailView: View {
    let contact: Contact

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileHeader
                contactActions
                infoCard
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Contact")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            Text(contact.initials)
                .font(.title.bold())
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(ARATheme.primaryBlue)
                .clipShape(Circle())

            Text(contact.name)
                .font(.title2.bold())

            Text(contact.role)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(contact.department)
                .font(.caption.bold())
                .foregroundStyle(ARATheme.primaryBlue)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(ARATheme.primaryBlue.opacity(0.1))
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
    }

    private var contactActions: some View {
        HStack(spacing: 16) {
            ContactActionButton(icon: "phone.fill", label: "Call", color: .green) {
                openURL("tel:\(contact.phone.replacingOccurrences(of: " ", with: ""))")
            }
            ContactActionButton(icon: "message.fill", label: "Message", color: ARATheme.primaryBlue) {
                openURL("sms:\(contact.phone.replacingOccurrences(of: " ", with: ""))")
            }
            ContactActionButton(icon: "envelope.fill", label: "Email", color: ARATheme.accentOrange) {
                openURL("mailto:\(contact.email)")
            }
        }
    }

    private var infoCard: some View {
        VStack(spacing: 0) {
            DetailRow(icon: "envelope.fill", title: "Email", value: contact.email)
            Divider().padding(.leading, 44)
            DetailRow(icon: "phone.fill", title: "Phone", value: contact.phone)
            Divider().padding(.leading, 44)
            DetailRow(icon: "building.2.fill", title: "Department", value: contact.department)
            if let locationName = contact.locationName {
                Divider().padding(.leading, 44)
                DetailRow(icon: "mappin.circle.fill", title: "Location", value: locationName)
            }
        }
        .padding(.vertical, 4)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

struct ContactActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .frame(width: 52, height: 52)
                    .background(color.opacity(0.12))
                    .clipShape(Circle())
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
