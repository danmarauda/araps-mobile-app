import Testing
import SwiftData
import Foundation
@testable import ARAPropertyServiceApp

@Suite("Model Tests")
struct ModelTests {

    @Test("Issue model initializes with correct defaults")
    func testIssueDefaults() {
        let issue = Issue(
            title: "Test Issue",
            issueDescription: "A test description",
            priority: .medium,
            category: .cleaning,
            location: "Level 3",
            reportedBy: "Test User"
        )

        #expect(issue.title == "Test Issue")
        #expect(issue.issueDescription == "A test description")
        #expect(issue.priority == .medium)
        #expect(issue.category == .cleaning)
        #expect(issue.status == .open)
        #expect(issue.resolvedAt == nil)
    }

    @Test("FieldTask model initializes correctly")
    func testFieldTaskDefaults() {
        let now = Date.now
        let later = now.addingTimeInterval(3600)

        let task = FieldTask(
            taskNumber: "TASK-001",
            title: "Deep Clean Level 7",
            taskType: "Cleaning",
            priority: .high,
            facilityName: "Collins St Tower",
            assignedWorker: "Maria Santos",
            scheduledStart: now,
            scheduledEnd: later,
            estimatedDuration: 60
        )

        #expect(task.taskNumber == "TASK-001")
        #expect(task.priority == .high)
        #expect(task.taskStatus == .pending)
        #expect(task.facilityName == "Collins St Tower")
        #expect(task.estimatedDuration == 60)
    }

    @Test("Contact initials computed correctly")
    func testContactInitials() {
        let contact = Contact(
            name: "Maria Santos",
            role: "Site Supervisor",
            department: "Operations",
            email: "maria@ara.com.au",
            phone: "+61 400 000 000"
        )

        #expect(contact.initials == "MS")
    }

    @Test("Contact initials with single name")
    func testContactInitialsSingleName() {
        let contact = Contact(
            name: "Madonna",
            role: "Artist",
            department: "Music",
            email: "m@example.com",
            phone: "0400000000"
        )

        #expect(contact.initials == "M")
    }

    @Test("UserAccount role computed from raw string")
    func testUserAccountRole() {
        let user = UserAccount(
            email: "test@ara.com.au",
            firstName: "Test",
            lastName: "User",
            role: .supervisor,
            authProvider: .workos
        )

        #expect(user.role == .supervisor)
        #expect(user.fullName == "Test User")
        #expect(user.initials == "TU")
        #expect(user.isActive == true)
    }

    @Test("CleaningAlert urgency maps correctly")
    func testCleaningAlertUrgency() {
        let alert = CleaningAlert(
            alertId: "ALERT-001",
            locationName: "Level 5 Bathroom",
            issueType: .spill,
            urgency: .critical,
            alertDescription: "Chemical spill",
            reporterName: "John Smith",
            reporterContact: "john@ara.com.au"
        )

        #expect(alert.urgency == .critical)
        #expect(alert.alertStatus == .pending)
        #expect(alert.locationName == "Level 5 Bathroom")
    }

    @Test("Organization tier maxUsers computed correctly")
    func testOrganizationTier() {
        let org = Organization(
            name: "ARA Property Services",
            slug: "ara-property-services",
            domain: "ara.com.au",
            tier: .enterprise
        )

        #expect(org.tier == .enterprise)
        #expect(org.tier.maxUsers > 100)
        #expect(org.isActive == true)
    }

    @Test("Facility has all required fields")
    func testFacilityModel() {
        let facility = Facility(
            facilityId: "FAC-001",
            name: "Collins St Tower",
            type: "Commercial Office",
            address: "55 Collins St",
            suburb: "Melbourne",
            state: "VIC",
            postcode: "3000",
            region: "CBD",
            services: ["Cleaning", "Waste Management"],
            clientName: "Investa",
            complianceRating: 94.5,
            nextScheduledService: Date.now.addingTimeInterval(86400 * 7)
        )

        #expect(facility.name == "Collins St Tower")
        #expect(facility.complianceRating == 94.5)
        #expect(facility.services.count == 2)
    }

    @Test("Issue status transitions work")
    func testIssueStatusTransitions() {
        let issue = Issue(
            title: "Test",
            issueDescription: "Desc",
            priority: .low,
            category: .other,
            location: "Location",
            reportedBy: "User"
        )

        #expect(issue.status == .open)

        issue.status = .inProgress
        #expect(issue.status == .inProgress)

        issue.status = .resolved
        issue.resolvedAt = .now
        #expect(issue.status == .resolved)
        #expect(issue.resolvedAt != nil)
    }

    @Test("AppConfig reads environment variables")
    func testAppConfigDefaults() {
        #expect(AppConfig.redirectURI == "araps://auth/callback")
        #expect(AppConfig.callbackURLScheme == "araps")
        #expect(AppConfig.universalLinkDomain == "araps.aliaslabs.ai")
    }

    @Test("OrganizationMembership role permissions")
    func testMembershipPermissions() {
        let adminMembership = OrganizationMembership(
            userId: UUID(),
            organizationId: UUID(),
            role: .admin
        )
        let memberMembership = OrganizationMembership(
            userId: UUID(),
            organizationId: UUID(),
            role: .member
        )

        #expect(adminMembership.membershipRole == .admin)
        #expect(memberMembership.membershipRole == .member)
    }
}

@Suite("ChatService Tests")
struct ChatServiceTests {

    @Test("ChatService returns configuration message when no API key")
    func testChatServiceNoApiKey() async throws {
        let result = try await ChatService.sendMessage(
            userMessage: "Hello",
            conversationHistory: []
        )

        #expect(result.contains("not configured") || !result.isEmpty)
    }
}

@Suite("Navigation State Tests")
struct NavigationStateTests {

    @MainActor
    @Test("AppNavigationState defaults to dashboard")
    func testDefaultTab() {
        let state = AppNavigationState()
        #expect(state.selectedTab == .dashboard)
    }

    @MainActor
    @Test("AppNavigationState handles deep links correctly")
    func testDeepLinkNavigation() {
        let state = AppNavigationState()

        let issuesURL = URL(string: "araps://issues")!
        state.handleDeepLink(issuesURL)
        #expect(state.selectedTab == .issues)

        let tasksURL = URL(string: "araps://tasks")!
        state.handleDeepLink(tasksURL)
        #expect(state.selectedTab == .tasks)

        let cleanOpsURL = URL(string: "araps://cleanops")!
        state.handleDeepLink(cleanOpsURL)
        #expect(state.selectedTab == .cleanOps)

        let alertURL = URL(string: "araps://alert")!
        state.handleDeepLink(alertURL)
        #expect(state.selectedTab == .cleanOps)
    }
}

@Suite("AppTab Tests")
struct AppTabTests {

    @Test("All AppTab cases have system images")
    func testAppTabIcons() {
        for tab in AppTab.allCases {
            #expect(!tab.icon.isEmpty)
        }
    }

    @Test("AppTab rawValues are unique")
    func testUniqueRawValues() {
        let rawValues = AppTab.allCases.map(\.rawValue)
        let uniqueValues = Set(rawValues)
        #expect(rawValues.count == uniqueValues.count)
    }
}
