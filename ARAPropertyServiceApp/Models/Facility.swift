import Foundation
import SwiftData

@Model
final class Facility {
    var id: UUID
    var facilityId: String
    var name: String
    var type: String
    var address: String
    var suburb: String
    var state: String
    var postcode: String
    var region: String
    var services: [String]
    var clientName: String
    var complianceRating: Double
    var lastISOAudit: Date?
    var nextScheduledService: Date
    var accessInstructions: String?
    var safetyNotes: String?

    init(
        facilityId: String,
        name: String,
        type: String,
        address: String,
        suburb: String,
        state: String,
        postcode: String,
        region: String,
        services: [String],
        clientName: String,
        complianceRating: Double,
        lastISOAudit: Date? = nil,
        nextScheduledService: Date,
        accessInstructions: String? = nil,
        safetyNotes: String? = nil
    ) {
        self.id = UUID()
        self.facilityId = facilityId
        self.name = name
        self.type = type
        self.address = address
        self.suburb = suburb
        self.state = state
        self.postcode = postcode
        self.region = region
        self.services = services
        self.clientName = clientName
        self.complianceRating = complianceRating
        self.lastISOAudit = lastISOAudit
        self.nextScheduledService = nextScheduledService
        self.accessInstructions = accessInstructions
        self.safetyNotes = safetyNotes
    }
}
