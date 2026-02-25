import SwiftUI
import SwiftData

struct FacilitiesListView: View {
    @Query(sort: \Facility.name) private var facilities: [Facility]
    @State private var searchText = ""

    private var filteredFacilities: [Facility] {
        guard !searchText.isEmpty else { return facilities }
        return facilities.filter {
            $0.name.localizedStandardContains(searchText) ||
            $0.clientName.localizedStandardContains(searchText) ||
            $0.region.localizedStandardContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if filteredFacilities.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ForEach(filteredFacilities) { facility in
                        NavigationLink {
                            FacilityDetailView(facility: facility)
                        } label: {
                            FacilityRow(facility: facility)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Properties")
            .searchable(text: $searchText, prompt: "Search properties...")
        }
    }
}

struct FacilityRow: View {
    let facility: Facility

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(facility.name)
                    .font(.subheadline.bold())
                Spacer()
                ComplianceRing(value: facility.complianceRating)
            }

            Text(facility.clientName)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Label(facility.region, systemImage: "mappin")
                Label(facility.type, systemImage: "building.2")
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

struct ComplianceRing: View {
    let value: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.tertiarySystemGroupedBackground), lineWidth: 3)
            Circle()
                .trim(from: 0, to: value / 100)
                .stroke(value >= 90 ? Color.green : Color.orange, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(value))")
                .font(.caption2.bold())
        }
        .frame(width: 36, height: 36)
    }
}
