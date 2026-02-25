import SwiftUI

struct KPICardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String?

    init(title: String, value: String, icon: String, color: Color, trend: String? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.trend = trend
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                Spacer()
                if let trend {
                    Text(trend)
                        .font(.caption.bold())
                        .foregroundStyle(trend.hasPrefix("+") ? .green : .secondary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }
}
