import SwiftUI

struct ExecMeetingsView: View {
    let onBack: () -> Void
    @State private var appeared: Bool = false

    var body: some View {
        ExecScreenWrapper(title: "Meetings & Schedule", onBack: onBack) {
            comingSoonCard
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(.spring(response: 0.4).delay(0.05), value: appeared)

            calendarIntegrationCard
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(.spring(response: 0.4).delay(0.12), value: appeared)
        }
        .onAppear { appeared = true }
    }

    private var comingSoonCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(araGreen.opacity(0.1))
                    .frame(width: 64, height: 64)
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 28))
                    .foregroundStyle(araGreen)
            }

            VStack(spacing: 6) {
                Text("Calendar Integration")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Text("Meeting scheduling and calendar sync coming in the next release.")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            Text("Coming Soon")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(araGreen)
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .background {
                    Capsule().fill(araGreen.opacity(0.12))
                        .overlay { Capsule().strokeBorder(araGreen.opacity(0.25), lineWidth: 0.5) }
                }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .glassCard()
        .clipShape(.rect(cornerRadius: 16))
    }

    private var calendarIntegrationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Planned Features")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.35))
                .textCase(.uppercase)
                .tracking(1)

            ForEach([
                ("calendar.badge.plus", "Schedule and track team meetings"),
                ("bell.badge.fill", "Automated reminders and notifications"),
                ("person.2.badge.key.fill", "Client meeting management"),
                ("chart.bar.doc.horizontal.fill", "Meeting notes and action items"),
            ], id: \.0) { icon, text in
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(araGreen.opacity(0.7))
                        .frame(width: 20)
                    Text(text)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .padding(16)
        .glassCard()
        .clipShape(.rect(cornerRadius: 16))
    }
}
