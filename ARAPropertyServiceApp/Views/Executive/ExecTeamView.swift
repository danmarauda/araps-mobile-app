import SwiftUI
import SwiftData

struct ExecTeamView: View {
    let onBack: () -> Void
    @State private var appeared: Bool = false

    @Query(sort: \UserAccount.firstName) private var allUsers: [UserAccount]

    private var fieldTeam: [UserAccount] {
        allUsers.filter {
            $0.role == .fieldWorker ||
            $0.role == .supervisor ||
            $0.role == .contractor
        }
    }

    private var onSiteCount: Int { fieldTeam.filter { $0.isActive }.count }
    private var totalCount: Int { fieldTeam.count }

    var body: some View {
        ExecScreenWrapper(title: "Field Team", onBack: onBack) {
            teamSummary
            if fieldTeam.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.2.slash")
                        .font(.system(size: 32))
                        .foregroundStyle(.white.opacity(0.3))
                    Text("No field team members yet")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .glassCard()
                .clipShape(.rect(cornerRadius: 16))
            } else {
                ForEach(Array(fieldTeam.enumerated()), id: \.element.id) { index, member in
                    memberCard(member, index: index)
                }
            }
        }
        .onAppear { appeared = true }
    }

    private var teamSummary: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(onSiteCount)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    Text("/\(totalCount)")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.4))
                }
                Text("Active team members")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
            }
            Spacer()
            HStack(spacing: 3) {
                ForEach(fieldTeam.prefix(8)) { m in
                    Circle()
                        .fill(m.isActive ? araGreen : Color.white.opacity(0.2))
                        .frame(width: 7, height: 7)
                }
            }
        }
        .padding(16)
        .glassCard()
        .clipShape(.rect(cornerRadius: 16))
    }

    private func memberCard(_ member: UserAccount, index: Int) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.08))
                    .overlay {
                        Circle().strokeBorder(.white.opacity(0.12), lineWidth: 0.5)
                    }
                Text(member.initials)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(member.fullName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                Text(roleLabel(member.role))
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(member.isActive ? araGreen : Color.white.opacity(0.3))
                        .frame(width: 6, height: 6)
                    Text(member.isActive ? "Active" : "Inactive")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
        }
        .padding(14)
        .glassCard()
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.spring(response: 0.4).delay(Double(index) * 0.06), value: appeared)
    }

    private func roleLabel(_ role: UserRole) -> String {
        switch role {
        case .executive: return "Executive"
        case .manager: return "Manager"
        case .supervisor: return "Site Supervisor"
        case .fieldWorker: return "Field Worker"
        case .contractor: return "Contractor"
        case .admin: return "Administrator"
        case .finance: return "Finance"
        case .hr: return "HR"
        case .it: return "IT"
        case .support: return "Support"
        case .client: return "Client"
        case .guest: return "Guest"
        }
    }
}
