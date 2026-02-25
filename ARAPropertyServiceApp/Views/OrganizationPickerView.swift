import SwiftUI

struct OrganizationPickerView: View {
    let organizations: [Organization]
    let onSelect: (Organization) -> Void

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Image(systemName: "building.2.crop.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(ARATheme.primaryBlue)

                Text("Select Organization")
                    .font(.title2.bold())

                Text("Choose which organization to work in")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 60)

            VStack(spacing: 12) {
                ForEach(organizations, id: \.id) { org in
                    Button {
                        onSelect(org)
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(ARATheme.primaryBlue.opacity(0.1))
                                    .frame(width: 48, height: 48)

                                Text(orgInitials(org.name))
                                    .font(.headline.bold())
                                    .foregroundStyle(ARATheme.primaryBlue)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(org.name)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)

                                Text(org.tier.label)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption.bold())
                                .foregroundStyle(.tertiary)
                        }
                        .padding(16)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }

    private func orgInitials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let second = parts.dropFirst().first?.prefix(1) ?? ""
        return "\(first)\(second)".uppercased()
    }
}
