import SwiftUI

struct WidgetTileView: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    let sub: String
    let hasAlert: Bool
    let delay: Double
    let appeared: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(iconColor)
                    Spacer()
                    if hasAlert {
                        Circle()
                            .fill(.red)
                            .frame(width: 7, height: 7)
                            .symbolEffect(.pulse)
                    }
                }
                .padding(.bottom, 10)

                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.45))
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .padding(.bottom, 3)

                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                if !sub.isEmpty {
                    Text(sub)
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.3))
                        .lineLimit(1)
                        .padding(.top, 3)
                }

                Spacer(minLength: 0)

                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.2))
                }
            }
            .padding(14)
            .frame(minHeight: 130)
            .glassCard()
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.94)
        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(delay), value: appeared)
    }
}
