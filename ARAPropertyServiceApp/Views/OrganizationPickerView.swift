import SwiftUI

struct OrganizationPickerView: View {
    let organizations: [Organization]
    let onSelect: (Organization) -> Void
    @State private var appeared = false

    var body: some View {
        ZStack {
            araDarkBg.ignoresSafeArea()

            Canvas { context, size in
                context.fill(
                    Path(ellipseIn: CGRect(x: size.width - 160, y: -80, width: 280, height: 280)),
                    with: .color(araGreen.opacity(0.06))
                )
                context.fill(
                    Path(ellipseIn: CGRect(x: -60, y: size.height - 200, width: 240, height: 240)),
                    with: .color(Color.blue.opacity(0.04))
                )
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(araGreen.opacity(0.12))
                            .frame(width: 64, height: 64)
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(araGreen)
                    }

                    VStack(spacing: 6) {
                        Text("Select Organisation")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)

                        Text("Choose the organisation you're working in")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 72)
                .padding(.horizontal, 32)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : -12)
                .animation(.spring(response: 0.6, dampingFraction: 0.85), value: appeared)

                Spacer().frame(height: 40)

                // Org list
                VStack(spacing: 10) {
                    ForEach(Array(organizations.enumerated()), id: \.element.id) { index, org in
                        OrgCard(org: org, index: index, appeared: appeared) {
                            onSelect(org)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Footer
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                    Text("Access is limited to your assigned organisation")
                        .font(.system(size: 11))
                }
                .foregroundStyle(.white.opacity(0.2))
                .padding(.bottom, 40)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: appeared)
            }
        }
        .onAppear { appeared = true }
    }
}

private struct OrgCard: View {
    let org: Organization
    let index: Int
    let appeared: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Org initials badge
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(araGreen.opacity(0.14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(araGreen.opacity(0.22), lineWidth: 0.5)
                        }
                        .frame(width: 52, height: 52)

                    Text(org.initials)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(araGreen)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(org.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text(org.tier.label)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(araGreen.opacity(0.75))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background {
                                Capsule().fill(araGreen.opacity(0.1))
                            }

                        if let domain = org.domain {
                            Text("·")
                                .foregroundStyle(.white.opacity(0.2))
                            Text(domain)
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.35))
                                .lineLimit(1)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.2))
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white.opacity(0.06))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.14), .white.opacity(0.04)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    }
            }
        }
        .buttonStyle(.plain)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(.spring(response: 0.55, dampingFraction: 0.85).delay(0.1 + Double(index) * 0.07), value: appeared)
    }
}

private extension Organization {
    var initials: String {
        let parts = name.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let second = parts.dropFirst().first?.prefix(1) ?? ""
        return "\(first)\(second)".uppercased()
    }
}
