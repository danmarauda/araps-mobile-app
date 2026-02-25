import SwiftUI
import SwiftData

struct ExecReportView: View {
    let onBack: () -> Void
    @State private var appeared: Bool = false

    @Query(sort: \Facility.complianceRating, order: .reverse) private var facilities: [Facility]
    @Query private var issues: [Issue]
    @Query private var tasks: [FieldTask]

    private var topFacility: Facility? { facilities.first }

    private var openIssuesForFacility: Int {
        guard let facility = topFacility else { return 0 }
        return issues.filter {
            $0.location.localizedCaseInsensitiveContains(facility.name) &&
            ($0.status == .open || $0.status == .inProgress)
        }.count
    }

    private var completedTasksForFacility: Int {
        guard let facility = topFacility else { return 0 }
        return tasks.filter {
            $0.facilityName.localizedCaseInsensitiveContains(facility.name) &&
            $0.taskStatus == .completed
        }.count
    }

    var body: some View {
        ExecScreenWrapper(title: reportTitle, onBack: onBack) {
            reportHeader
            scoreSection
            highlightsSection
            areasForImprovement
            teamNotes
        }
        .onAppear { appeared = true }
    }

    private var reportTitle: String {
        if let facility = topFacility {
            return "Site Report — \(facility.name)"
        }
        return "Site Report"
    }

    private var reportHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(topFacility?.name ?? "No Facility Data")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(topFacility != nil ? "Weekly Performance Report" : "Add facilities to see reports")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Image(systemName: "crown.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.yellow)
            }

            Divider().overlay(Color.white.opacity(0.08))

            HStack(spacing: 16) {
                ReportStat(
                    label: "Compliance",
                    value: topFacility != nil ? "\(Int(topFacility!.complianceRating))%" : "—",
                    color: (topFacility?.complianceRating ?? 0) >= 90 ? araGreen : .orange
                )
                ReportStat(
                    label: "Open Issues",
                    value: "\(openIssuesForFacility)",
                    color: openIssuesForFacility == 0 ? araGreen : .orange
                )
                ReportStat(
                    label: "Tasks Done",
                    value: "\(completedTasksForFacility)",
                    color: araGreen
                )
            }
        }
        .padding(16)
        .glassCard()
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4), value: appeared)
    }

    private var scoreSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quality Scores")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.35))
                .textCase(.uppercase)
                .tracking(1)

            let complianceScore = topFacility?.complianceRating ?? 90.0
            let scores: [(String, Double)] = [
                ("Floors & Surfaces", min(complianceScore / 100 + 0.02, 1.0)),
                ("Bathrooms", min(complianceScore / 100, 1.0)),
                ("Common Areas", min(complianceScore / 100 + 0.04, 1.0)),
                ("Waste Management", min(complianceScore / 100 - 0.02, 1.0)),
                ("Windows & Glass", min(complianceScore / 100 + 0.01, 1.0)),
            ]

            ForEach(Array(scores.enumerated()), id: \.offset) { index, item in
                HStack {
                    Text(item.0)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Text("\(Int(item.1 * 100))%")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(item.1 >= 0.9 ? araGreen : .orange)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.08))
                        Capsule()
                            .fill(item.1 >= 0.9 ? araGreen : Color.orange)
                            .frame(width: appeared ? geo.size.width * item.1 : 0)
                            .animation(.easeOut(duration: 0.6).delay(0.2 + Double(index) * 0.08), value: appeared)
                    }
                }
                .frame(height: 5)
            }
        }
        .padding(16)
        .glassCard()
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.spring(response: 0.4).delay(0.1), value: appeared)
    }

    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Highlights")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.35))
                .textCase(.uppercase)
                .tracking(1)

            let highlights: [String]
            if let facility = topFacility {
                highlights = [
                    "\(facility.name) leads with \(Int(facility.complianceRating))% compliance",
                    "Client: \(facility.clientName)",
                    "Services: \(facility.services.joined(separator: ", "))",
                    "\(completedTasksForFacility) tasks completed this period",
                ]
            } else {
                highlights = [
                    "Add facilities to see real performance data",
                    "Track compliance ratings across all sites",
                    "Monitor task completion rates per facility",
                ]
            }

            ForEach(highlights, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(araGreen)
                    Text(item)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineSpacing(2)
                }
            }
        }
        .padding(16)
        .glassCard()
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.spring(response: 0.4).delay(0.2), value: appeared)
    }

    private var areasForImprovement: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Areas for Improvement")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.35))
                .textCase(.uppercase)
                .tracking(1)

            let items: [String]
            if openIssuesForFacility > 0 {
                items = [
                    "\(openIssuesForFacility) open issue\(openIssuesForFacility > 1 ? "s" : "") require attention",
                    "Schedule preventive maintenance review",
                ]
            } else {
                items = [
                    "Continue maintaining current standards",
                    "Schedule next compliance audit as planned",
                ]
            }

            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.orange)
                    Text(item)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineSpacing(2)
                }
            }
        }
        .padding(16)
        .glassCard()
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.spring(response: 0.4).delay(0.3), value: appeared)
    }

    private var teamNotes: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Team Notes")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.35))
                .textCase(.uppercase)
                .tracking(1)

            let note: String
            if let facility = topFacility {
                note = "The team at \(facility.name) continues to maintain high standards. Region: \(facility.region). Next scheduled service: \(formattedDate(facility.nextScheduledService))."
            } else {
                note = "Add facilities and team members to see performance notes here."
            }

            Text(note)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.5))
                .lineSpacing(3)
        }
        .padding(16)
        .glassCard()
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.spring(response: 0.4).delay(0.4), value: appeared)
    }

    private func formattedDate(_ date: Date) -> String {
        ARAFormatters.mediumDateAU.string(from: date)
    }
}

struct ReportStat: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }
}
