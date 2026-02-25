import SwiftUI

nonisolated enum ExecScreen: String, Sendable {
    case widget, kpis, safety, meetings, jobs, team, revenue, report
}

struct ExecDashboardView: View {
    let authVM: AuthViewModel
    @State private var screen: ExecScreen = .widget
    @State private var appeared: Bool = false

    var body: some View {
        ZStack {
            araDarkBg.ignoresSafeArea()

            Canvas { context, size in
                context.fill(
                    Path(ellipseIn: CGRect(x: -60, y: -60, width: 280, height: 280)),
                    with: .color(araGreen.opacity(0.12))
                )
                context.fill(
                    Path(ellipseIn: CGRect(x: size.width - 140, y: size.height - 140, width: 280, height: 280)),
                    with: .color(Color.blue.opacity(0.08))
                )
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            switch screen {
            case .widget:
                ExecWidgetHomeView(onNavigate: navigate)
                    .transition(.opacity)
            case .kpis:
                ExecKPIsView(onBack: back)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .safety:
                ExecSafetyView(onBack: back)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .meetings:
                ExecMeetingsView(onBack: back)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .jobs:
                ExecJobsView(onBack: back)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .team:
                ExecTeamView(onBack: back)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .revenue:
                ExecRevenueView(onBack: back)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .report:
                ExecReportView(onBack: back)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.88), value: screen)
    }

    private func navigate(_ s: ExecScreen) {
        screen = s
    }

    private func back() {
        screen = .widget
    }
}
