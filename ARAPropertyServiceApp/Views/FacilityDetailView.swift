import SwiftUI

struct FacilityDetailView: View {
    let facility: Facility

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                servicesSection
                detailsSection
                notesSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(facility.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(facility.name)
                        .font(.title3.bold())
                    Text(facility.clientName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(facility.type)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                Spacer()
                ComplianceRing(value: facility.complianceRating)
                    .frame(width: 56, height: 56)
            }

            HStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(ARATheme.primaryBlue)
                Text("\(facility.address), \(facility.suburb) \(facility.state) \(facility.postcode)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Services")
                .font(.headline)

            FlowLayout(spacing: 8) {
                ForEach(facility.services, id: \.self) { service in
                    Text(service)
                        .font(.caption.bold())
                        .foregroundStyle(ARATheme.primaryBlue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(ARATheme.primaryBlue.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var detailsSection: some View {
        VStack(spacing: 0) {
            DetailRow(icon: "map.fill", title: "Region", value: facility.region)
            Divider().padding(.leading, 44)
            DetailRow(icon: "calendar", title: "Next Service", value: facility.nextScheduledService.formatted(date: .abbreviated, time: .omitted))
            if let lastAudit = facility.lastISOAudit {
                Divider().padding(.leading, 44)
                DetailRow(icon: "checkmark.shield.fill", title: "Last ISO Audit", value: lastAudit.formatted(date: .abbreviated, time: .omitted))
            }
        }
        .padding(.vertical, 4)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    @ViewBuilder
    private var notesSection: some View {
        if facility.accessInstructions != nil || facility.safetyNotes != nil {
            VStack(alignment: .leading, spacing: 12) {
                if let access = facility.accessInstructions {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Access Instructions", systemImage: "key.fill")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        Text(access)
                            .font(.subheadline)
                    }
                }
                if let safety = facility.safetyNotes {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Safety Notes", systemImage: "exclamationmark.shield.fill")
                            .font(.caption.bold())
                            .foregroundStyle(.orange)
                        Text(safety)
                            .font(.subheadline)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
    }
}

struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (positions, CGSize(width: maxX, height: y + rowHeight))
    }
}
