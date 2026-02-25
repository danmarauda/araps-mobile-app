import SwiftUI
import SwiftData

@main
struct ARAPSMobileAppApp: App {
    @State private var authVM = AuthViewModel()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Issue.self,
            Contact.self,
            FieldTask.self,
            ChatMessage.self,
            Facility.self,
            CleaningAlert.self,
            AppNotification.self,
            UserAccount.self,
            Organization.self,
            OrganizationMembership.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView(authVM: authVM)
                .preferredColorScheme(.dark)
                .onAppear {
                    authVM.configure(modelContext: sharedModelContainer.mainContext)
                    SeedData.seedIfNeeded(context: sharedModelContainer.mainContext)
                    authVM.checkAuthState()
                }
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }

        if components.host == "auth" && components.path == "/callback" {
            return
        }

        NotificationCenter.default.post(
            name: .araDeepLink,
            object: nil,
            userInfo: ["url": url]
        )
    }
}

extension Notification.Name {
    static let araDeepLink = Notification.Name("com.arapropertyservices.araps.deeplink")
}
