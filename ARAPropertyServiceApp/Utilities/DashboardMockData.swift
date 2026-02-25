import Foundation

enum DashboardMockData {
    static let kpis: [DashboardKPI] = [
        DashboardKPI(label: "Revenue (MTD)", value: "$284K", sub: "Target $310K", trend: .up, trendValue: "+8.2%", good: true, icon: "dollarsign.circle.fill", iconColor: "green"),
        DashboardKPI(label: "Client Satisfaction", value: "94.6%", sub: "46 sites rated", trend: .up, trendValue: "+1.3%", good: true, icon: "star.fill", iconColor: "yellow"),
        DashboardKPI(label: "Jobs Completed", value: "312", sub: "This month", trend: .up, trendValue: "+22 vs last", good: true, icon: "checkmark.seal.fill", iconColor: "blue"),
        DashboardKPI(label: "Outstanding Invoices", value: "$41.2K", sub: "7 invoices", trend: .down, trendValue: "-$6K", good: false, icon: "doc.text.fill", iconColor: "red"),
        DashboardKPI(label: "Staff Utilisation", value: "87%", sub: "52 of 60 active", trend: .up, trendValue: "+4%", good: true, icon: "person.3.fill", iconColor: "blue"),
        DashboardKPI(label: "Incidents (MTD)", value: "2", sub: "0 critical", trend: .down, trendValue: "-3 vs last", good: true, icon: "shield.checkered", iconColor: "green")
    ]
    
    static let safetyAlerts: [DashboardSafetyAlert] = [
        DashboardSafetyAlert(id: "s1", severity: .critical, site: "Collins St Tower", message: "Chemical spill reported — Level 12 bathroom. Crew isolated area.", time: "08:14 AM", resolved: false),
        DashboardSafetyAlert(id: "s2", severity: .warning, site: "Docklands Precinct", message: "Staff member slipped on wet surface. First aid administered.", time: "Yesterday", resolved: false),
        DashboardSafetyAlert(id: "s3", severity: .warning, site: "Southbank Centre", message: "Expired MSDS sheets for Exitoclean. Needs replacement.", time: "2 days ago", resolved: false),
        DashboardSafetyAlert(id: "s4", severity: .info, site: "Richmond Office Park", message: "SWMS updated and signed off by site team.", time: "3 days ago", resolved: true),
        DashboardSafetyAlert(id: "s5", severity: .info, site: "Melbourne Central", message: "Monthly safety toolbox talk completed. 8/8 attended.", time: "4 days ago", resolved: true)
    ]
    
    static let meetings: [DashboardMeeting] = [
        DashboardMeeting(id: "m1", title: "Q4 Client Review — Investa", time: "10:00 AM", date: "Today", type: .review, attendees: 5, location: "Zoom"),
        DashboardMeeting(id: "m2", title: "Site Supervisor Standup", time: "7:30 AM", date: "Tomorrow", type: .team, attendees: 8, location: "ARA Head Office"),
        DashboardMeeting(id: "m3", title: "Safety Committee Meeting", time: "2:00 PM", date: "Wed 22 Jan", type: .safety, attendees: 6, location: "Teams"),
        DashboardMeeting(id: "m4", title: "New Contract — CBRE Onboarding", time: "11:00 AM", date: "Thu 23 Jan", type: .client, attendees: 4, location: "Level 8, 80 Collins St"),
        DashboardMeeting(id: "m5", title: "Monthly KPI Review", time: "3:30 PM", date: "Fri 24 Jan", type: .review, attendees: 3, location: "Zoom")
    ]
    
    static let jobs: [DashboardJob] = [
        DashboardJob(id: "j1", site: "Collins St Tower", address: "55 Collins St, Melbourne", status: .inProgress, team: "Team Alpha", time: "Since 6:00 AM", score: 4.8),
        DashboardJob(id: "j2", site: "Docklands Precinct", address: "NewQuay Promenade", status: .issue, team: "Team Bravo", time: "Since 5:30 AM", score: nil),
        DashboardJob(id: "j3", site: "Southbank Centre", address: "3 Southgate Ave", status: .completed, team: "Team Charlie", time: "Done 9:45 AM", score: 4.9),
        DashboardJob(id: "j4", site: "Richmond Office Park", address: "620 Church St", status: .completed, team: "Team Delta", time: "Done 8:30 AM", score: 4.6),
        DashboardJob(id: "j5", site: "Melbourne Central", address: "300 Lonsdale St", status: .scheduled, team: "Team Echo", time: "Starts 2:00 PM", score: nil),
        DashboardJob(id: "j6", site: "South Yarra Plaza", address: "627 Chapel St", status: .scheduled, team: "Team Foxtrot", time: "Starts 4:00 PM", score: nil)
    ]
    
    static let teamMembers: [DashboardTeamMember] = [
        DashboardTeamMember(id: "t1", name: "Maria Santos", role: "Site Supervisor", site: "Collins St Tower", status: .onSite, hrs: "4.2h"),
        DashboardTeamMember(id: "t2", name: "James Nguyen", role: "Senior Cleaner", site: "Docklands Precinct", status: .onSite, hrs: "4.7h"),
        DashboardTeamMember(id: "t3", name: "Sarah Kowalski", role: "Site Supervisor", site: "Southbank Centre", status: .onSite, hrs: "3.8h"),
        DashboardTeamMember(id: "t4", name: "Ahmed Hassan", role: "Cleaner", site: "In Transit", status: .transit, hrs: "0.5h"),
        DashboardTeamMember(id: "t5", name: "Lily Park", role: "Senior Cleaner", site: "Richmond Office Park", status: .onSite, hrs: "3.1h"),
        DashboardTeamMember(id: "t6", name: "David Tran", role: "Cleaner", site: "Off Duty", status: .off, hrs: "—")
    ]
    
    static let revenueBreakdown: [RevenueBreakdown] = [
        RevenueBreakdown(label: "Commercial Office", value: "$142K", percentage: 0.50),
        RevenueBreakdown(label: "Retail Centres", value: "$78K", percentage: 0.27),
        RevenueBreakdown(label: "Industrial Sites", value: "$41K", percentage: 0.14),
        RevenueBreakdown(label: "Government Contracts", value: "$23K", percentage: 0.09)
    ]
    
    static let monthlyRevenue: [MonthlyRevenue] = [
        MonthlyRevenue(month: "Aug", value: 68),
        MonthlyRevenue(month: "Sep", value: 74),
        MonthlyRevenue(month: "Oct", value: 71),
        MonthlyRevenue(month: "Nov", value: 80),
        MonthlyRevenue(month: "Dec", value: 77),
        MonthlyRevenue(month: "Jan", value: 92)
    ]
}
