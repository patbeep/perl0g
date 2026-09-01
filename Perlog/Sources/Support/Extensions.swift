import SwiftUI
import UIKit

extension Color {
    /// Builds a `Color` from a 6-digit hex string like "8E8E93" (an
    /// optional leading "#" is tolerated). Falls back to gray on any
    /// malformed input rather than crashing.
    init(hex: String) {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if sanitized.hasPrefix("#") { sanitized.removeFirst() }

        guard sanitized.count == 6, let value = UInt32(sanitized, radix: 16) else {
            self = .gray
            return
        }

        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }

    /// A reasonably stable hex string for persisting a picked color.
    var hexString: String {
        let resolved = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(
            format: "%02X%02X%02X",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255)
        )
    }
}

extension Date {
    /// True if this date falls on the same month and day as `other`,
    /// regardless of year — used to power the "On this day" memories.
    func isSameMonthAndDay(as other: Date, calendar: Calendar = .current) -> Bool {
        let lhs = calendar.dateComponents([.month, .day], from: self)
        let rhs = calendar.dateComponents([.month, .day], from: other)
        return lhs.month == rhs.month && lhs.day == rhs.day
    }

    var yearsAgoDescription: String {
        let years = Calendar.current.dateComponents([.year], from: self, to: .now).year ?? 0
        if years <= 0 { return "This year" }
        return years == 1 ? "1 year ago" : "\(years) years ago"
    }
}
