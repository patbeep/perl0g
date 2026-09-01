import Foundation
import SwiftData

/// The category of a log entry. Stored on the model as a raw string
/// (`typeRaw`) so SwiftData never has to persist an enum directly.
enum EntryType: String, Codable, CaseIterable, Identifiable, Hashable {
    case thought
    case photo
    case mood
    case place
    case person
    case meal
    case music
    case activity
    case task
    case milestone

    var id: String { rawValue }

    var title: String {
        switch self {
        case .thought: return "Thought"
        case .photo: return "Photo"
        case .mood: return "Mood"
        case .place: return "Place"
        case .person: return "Person"
        case .meal: return "Meal"
        case .music: return "Music"
        case .activity: return "Activity"
        case .task: return "Task"
        case .milestone: return "Milestone"
        }
    }

    var systemImage: String {
        switch self {
        case .thought: return "pencil.line"
        case .photo: return "photo.on.rectangle.angled"
        case .mood: return "face.smiling"
        case .place: return "mappin.and.ellipse"
        case .person: return "person.2.fill"
        case .meal: return "fork.knife"
        case .music: return "music.note"
        case .activity: return "figure.walk"
        case .task: return "checkmark.circle"
        case .milestone: return "star.fill"
        }
    }

    /// Base hue (0-1) used to tint this entry type's badge when the
    /// theme is in "Iridescent" mode; other themes override this.
    var baseHue: Double {
        switch self {
        case .thought: return 0.58
        case .photo: return 0.75
        case .mood: return 0.12
        case .place: return 0.55
        case .person: return 0.83
        case .meal: return 0.05
        case .music: return 0.92
        case .activity: return 0.38
        case .task: return 0.62
        case .milestone: return 0.13
        }
    }
}

enum Mood: String, Codable, CaseIterable, Identifiable {
    case great, good, okay, low, rough

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .great: return "😄"
        case .good: return "🙂"
        case .okay: return "😐"
        case .low: return "😕"
        case .rough: return "😣"
        }
    }

    var label: String {
        switch self {
        case .great: return "Great"
        case .good: return "Good"
        case .okay: return "Okay"
        case .low: return "Low"
        case .rough: return "Rough"
        }
    }
}

@Model
final class LogEntry {
    var id: UUID = UUID()
    var date: Date = Date.now
    var typeRaw: String = EntryType.thought.rawValue
    var title: String = ""
    var content: String = ""
    var moodRaw: String?

    // Place
    var placeName: String?
    var latitude: Double?
    var longitude: Double?

    // Media
    var photoData: [Data] = []

    // Meal
    var mealCategory: String?

    // Music / media
    var mediaTitle: String?
    var mediaArtist: String?

    // Activity
    var measurementValue: Double?
    var measurementUnit: String?

    // Task
    var isTask: Bool = false
    var isCompleted: Bool = false
    var dueDate: Date?

    // Milestone
    var isMilestone: Bool = false

    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    @Relationship(deleteRule: .nullify, inverse: \Tag.entries)
    var tags: [Tag] = []

    @Relationship(deleteRule: .nullify, inverse: \Person.entries)
    var people: [Person] = []

    init(
        date: Date = .now,
        type: EntryType = .thought,
        title: String = "",
        content: String = ""
    ) {
        self.id = UUID()
        self.date = date
        self.typeRaw = type.rawValue
        self.title = title
        self.content = content
        self.createdAt = .now
        self.updatedAt = .now
    }

    var type: EntryType {
        get { EntryType(rawValue: typeRaw) ?? .thought }
        set { typeRaw = newValue.rawValue }
    }

    var mood: Mood? {
        get {
            guard let moodRaw else { return nil }
            return Mood(rawValue: moodRaw)
        }
        set { moodRaw = newValue?.rawValue }
    }

    var hasLocation: Bool {
        latitude != nil && longitude != nil
    }
}
