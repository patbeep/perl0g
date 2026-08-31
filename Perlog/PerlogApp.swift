import SwiftUI
import SwiftData
import PhotosUI
import UserNotifications
import UIKit

// MARK: - App

@main
struct PerlogApp: App {
    @StateObject private var theme = ThemeStore()

    var body: some Scene {
        WindowGroup {
            PerlogRootView()
                .environmentObject(theme)
        }
        .modelContainer(for: LogEntry.self)
    }
}

// MARK: - Data Model

enum LogType: String, Codable, CaseIterable, Identifiable {
    case journal, mood, photo, meal, shopping, place, music, weight, steps, sleep, todo, divider
    var id: String { rawValue }
    var title: String {
        switch self {
        case .journal: return "Journal"
        case .mood: return "Mood"
        case .photo: return "Photo"
        case .meal: return "Meal"
        case .shopping: return "Shopping"
        case .place: return "Place"
        case .music: return "Music"
        case .weight: return "Weight"
        case .steps: return "Steps"
        case .sleep: return "Sleep"
        case .todo: return "To-Do"
        case .divider: return "Divider"
        }
    }
    var icon: String {
        switch self {
        case .journal: return "square.and.pencil"
        case .mood: return "face.smiling"
        case .photo: return "photo"
        case .meal: return "fork.knife"
        case .shopping: return "bag"
        case .place: return "mappin.and.ellipse"
        case .music: return "music.note"
        case .weight: return "scalemass"
        case .steps: return "figure.walk"
        case .sleep: return "bed.double"
        case .todo: return "checklist"
        case .divider: return "rectangle.split.3x1"
        }
    }
}

enum Mood: String, Codable, CaseIterable, Identifiable {
    case radiant, excited, happy, calm, neutral, tired, anxious, annoyed, sad
    var id: String { rawValue }
    var emoji: String {
        switch self {
        case .radiant: return "☀️"
        case .excited: return "🤩"
        case .happy: return "😊"
        case .calm: return "😌"
        case .neutral: return "😐"
        case .tired: return "😴"
        case .anxious: return "😟"
        case .annoyed: return "😤"
        case .sad: return "😢"
        }
    }
}

@Model
final class LogEntry {
    var id: UUID
    var createdAt: Date
    var updatedAt: Date
    var occurredAt: Date
    var kindRaw: String
    var title: String
    var bodyText: String
    var moodRaw: String?
    var tags: [String]
    var location: String?
    var value: Double?
    var unit: String?
    var done: Bool
    var photos: [Data]
    var urlString: String?
    var reminderDate: Date?
    var dividerLabel: String?

    init(
        kind: LogType = .journal,
        occurredAt: Date = .now,
        title: String = "",
        bodyText: String = "",
        mood: Mood? = nil,
        tags: [String] = [],
        location: String? = nil,
        value: Double? = nil,
        unit: String? = nil,
        done: Bool = false,
        photos: [Data] = [],
        urlString: String? = nil,
        reminderDate: Date? = nil,
        dividerLabel: String? = nil
    ) {
        id = UUID()
        createdAt = .now
        updatedAt = .now
        self.occurredAt = occurredAt
        kindRaw = kind.rawValue
        self.title = title
        self.bodyText = bodyText
        moodRaw = mood?.rawValue
        self.tags = tags
        self.location = location
        self.value = value
        self.unit = unit
        self.done = done
        self.photos = photos
        self.urlString = urlString
        self.reminderDate = reminderDate
        self.dividerLabel = dividerLabel
    }

    var kind: LogType {
        get { LogType(rawValue: kindRaw) ?? .journal }
        set { kindRaw = newValue.rawValue }
    }

    var mood: Mood? {
        get { moodRaw.flatMap { Mood(rawValue: $0) } }
        set { moodRaw = newValue?.rawValue }
    }
}

// MARK: - Theme

struct PerlogThemeConfiguration: Codable, Equatable {
    enum Mode: String, Codable { case grey, white, black, iridescent, custom }
    var mode: Mode = .grey
    var hue: Double = 265
    var backgroundHex = "0A0B0F"
    var glassHex = "181B22"
    var accentHex = "4F78FF"
    var primaryHex = "F5F6FA"
    var secondaryHex = "A7ABB8"
}

final class ThemeStore: ObservableObject {
    @Published var configuration: PerlogThemeConfiguration {
        didSet { save() }
    }
    private let key = "Perlog.theme.v2"

    init() {
        if let data = UserDefaults.standard.data(forKey: key), let value = try? JSONDecoder().decode(PerlogThemeConfiguration.self, from: data) {
            configuration = value
        } else {
            configuration = PerlogThemeConfiguration()
        }
    }

    func setMode(_ mode: PerlogThemeConfiguration.Mode) { configuration.mode = mode }
    func restoreDefaults() { configuration = PerlogThemeConfiguration() }
    private func save() {
        if let data = try? JSONEncoder().encode(configuration) { UserDefaults.standard.set(data, forKey: key) }
    }

    var palette: Palette {
        switch configuration.mode {
        case .grey:
            return Palette(background: Color(hex: "0B0D12"), glass: Color(hex: "1A1D24"), accent: Color(hex: "5A7CFF"), primary: .white, secondary: Color(hex: "A7ABB8"), dark: true)
        case .white:
            return Palette(background: Color(hex: "EEF1F5"), glass: .white, accent: Color(hex: "456CE8"), primary: Color(hex: "101218"), secondary: Color(hex: "666D79"), dark: false)
        case .black:
            return Palette(background: Color.black, glass: Color(hex: "111318"), accent: Color(hex: "4F78FF"), primary: .white, secondary: Color(hex: "9DA2AE"), dark: true)
        case .iridescent:
            let accent = Color(hue: configuration.hue / 360, saturation: 0.68, brightness: 1.0)
            return Palette(background: Color(hue: configuration.hue / 360, saturation: 0.12, brightness: 0.075), glass: Color(hue: configuration.hue / 360, saturation: 0.18, brightness: 0.14), accent: accent, primary: .white, secondary: Color.white.opacity(0.62), dark: true)
        case .custom:
            return Palette(background: Color(hex: configuration.backgroundHex), glass: Color(hex: configuration.glassHex), accent: Color(hex: configuration.accentHex), primary: Color(hex: configuration.primaryHex), secondary: Color(hex: configuration.secondaryHex), dark: true)
        }
    }
}

struct Palette {
    let background: Color
    let glass: Color
    let accent: Color
    let primary: Color
    let secondary: Color
    let dark: Bool
}

extension Color {
    init(hex: String) {
        let cleaned = String(hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")).prefix(6))
        let value = UInt64(cleaned, radix: 16) ?? 0
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}

// MARK: - Glass Design System

struct PerlogBackground: View {
    @EnvironmentObject private var theme: ThemeStore
    var body: some View {
        ZStack {
            theme.palette.background.ignoresSafeArea()
            Circle().fill(theme.palette.accent.opacity(0.14)).frame(width: 360).blur(radius: 100).offset(x: 160, y: -330)
            Circle().fill(Color.purple.opacity(0.08)).frame(width: 320).blur(radius: 100).offset(x: -170, y: 330)
            Circle().fill(Color.cyan.opacity(0.05)).frame(width: 220).blur(radius: 80).offset(x: 20, y: -80)
        }
    }
}

struct GlassSurface<Content: View>: View {
    @EnvironmentObject private var theme: ThemeStore
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .background(theme.palette.glass.opacity(0.42), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(LinearGradient(colors: [.white.opacity(theme.palette.dark ? 0.20 : 0.72), .white.opacity(0.03)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
            .shadow(color: .black.opacity(theme.palette.dark ? 0.30 : 0.10), radius: 20, y: 10)
    }
}

struct GlassPill<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding(.horizontal, 13).padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.15), lineWidth: 1))
    }
}

// MARK: - Root

struct PerlogRootView: View {
    @EnvironmentObject private var theme: ThemeStore
    @State private var selectedTab = 0
    @State private var quickAdd = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                TimelineView(showQuickAdd: $quickAdd).tag(0).tabItem { Label("Timeline", systemImage: "clock") }
                MemoriesView().tag(1).tabItem { Label("Memories", systemImage: "sparkles") }
                SummaryView().tag(2).tabItem { Label("Summary", systemImage: "chart.xyaxis.line") }
                MeView().tag(3).tabItem { Label("Me", systemImage: "person.crop.circle") }
            }
            .tint(theme.palette.accent)
            .toolbarBackground(.hidden, for: .tabBar)
        }
        .sheet(isPresented: $quickAdd) { QuickAddSheet() }
    }
}

// MARK: - Timeline

struct TimelineView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor<LogEntry>(\.occurredAt, order: .reverse)]) private var entries: [LogEntry]
    @Binding var showQuickAdd: Bool
    @State private var search = ""
    @State private var filter: LogType?
    @State private var selectedEntry: LogEntry?
    @State private var editorEntry: LogEntry?
    @State private var newEditor = false
    @State private var showFilters = false
    @State private var showJump = false
    @State private var showDelete = false
    @State private var deleteTarget: LogEntry?

    private var visibleEntries: [LogEntry] {
        entries.filter { entry in
            let typeOK = filter == nil || entry.kind == filter
            let searchable = [entry.title, entry.bodyText, entry.location ?? "", entry.tags.joined(separator: " "), entry.dividerLabel ?? ""].joined(separator: " ")
            return typeOK && (search.isEmpty || searchable.localizedCaseInsensitiveContains(search))
        }
    }

    private var days: [Date] {
        Array(Set(visibleEntries.map { Calendar.current.startOfDay(for: $0.occurredAt) })).sorted(by: >)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                PerlogBackground()
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 15) {
                            topBar
                            dayHeader
                            searchBar
                            filterRow
                            if visibleEntries.isEmpty { emptyState }
                            ForEach(days, id: \.self) { day in
                                DaySection(day: day, entries: visibleEntries.filter { Calendar.current.isDate($0.occurredAt, inSameDayAs: day) }, onOpen: { selectedEntry = $0 }, onDelete: { deleteTarget = $0; showDelete = true })
                                    .id(day)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 110)
                    }
                    .onChange(of: showJump) { _, newValue in
                        if !newValue, let target = pendingJump { withAnimation { proxy.scrollTo(target, anchor: .top) }; pendingJump = nil }
                    }
                }
                addButton
            }
            .sheet(item: $selectedEntry) { EntryDetailView(entry: $0) }
            .sheet(isPresented: $newEditor) { EntryEditorView(entry: nil) }
            .sheet(item: $editorEntry) { EntryEditorView(entry: $0) }
            .sheet(isPresented: $showFilters) { FilterSheet(selection: $filter) }
            .sheet(isPresented: $showJump) { JumpDateSheet(onSelect: { date in pendingJump = Calendar.current.startOfDay(for: date); showJump = false }) }
            .confirmationDialog("Delete this Perlog?", isPresented: $showDelete, titleVisibility: .visible) { Button("Delete", role: .destructive) { if let target = deleteTarget { context.delete(target); try? context.save() } }; Button("Cancel", role: .cancel) {} }
        }
    }

    @State private var pendingJump: Date?

    private var topBar: some View {
        HStack(spacing: 8) {
            GlassPill { Text("Perlog").font(.subheadline.weight(.semibold)) }
            Spacer()
            Button { showJump = true } label: { Image(systemName: "magnifyingglass") }
                .frame(width: 38, height: 38).background(.ultraThinMaterial, in: Circle())
            Button { showFilters = true } label: { Image(systemName: "ellipsis") }
                .frame(width: 38, height: 38).background(.ultraThinMaterial, in: Circle())
        }
        .foregroundStyle(theme.palette.primary)
    }

    private var dayHeader: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day())).font(.system(size: 25, weight: .regular, design: .rounded))
            Text(summaryLine).font(.caption).foregroundStyle(theme.palette.secondary)
        }
        .padding(.top, 4)
    }

    private var summaryLine: String {
        let today = entries.filter { Calendar.current.isDateInToday($0.occurredAt) }
        let moods = today.compactMap(\.mood).count
        return "\(today.count) record\(today.count == 1 ? "" : "s")  •  \(moods) mood\(moods == 1 ? "" : "s")  •  \(today.filter { !$0.photos.isEmpty }.count) photo\(today.filter { !$0.photos.isEmpty }.count == 1 ? "" : "s")"
    }

    private var searchBar: some View {
        HStack(spacing: 10) { Image(systemName: "magnifyingglass").foregroundStyle(theme.palette.secondary); TextField("Search your personal log", text: $search).textInputAutocapitalization(.never); if !search.isEmpty { Button { search = "" } label: { Image(systemName: "xmark.circle.fill") } } }
            .padding(13).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 17, style: .continuous)).overlay(RoundedRectangle(cornerRadius: 17).stroke(.white.opacity(0.10)))
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 7) { typeChip(nil, "All", "square.grid.2x2"); ForEach(LogType.allCases.filter { $0 != .divider }) { type in typeChip(type, type.title, type.icon) } } }
    }

    private func typeChip(_ type: LogType?, _ title: String, _ icon: String) -> some View {
        Button { filter = filter == type ? nil : type } label: { Label(title, systemImage: icon).font(.caption2.weight(.semibold)).foregroundStyle(filter == type ? theme.palette.primary : theme.palette.secondary).padding(.horizontal, 10).padding(.vertical, 7).background(filter == type ? theme.palette.accent.opacity(0.22) : Color.white.opacity(0.045), in: Capsule()).overlay(Capsule().stroke(.white.opacity(0.08))) }.buttonStyle(.plain)
    }

    private var emptyState: some View {
        GlassSurface { VStack(alignment: .leading, spacing: 10) { Image(systemName: "sparkles.rectangle.stack").font(.title).foregroundStyle(theme.palette.accent); Text("Your personal log is ready.").font(.headline); Text("Capture a thought, photo, mood, place, meal, activity, task, or anything worth remembering.").font(.subheadline).foregroundStyle(theme.palette.secondary); Button("Create your first Perlog") { newEditor = true }.buttonStyle(.borderedProminent).tint(theme.palette.accent) }.frame(maxWidth: .infinity, alignment: .leading).padding(18) }
    }

    private var addButton: some View {
        Button { showQuickAdd = true } label: { Image(systemName: "plus").font(.title3.bold()).frame(width: 58, height: 58) }
            .foregroundStyle(theme.palette.primary).background(.ultraThinMaterial, in: Circle()).overlay(Circle().stroke(.white.opacity(0.24))).shadow(color: .black.opacity(0.3), radius: 18, y: 8).padding(.trailing, 20).padding(.bottom, 76)
    }
}

struct DaySection: View {
    @EnvironmentObject private var theme: ThemeStore
    let day: Date
    let entries: [LogEntry]
    let onOpen: (LogEntry) -> Void
    let onDelete: (LogEntry) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(day.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())).font(.caption.weight(.bold)).foregroundStyle(theme.palette.secondary).padding(.leading, 3)
            ForEach(entries) { entry in EntryCard(entry: entry, onOpen: { onOpen(entry) }, onDelete: { onDelete(entry) }) }
        }
    }
}

struct EntryCard: View {
    @EnvironmentObject private var theme: ThemeStore
    let entry: LogEntry
    let onOpen: () -> Void
    let onDelete: () -> Void
    var body: some View {
        Button(action: onOpen) {
            GlassSurface {
                HStack(alignment: .top, spacing: 11) {
                    ZStack { Circle().fill(theme.palette.accent.opacity(0.15)); Image(systemName: entry.kind.icon).foregroundStyle(theme.palette.accent) }.frame(width: 34, height: 34)
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(alignment: .firstTextBaseline) { Text(entry.kind.title).font(.caption.weight(.bold)); Spacer(); Text(entry.occurredAt.formatted(date: .omitted, time: .shortened)).font(.caption2).foregroundStyle(theme.palette.secondary) }
                        if !entry.title.isEmpty { Text(entry.title).font(.subheadline.weight(.semibold)) }
                        if !entry.bodyText.isEmpty { Text(entry.bodyText).font(.caption).foregroundStyle(theme.palette.secondary).lineLimit(4) }
                        if let mood = entry.mood { Text("\(mood.emoji)  \(mood.rawValue.capitalized)").font(.caption2).foregroundStyle(theme.palette.secondary) }
                        if let value = entry.value { Text("\(value.formatted()) \(entry.unit ?? "")").font(.headline) }
                        if let place = entry.location, !place.isEmpty { Label(place, systemImage: "mappin.and.ellipse").font(.caption2).foregroundStyle(theme.palette.secondary) }
                        if !entry.tags.isEmpty { Text(entry.tags.map { "#\($0)" }.joined(separator: "   ")).font(.caption2).foregroundStyle(theme.palette.accent) }
                        if !entry.photos.isEmpty { PhotoStrip(data: entry.photos, compact: true) }
                        if entry.kind == .todo { Label(entry.done ? "Completed" : "Open", systemImage: entry.done ? "checkmark.circle.fill" : "circle").font(.caption2) }
                    }
                }.padding(13)
            }
        }
        .buttonStyle(.plain)
        .contextMenu { Button("Delete", role: .destructive, action: onDelete) }
    }
}

// MARK: - Quick Add

struct QuickAddSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeStore
    @State private var selected: LogType = .journal
    @State private var title = ""
    @State private var bodyText = ""
    @State private var mood: Mood?
    @State private var date = Date.now
    @State private var tags = ""
    @State private var location = ""
    @State private var photos: [Data] = []
    @State private var items: [PhotosPickerItem] = []
    @Environment(\.modelContext) private var context

    private let quickTypes: [LogType] = [.journal, .mood, .photo, .meal, .shopping, .place, .music, .steps]

    var body: some View {
        NavigationStack {
            ZStack {
                PerlogBackground()
                ScrollView { VStack(spacing: 14) {
                    PickerRow(types: quickTypes, selected: $selected)
                    GlassSurface { VStack(alignment: .leading, spacing: 12) { Text(selected == .journal ? "Morning pages" : "New \(selected.title.lowercased())").font(.headline); TextEditor(text: $bodyText).frame(minHeight: 105).scrollContentBackground(.hidden).padding(-5) } .padding(15) }
                    if selected == .mood || mood != nil { moodRow }
                    if selected == .photo || !photos.isEmpty { photoPicker }
                    if selected == .place { GlassSurface { HStack { Image(systemName: "mappin.and.ellipse"); TextField("Place", text: $location) }.padding(15) } }
                    GlassSurface { VStack(spacing: 0) { DatePicker("Today · \(date.formatted(date: .omitted, time: .shortened))", selection: $date).padding(15); Divider(); TextField("Tags, comma separated", text: $tags).padding(15) } }
                    Button { save() } label: { Text("Save record").font(.subheadline.bold()).frame(maxWidth: .infinity).padding(.vertical, 14) }.buttonStyle(.borderedProminent).tint(theme.palette.accent)
                }.padding(16) }
            }
            .navigationTitle("New record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
    }

    private var moodRow: some View { GlassSurface { ScrollView(.horizontal, showsIndicators: false) { HStack { ForEach(Mood.allCases) { m in Button("\(m.emoji) \(m.rawValue.capitalized)") { mood = mood == m ? nil : m }.buttonStyle(.bordered) } } }.padding(12) } }
    private var photoPicker: some View { GlassSurface { VStack(alignment: .leading, spacing: 10) { PhotosPicker(selection: $items, maxSelectionCount: 20, matching: .images) { Label("Add photos", systemImage: "photo.on.rectangle.angled") }.buttonStyle(.bordered); PhotoStrip(data: photos) }.padding(12) } }

    private func save() {
        let cleanTags = tags.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let entry = LogEntry(kind: selected, occurredAt: date, title: title, bodyText: bodyText, mood: mood, tags: cleanTags, location: location.isEmpty ? nil : location, photos: photos)
        // For a fast journal flow, a blank title is intentionally allowed.
        context.insert(entry)
        try? context.save()
        dismiss()
    }
}


struct PickerRow: View {
    @EnvironmentObject private var theme: ThemeStore
    let types: [LogType]
    @Binding var selected: LogType

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(types) { type in
                    Button {
                        selected = type
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: type.icon).font(.headline)
                            Text(type.title).font(.caption2)
                        }
                        .frame(width: 55, height: 52)
                        .foregroundStyle(selected == type ? theme.palette.primary : theme.palette.secondary)
                        .background(selected == type ? theme.palette.accent.opacity(0.26) : Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(.white.opacity(0.08)))
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }
}

// MARK: - Detail

struct EntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var theme: ThemeStore
    let entry: LogEntry
    @State private var editing = false
    @State private var deleting = false
    var body: some View {
        NavigationStack {
            ZStack { PerlogBackground(); ScrollView { VStack(spacing: 14) {
                if !entry.photos.isEmpty { PhotoStrip(data: entry.photos) }
                GlassSurface { VStack(alignment: .leading, spacing: 10) { HStack { Label(entry.kind.title, systemImage: entry.kind.icon); Spacer(); Text(entry.occurredAt.formatted(date: .abbreviated, time: .shortened)).font(.caption).foregroundStyle(theme.palette.secondary) }; if !entry.title.isEmpty { Text(entry.title).font(.title2.weight(.semibold)) }; if let mood = entry.mood { Text("\(mood.emoji)  \(mood.rawValue.capitalized)") }; if !entry.bodyText.isEmpty { Text(entry.bodyText).textSelection(.enabled) }; if let place = entry.location { Label(place, systemImage: "mappin.and.ellipse") }; if !entry.tags.isEmpty { Text(entry.tags.map { "#\($0)" }.joined(separator: "   ")).foregroundStyle(theme.palette.accent) }; if let url = entry.urlString, let link = URL(string: url) { Link(destination: link) { Label(url, systemImage: "link") } } }.padding(18) }
                HStack { Button { editing = true } label: { Label("Edit", systemImage: "square.and.pencil").frame(maxWidth: .infinity) }.buttonStyle(.borderedProminent).tint(theme.palette.accent); Button(role: .destructive) { deleting = true } label: { Label("Delete", systemImage: "trash").frame(maxWidth: .infinity) }.buttonStyle(.bordered) }
            }.padding(16) } }
            .navigationTitle("Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } } }
            .sheet(isPresented: $editing) { EntryEditorView(entry: entry) }
            .confirmationDialog("Delete this record?", isPresented: $deleting) { Button("Delete", role: .destructive) { context.delete(entry); try? context.save(); dismiss() }; Button("Cancel", role: .cancel) {} }
        }
    }
}

// MARK: - Editor

struct EntryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var theme: ThemeStore
    let entry: LogEntry?
    @State private var kind: LogType = .journal
    @State private var title = ""
    @State private var bodyText = ""
    @State private var date = Date.now
    @State private var mood: Mood?
    @State private var tagsText = ""
    @State private var location = ""
    @State private var valueText = ""
    @State private var unit = ""
    @State private var done = false
    @State private var url = ""
    @State private var photos: [Data] = []
    @State private var items: [PhotosPickerItem] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Record") {
                    Picker("Type", selection: $kind) { ForEach(LogType.allCases) { Text($0.title).tag($0) } }
                    TextField("Title", text: $title)
                    TextEditor(text: $bodyText).frame(minHeight: 150)
                }
                Section("Mood") { ScrollView(.horizontal, showsIndicators: false) { HStack { ForEach(Mood.allCases) { m in Button("\(m.emoji) \(m.rawValue.capitalized)") { mood = mood == m ? nil : m }.buttonStyle(.bordered) } } } }
                if [.weight, .steps, .sleep].contains(kind) { Section("Measurement") { TextField("Value", text: $valueText).keyboardType(.decimalPad); TextField("Unit", text: $unit) } }
                if kind == .todo { Section { Toggle("Completed", isOn: $done) } }
                Section("Photos") { PhotosPicker(selection: $items, maxSelectionCount: 50, matching: .images) { Label("Add photos", systemImage: "photo.on.rectangle.angled") }; PhotoStrip(data: photos) }
                Section("Context") { DatePicker("Date & time", selection: $date); TextField("Location", text: $location); TextField("Tags, comma separated", text: $tagsText); TextField("Link", text: $url).keyboardType(.URL).textInputAutocapitalization(.never) }
            }
            .navigationTitle(entry == nil ? "New Perlog" : "Edit Perlog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }; ToolbarItem(placement: .confirmationAction) { Button("Save") { save() } } }
            .task { load() }
            .onChange(of: items) { _, newItems in Task { var result: [Data] = []; for item in newItems { if let data = try? await item.loadTransferable(type: Data.self) { result.append(data) } }; photos = result } }
        }
    }

    private func load() {
        guard let entry else { return }
        kind = entry.kind; title = entry.title; bodyText = entry.bodyText; date = entry.occurredAt; mood = entry.mood; tagsText = entry.tags.joined(separator: ", "); location = entry.location ?? ""; valueText = entry.value.map { String($0) } ?? ""; unit = entry.unit ?? ""; done = entry.done; url = entry.urlString ?? ""; photos = entry.photos
    }

    private func save() {
        let tags = tagsText.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let number = Double(valueText)
        let place = location.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
        if let entry {
            entry.kind = kind; entry.title = title; entry.bodyText = bodyText; entry.occurredAt = date; entry.updatedAt = .now; entry.mood = mood; entry.tags = tags; entry.location = place.isEmpty ? nil : place; entry.value = number; entry.unit = unit.isEmpty ? nil : unit; entry.done = done; entry.urlString = cleanURL.isEmpty ? nil : cleanURL; entry.photos = photos
        } else {
            context.insert(LogEntry(kind: kind, occurredAt: date, title: title, bodyText: bodyText, mood: mood, tags: tags, location: place.isEmpty ? nil : place, value: number, unit: unit.isEmpty ? nil : unit, done: done, photos: photos, urlString: cleanURL.isEmpty ? nil : cleanURL))
        }
        try? context.save(); dismiss()
    }
}

// MARK: - Photos

struct PhotoStrip: View {
    let data: [Data]
    var compact = false
    var body: some View { ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 8) { ForEach(Array(data.enumerated()), id: \.offset) { _, datum in if let image = UIImage(data: datum) { Image(uiImage: image).resizable().scaledToFill().frame(width: compact ? 76 : 120, height: compact ? 62 : 92).clipShape(RoundedRectangle(cornerRadius: compact ? 11 : 16, style: .continuous)) } } } } }
}

// MARK: - Memories

struct MemoriesView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Query(sort: [SortDescriptor<LogEntry>(\.occurredAt, order: .reverse)]) private var entries: [LogEntry]
    var body: some View { NavigationStack { ZStack { PerlogBackground(); ScrollView { VStack(alignment: .leading, spacing: 14) { Text("Memories").font(.system(size: 32, weight: .bold, design: .rounded)); Text("Moments from your personal log, resurfaced.").foregroundStyle(theme.palette.secondary); ForEach(entries.prefix(20)) { entry in Button { } label: { GlassSurface { HStack { if let first = entry.photos.first, let image = UIImage(data: first) { Image(uiImage: image).resizable().scaledToFill().frame(width: 78, height: 78).clipShape(RoundedRectangle(cornerRadius: 15)) }; VStack(alignment: .leading, spacing: 5) { Text(entry.occurredAt.formatted(date: .abbreviated, time: .omitted)).font(.caption).foregroundStyle(theme.palette.secondary); Text(entry.title.isEmpty ? entry.kind.title : entry.title).font(.headline); if !entry.bodyText.isEmpty { Text(entry.bodyText).font(.caption).foregroundStyle(theme.palette.secondary).lineLimit(3) } } }.padding(13) } }.buttonStyle(.plain) } }.padding(16) } }.toolbar(.hidden, for: .navigationBar) } }
}

// MARK: - Summary

struct SummaryView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Query private var entries: [LogEntry]
    private var photos: Int { entries.reduce(0) { $0 + $1.photos.count } }
    private var moods: Int { entries.filter { $0.mood != nil }.count }
    private var places: Int { entries.filter { $0.kind == .place || $0.location != nil }.count }
    var body: some View { NavigationStack { ZStack { PerlogBackground(); ScrollView { VStack(alignment: .leading, spacing: 15) { Text("Summary").font(.system(size: 32, weight: .bold, design: .rounded)); Text("A living overview of everything you have logged.").foregroundStyle(theme.palette.secondary); LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) { stat("\(entries.count)", "Perlogs", "clock"); stat("\(moods)", "Moods", "face.smiling"); stat("\(photos)", "Photos", "photo"); stat("\(places)", "Places", "mappin.and.ellipse"); stat("\(entries.filter { $0.kind == .todo }.count)", "To-Dos", "checklist"); stat("\(entries.filter { $0.kind == .journal }.count)", "Journal", "book.pages") }; GlassSurface { VStack(alignment: .leading, spacing: 7) { Text("All history").font(.headline); Text("Perlog does not impose a record or history limit. Your device storage is the practical limit.").font(.caption).foregroundStyle(theme.palette.secondary) }.padding(16) } }.padding(16) } }.toolbar(.hidden, for: .navigationBar) } }
    private func stat(_ value: String, _ title: String, _ icon: String) -> some View { GlassSurface { VStack(alignment: .leading, spacing: 7) { Image(systemName: icon).foregroundStyle(theme.palette.accent); Text(value).font(.system(size: 28, weight: .bold, design: .rounded)); Text(title).font(.caption).foregroundStyle(theme.palette.secondary) }.frame(maxWidth: .infinity, alignment: .leading).padding(15) } }
}

// MARK: - Me / Theme Studio

struct MeView: View {
    @EnvironmentObject private var theme: ThemeStore
    @State private var showThemes = false
    var body: some View { NavigationStack { ZStack { PerlogBackground(); ScrollView { VStack(alignment: .leading, spacing: 14) { GlassSurface { VStack(alignment: .leading, spacing: 5) { Text("Perlog").font(.largeTitle.bold()); Text("Your life, logged.").foregroundStyle(theme.palette.secondary); Text("A personal log for everything worth keeping.").font(.caption).foregroundStyle(theme.palette.secondary) }.frame(maxWidth: .infinity, alignment: .leading).padding(18) }; GlassSurface { Button { showThemes = true } label: { HStack { Image(systemName: "circle.lefthalf.filled").foregroundStyle(theme.palette.accent); VStack(alignment: .leading) { Text("Theme Studio").font(.headline); Text(theme.configuration.mode.rawValue.capitalized).font(.caption).foregroundStyle(theme.palette.secondary) }; Spacer(); Image(systemName: "chevron.right").foregroundStyle(theme.palette.secondary) }.padding(16) } }.buttonStyle(.plain); GlassSurface { VStack(alignment: .leading, spacing: 12) { Label("Local-first storage", systemImage: "internaldrive"); Label("No account required", systemImage: "person.crop.circle.badge.checkmark"); Label("No ads or tracking", systemImage: "eye.slash"); Label("Free and unlimited by design", systemImage: "infinity") }.padding(17) } }.padding(16) } }.navigationTitle("Me").navigationBarTitleDisplayMode(.inline).sheet(isPresented: $showThemes) { ThemeStudioView() } } }
}

struct ThemeStudioView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.dismiss) private var dismiss
    private let modes: [PerlogThemeConfiguration.Mode] = [.black, .grey, .white, .iridescent, .custom]
    var body: some View { NavigationStack { ZStack { PerlogBackground(); ScrollView { VStack(alignment: .leading, spacing: 12) { Text("Theme Studio").font(.largeTitle.bold()); Text("Make Perlog yours.").foregroundStyle(theme.palette.secondary); ForEach(modes, id: \.self) { mode in ThemePreview(mode: mode, selected: theme.configuration.mode == mode) { theme.setMode(mode) } }; if theme.configuration.mode == .iridescent { GlassSurface { VStack(alignment: .leading, spacing: 12) { HStack { Text("Base hue"); Spacer(); Text("\(Int(theme.configuration.hue))°").foregroundStyle(theme.palette.secondary) }; Slider(value: $theme.configuration.hue, in: 0...360); Button("Restore default hue") { theme.configuration.hue = 265 }.font(.caption) }.padding(16) } }; if theme.configuration.mode == .custom { CustomPaletteEditor() }; Button("Restore defaults") { theme.restoreDefaults() }.frame(maxWidth: .infinity).padding(.vertical, 12).buttonStyle(.bordered) }.padding(16) } }.toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } } } }
}

struct ThemePreview: View {
    @EnvironmentObject private var theme: ThemeStore
    let mode: PerlogThemeConfiguration.Mode
    let selected: Bool
    let action: () -> Void
    var body: some View { Button(action: action) { GlassSurface { HStack(spacing: 12) { Circle().fill(previewColor).frame(width: 28, height: 28).overlay(Circle().stroke(.white.opacity(0.35))); VStack(alignment: .leading) { Text(mode.rawValue.capitalized).font(.headline); Text(description).font(.caption).foregroundStyle(theme.palette.secondary) }; Spacer(); if selected { Image(systemName: "checkmark.circle.fill").foregroundStyle(theme.palette.accent) } }.padding(14) } }.buttonStyle(.plain) }
    private var previewColor: Color { switch mode { case .black: return .black; case .white: return .white; case .grey: return Color(hex: "69707D"); case .iridescent: return Color(hue: theme.configuration.hue / 360, saturation: 0.7, brightness: 1); case .custom: return Color(hex: theme.configuration.accentHex) } }
    private var description: String { switch mode { case .black: return "Deep glass · high contrast"; case .white: return "Bright · frosted"; case .grey: return "Neutral · dimensional"; case .iridescent: return "Hue-shifting glass"; case .custom: return "Your palette" } }
}

struct CustomPaletteEditor: View {
    @EnvironmentObject private var theme: ThemeStore
    var body: some View { GlassSurface { VStack(alignment: .leading, spacing: 14) { Text("Custom palette").font(.headline); colorRow("Accent", keyPath: \PerlogThemeConfiguration.accentHex); colorRow("Background", keyPath: \PerlogThemeConfiguration.backgroundHex); colorRow("Glass", keyPath: \PerlogThemeConfiguration.glassHex); colorRow("Primary text", keyPath: \PerlogThemeConfiguration.primaryHex); colorRow("Secondary text", keyPath: \PerlogThemeConfiguration.secondaryHex); Text("Use six-digit hex values. Perlog keeps the controls simple while preserving full palette control.").font(.caption).foregroundStyle(theme.palette.secondary) }.padding(16) } }
    private func colorRow(_ title: String, keyPath: ReferenceWritableKeyPath<PerlogThemeConfiguration, String>) -> some View { HStack { Text(title); Spacer(); TextField("#000000", text: Binding(get: { theme.configuration[keyPath: keyPath] }, set: { theme.configuration[keyPath: keyPath] = String($0.filter { $0.isHexDigit }.prefix(6)) })).font(.caption.monospaced()).multilineTextAlignment(.trailing).frame(width: 100) } }
}

// MARK: - Filters / Jump

struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: LogType?
    var body: some View { NavigationStack { List { Button("Everything") { selection = nil; dismiss() }; ForEach(LogType.allCases) { type in Button { selection = type; dismiss() } label: { Label(type.title, systemImage: type.icon) } } }.navigationTitle("Filter") } }
}

struct JumpDateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var date = Date.now
    let onSelect: (Date) -> Void
    var body: some View { NavigationStack { Form { DatePicker("Jump to", selection: $date, displayedComponents: .date); Button("Show this date") { onSelect(date) } }.navigationTitle("Jump to Date").toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } } } }
}
