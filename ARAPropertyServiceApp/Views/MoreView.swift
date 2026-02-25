import SwiftUI

struct MoreView: View {
    let authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Operations") {
                    NavigationLink {
                        CleanOpsView()
                    } label: {
                        Label("CleanOps", systemImage: "qrcode.viewfinder")
                    }

                    NavigationLink {
                        FacilitiesListView()
                    } label: {
                        Label("Properties", systemImage: "building.2.fill")
                    }

                    NavigationLink {
                        ContactsListView()
                    } label: {
                        Label("Contacts", systemImage: "person.2.fill")
                    }
                }

                Section("Reports") {
                    NavigationLink {
                        ReportsView()
                    } label: {
                        Label("Reports & Analytics", systemImage: "chart.bar.fill")
                    }
                }

                Section("App") {
                    NavigationLink {
                        SettingsView(authVM: authVM)
                    } label: {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("More")
        }
    }
}
