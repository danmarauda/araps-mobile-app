import SwiftUI

struct ExecRevenueView: View {
    let onBack: () -> Void
    @State private var appeared: Bool = false

    var body: some View {
        ExecScreenWrapper(title: "Revenue Overview", onBack: onBack) {
            comingSoonCard
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(.spring(response: 0.4).delay(0.05), value: appeared)

            featuresCard
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
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(araGreen)
            }

            VStack(spacing: 6) {
                Text("Revenue Analytics")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Text("Financial reporting and revenue tracking will be available in a future update.")
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

    private var featuresCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Planned Features")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.35))
                .textCase(.uppercase)
                .tracking(1)

            ForEach([
                ("chart.line.uptrend.xyaxis", "Month-to-date revenue tracking"),
                ("building.2.fill", "Revenue breakdown by site"),
                ("doc.text.fill", "Invoice management and status"),
                ("arrow.up.right.circle.fill", "Year-over-year trend analysis"),
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
