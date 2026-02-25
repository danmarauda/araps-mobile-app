import Foundation
import SwiftData

@Model
final class Contact {
    var id: UUID
    var name: String
    var role: String
    var department: String
    var email: String
    var phone: String
    var locationName: String?
    var isActive: Bool

    var initials: String {
        let parts = name.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.count > 1 ? parts.last!.prefix(1) : ""
        return "\(first)\(last)".uppercased()
    }

    init(
        name: String,
        role: String,
        department: String,
        email: String,
        phone: String,
        locationName: String? = nil,
        isActive: Bool = true
    ) {
        self.id = UUID()
        self.name = name
        self.role = role
        self.department = department
        self.email = email
        self.phone = phone
        self.locationName = locationName
        self.isActive = isActive
    }
}
