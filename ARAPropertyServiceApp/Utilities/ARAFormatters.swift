import Foundation

/// Shared, pre-allocated formatters for the ARA app.
/// DateFormatter creation is expensive — these are static singletons,
/// allocated once and reused across all views.
enum ARAFormatters {

    static let timeAU: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        f.locale = Locale(identifier: "en_AU")
        return f
    }()

    static let dateAU: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, d MMMM"
        f.locale = Locale(identifier: "en_AU")
        return f
    }()

    static let monthYearAU: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        f.locale = Locale(identifier: "en_AU")
        return f
    }()

    static let mediumDateAU: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.locale = Locale(identifier: "en_AU")
        return f
    }()

    static let shortTimeAU: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE d MMM"
        f.locale = Locale(identifier: "en_AU")
        return f
    }()

    /// Formats a date for scheduling context — "Today 9:00 AM", "Tomorrow 2:30 PM", or "Mon 3 Feb"
    static func scheduleLabel(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return timeAU.string(from: date)
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow " + timeAU.string(from: date)
        } else {
            return shortTimeAU.string(from: date)
        }
    }
}
