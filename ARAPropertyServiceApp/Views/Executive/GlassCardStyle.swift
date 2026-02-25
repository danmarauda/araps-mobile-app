import SwiftUI

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.08), .white.opacity(0.02)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.15), .white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    }
            }
            .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
    }
}

struct MutedGlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial.opacity(0.5))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.white.opacity(0.06), lineWidth: 0.5)
                    }
            }
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCard())
    }

    func mutedGlassCard() -> some View {
        modifier(MutedGlassCard())
    }
}

let araGreen = Color(red: 163/255, green: 197/255, blue: 39/255)
let araDarkBg = Color(red: 10/255, green: 15/255, blue: 10/255)
