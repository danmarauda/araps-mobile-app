import Foundation
import SwiftData

struct SeedData {
    static func seedIfNeeded(context: ModelContext) {
        let issueDescriptor = FetchDescriptor<Issue>()
        let existingCount = (try? context.fetchCount(issueDescriptor)) ?? 0
        guard existingCount == 0 else { return }

        seedOrganizationsAndUsers(context: context)
        seedIssues(context: context)
        seedContacts(context: context)
        seedTasks(context: context)
        seedFacilities(context: context)
        seedAlerts(context: context)
        seedNotifications(context: context)

        try? context.save()
    }

    private static func seedOrganizationsAndUsers(context: ModelContext) {
        let org = Organization(
            name: "ARA Property Services",
            slug: "ara-property-services",
            domain: "ara.com.au",
            tier: .enterprise
        )
        context.insert(org)

        let users: [(String, String, String, UserRole)] = [
            ("Paul", "McCann", "paul.mccann@ara.com.au", .ceo),
            ("Shannon", "Laffey", "shannon.laffey@ara.com.au", .execGeneralManager),
            ("Phil", "Bailey", "phil.bailey@ara.com.au", .nationalOpsManager),
            ("Ranuka", "Fernando", "ranuka.fernando@ara.com.au", .stateManager),
            ("Ashley", "Folbigg", "ashley.folbigg@ara.com.au", .stateManager),
            ("Margaret", "Fayers", "margaret.fayers@ara.com.au", .accountManager),
            ("demo", "user", "demo@ara.com.au", .fieldWorker),
        ]

        for u in users {
            let user = UserAccount(
                email: u.2,
                firstName: u.0,
                lastName: u.1,
                role: u.3,
                authProvider: .email,
                organizationId: org.id
            )
            context.insert(user)

            let memberRole: MembershipRole = u.3 == .ceo ? .owner : (u.3 == .execGeneralManager ? .admin : .member)
            let membership = OrganizationMembership(
                userId: user.id,
                organizationId: org.id,
                role: memberRole
            )
            context.insert(membership)
        }
    }

    private static func seedIssues(context: ModelContext) {
        let issues: [(String, String, IssueStatus, IssuePriority, IssueCategory, String, String, String?, Int)] = [
            ("Leaking pipe in L7 Kitchen", "Water dripping from under the sink cabinet. Forming a puddle on the floor.", .open, .high, .plumbing, "Level 7 Kitchen", "Margaret Fayers", "Phil Bailey", -2),
            ("HVAC not cooling Level 8", "Temperature on Level 8 has been consistently above 26°C. Multiple complaints from staff.", .inProgress, .high, .hvac, "Level 8 Office", "Shannon Laffey", "Ranuka Fernando", -5),
            ("Broken light fixture in corridor", "Fluorescent tube flickering in the main corridor near elevator bank.", .open, .medium, .electrical, "Level 7 Corridor", "Sam Croxall", nil, -1),
            ("Carpet stain in reception", "Large coffee stain on the carpet near the reception desk. Needs deep cleaning.", .resolved, .low, .cleaning, "Level 8 Reception", "Charlie Dewage", "Ashley Folbigg", -10),
            ("Crack in partition wall", "Visible crack running diagonally across the glass partition in Meeting Room 3.", .open, .critical, .structural, "Level 7 Meeting Room 3", "Gaurav Majumdar", "Phil Bailey", 0),
            ("Toilet flush mechanism broken", "Male toilet on Level 7 - flush mechanism stuck. Requires replacement.", .inProgress, .high, .plumbing, "L7 Male Toilet", "Josh Beckman", nil, -3),
            ("Emergency exit sign dim", "Emergency exit sign above stairwell B is barely visible. Battery may need replacement.", .open, .critical, .electrical, "Stairwell B", "Kaveesha Mahanama", "Phil Bailey", -1),
            ("Air freshener dispenser empty", "Dispenser in L7 Female Toilet needs refill.", .resolved, .low, .cleaning, "L7 Female Toilet", "Cath Pichut", "Ashley Folbigg", -7),
        ]

        for issue in issues {
            let i = Issue(
                title: issue.0,
                issueDescription: issue.1,
                status: issue.2,
                priority: issue.3,
                category: issue.4,
                location: issue.5,
                reportedBy: issue.6,
                assignedTo: issue.7,
                reportedAt: Calendar.current.date(byAdding: .day, value: issue.8, to: .now) ?? .now
            )
            context.insert(i)
        }
    }

    private static func seedContacts(context: ModelContext) {
        let contacts: [(String, String, String, String, String)] = [
            ("Paul McCann", "CEO", "Executive", "paul.mccann@ara.com.au", "+61 2 9000 1001"),
            ("Shannon Laffey", "Exec General Manager", "Executive", "shannon.laffey@ara.com.au", "+61 2 9000 1002"),
            ("Phil Bailey", "National Ops Manager", "Operations", "phil.bailey@ara.com.au", "+61 2 9000 1003"),
            ("Ranuka Fernando", "State Manager - VIC", "Operations", "ranuka.fernando@ara.com.au", "+61 3 9000 2001"),
            ("Ashley Folbigg", "State Manager - NSW", "Operations", "ashley.folbigg@ara.com.au", "+61 2 9000 2002"),
            ("Margaret Fayers", "Account Manager", "Client Services", "margaret.fayers@ara.com.au", "+61 2 9000 3001"),
            ("Sam Croxall", "Account Manager", "Client Services", "sam.croxall@ara.com.au", "+61 2 9000 3002"),
            ("Charlie Dewage", "Client Relationship Mgr", "Client Services", "charlie.dewage@ara.com.au", "+61 2 9000 3003"),
            ("Mark Norton", "Finance Manager", "Finance", "mark.norton@ara.com.au", "+61 2 9000 4001"),
            ("Sophie Feng", "Financial Controller", "Finance", "sophie.feng@ara.com.au", "+61 2 9000 4002"),
            ("Linh Vu", "Accounts Payable", "Finance", "linh.vu@ara.com.au", "+61 2 9000 4003"),
            ("Kaveesha Mahanama", "People & Safety Lead", "People & Safety", "kaveesha.mahanama@ara.com.au", "+61 2 9000 5001"),
            ("Josh Beckman", "HSE Coordinator", "People & Safety", "josh.beckman@ara.com.au", "+61 2 9000 5002"),
            ("Gaurav Majumdar", "CX Manager", "CX & Compliance", "gaurav.majumdar@ara.com.au", "+61 2 9000 6001"),
            ("Cath Pichut", "Compliance Officer", "CX & Compliance", "cath.pichut@ara.com.au", "+61 2 9000 6002"),
        ]

        for c in contacts {
            let contact = Contact(name: c.0, role: c.1, department: c.2, email: c.3, phone: c.4)
            context.insert(contact)
        }
    }

    private static func seedTasks(context: ModelContext) {
        let now = Date.now
        let cal = Calendar.current

        let tasks: [(String, String, String, String, TaskPriority, TaskStatus, String, String, Int, Int, Int)] = [
            ("FT-001", "Deep Clean Level 7 Kitchen", "Full deep clean including appliances, surfaces, and floors", "Deep Clean", .high, .inProgress, "Tower A - Level 7", "Maria Santos", 0, 8, 120),
            ("FT-002", "Replace Air Filters L8", "Quarterly air filter replacement for all HVAC units on Level 8", "Maintenance", .medium, .assigned, "Tower A - Level 8", "James Wilson", 1, 9, 90),
            ("FT-003", "Safety Inspection Stairwells", "Monthly fire safety check of all stairwell exits and equipment", "Inspection", .high, .pending, "Tower A - All Floors", "David Kim", 2, 10, 180),
            ("FT-004", "Window Cleaning Exterior", "External window cleaning for floors 6-10", "Cleaning", .low, .pending, "Tower A - Levels 6-10", "External Crew", 3, 7, 480),
            ("FT-005", "Fix Broken Door Handle", "Meeting Room 5 door handle is loose, needs tightening or replacement", "Repair", .medium, .completed, "Tower A - Level 7", "James Wilson", -2, 14, 30),
            ("FT-006", "Restroom Deep Clean", "Full sanitization of all Level 7 restrooms", "Deep Clean", .high, .assigned, "Tower A - Level 7", "Maria Santos", 0, 14, 150),
        ]

        for t in tasks {
            let start = cal.date(byAdding: .day, value: t.8, to: now)!
            let startWithHour = cal.date(bySettingHour: t.9, minute: 0, second: 0, of: start)!
            let end = cal.date(byAdding: .minute, value: t.10, to: startWithHour)!

            let task = FieldTask(
                taskNumber: t.0,
                title: t.1,
                taskDescription: t.2,
                taskType: t.3,
                priority: t.4,
                status: t.5,
                facilityName: t.6,
                assignedWorker: t.7,
                scheduledStart: startWithHour,
                scheduledEnd: end,
                estimatedDuration: t.10
            )
            context.insert(task)
        }
    }

    private static func seedFacilities(context: ModelContext) {
        let facilities: [(String, String, String, String, String, String, String, String, [String], String, Double)] = [
            ("FAC-001", "Tower A - Sydney CBD", "Commercial Office", "100 George Street", "Sydney", "NSW", "2000", "NSW Metro", ["Cleaning", "Maintenance", "Security"], "Westpac", 94.5),
            ("FAC-002", "Melbourne Central Tower", "Commercial Office", "360 Elizabeth Street", "Melbourne", "VIC", "3000", "VIC Metro", ["Cleaning", "HVAC Maintenance"], "NAB", 91.2),
            ("FAC-003", "Brisbane Quarter", "Mixed Use", "300 George Street", "Brisbane", "QLD", "4000", "QLD Metro", ["Cleaning", "Landscaping", "Maintenance"], "Santos", 88.7),
            ("FAC-004", "Perth Business Hub", "Commercial Office", "125 St Georges Terrace", "Perth", "WA", "6000", "WA Metro", ["Cleaning", "Security"], "BHP", 96.1),
        ]

        for f in facilities {
            let facility = Facility(
                facilityId: f.0,
                name: f.1,
                type: f.2,
                address: f.3,
                suburb: f.4,
                state: f.5,
                postcode: f.6,
                region: f.7,
                services: f.8,
                clientName: f.9,
                complianceRating: f.10,
                nextScheduledService: Calendar.current.date(byAdding: .day, value: 3, to: .now)!
            )
            context.insert(facility)
        }
    }

    private static func seedAlerts(context: ModelContext) {
        let alerts: [(String, String, AlertIssueType, AlertUrgency, AlertStatus, String, String, String, Int)] = [
            ("ALERT-L7K-001", "Level 7 Kitchen", .cleaning, .high, .pending, "Coffee spill near microwave area", "John Smith", "john@example.com", 0),
            ("ALERT-L7MT-001", "L7 Male Toilet", .maintenance, .normal, .acknowledged, "Paper towel dispenser jammed", "Anonymous", "", -1),
            ("ALERT-L8K-001", "Level 8 Kitchen", .safety, .high, .inProgress, "Wet floor near dishwasher - slip hazard", "Sarah Jones", "sarah@company.com", 0),
        ]

        for a in alerts {
            let alert = CleaningAlert(
                alertId: a.0,
                locationName: a.1,
                issueType: a.2,
                urgency: a.3,
                status: a.4,
                alertDescription: a.5,
                reporterName: a.6,
                reporterContact: a.7,
                reportedAt: Calendar.current.date(byAdding: .hour, value: a.8 * 24, to: .now) ?? .now
            )
            context.insert(alert)
        }
    }

    private static func seedNotifications(context: ModelContext) {
        let notifications: [(String, String, String, Bool, Int)] = [
            ("New Issue Reported", "Crack in partition wall - Level 7 Meeting Room 3", "issue", false, 0),
            ("Task Assigned", "Deep Clean Level 7 Kitchen has been assigned to Maria Santos", "task", false, -1),
            ("Alert Acknowledged", "Paper towel dispenser alert has been acknowledged", "alert", true, -2),
            ("Compliance Due", "ISO audit for Tower A is due in 5 days", "compliance", false, -1),
        ]

        for n in notifications {
            let notif = AppNotification(
                title: n.0,
                body: n.1,
                type: n.2,
                isRead: n.3,
                createdAt: Calendar.current.date(byAdding: .day, value: n.4, to: .now) ?? .now
            )
            context.insert(notif)
        }
    }
}
