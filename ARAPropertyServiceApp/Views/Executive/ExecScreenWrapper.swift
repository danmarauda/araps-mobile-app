import SwiftUI

struct ExecScreenWrapper<Content: View>: View {
    let title: String
    let onBack: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(.white.opacity(0.08)))
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)

            ScrollView {
                VStack(spacing: 10) {
                    content
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
        }
    }
}
