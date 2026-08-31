import SwiftUI
import SwiftData
import PhotosUI

@main
struct PerlogApp: App {
    @StateObject private var themeStore = ThemeStore()

    var body: some Scene {
        WindowGroup {
            PerlogRootView()
                .environmentObject(themeStore)
        }
        .modelContainer(for: LogEntry.self)
    }
}

// MARK: - Model

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
        self.id = UUID()
        self.createdAt = .now
        self.updatedAt = .now
        self.occurredAt = occurredAt
        self.kindRaw = kind.rawValue
        self.title = title
        self.bodyText = bodyText
        self.moodRaw = mood?.rawValue
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

struct ThemeConfiguration: Codable {
    var name = "Grey"
    var hue = 215.0
    var accentHex = "#5D8DFF"
    var backgroundHex = "#E6E9EF"
    var glassHex = "#FFFFFF"
    var primaryHex = "#14161B"
    var secondaryHex = "#646A76"
}

struct PerlogPalette {
    let background: Color
    let glassTint: Color
    let primary: Color
    let secondary: Color
    let accent: Color
    let isDark: Bool
}

final class ThemeStore: ObservableObject {
    @Published var configuration: ThemeConfiguration {
        didSet { persist() }
    }

    private let key = "Perlog.ThemeConfiguration.v2"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode(ThemeConfiguration.self, from: data) {
            configuration = saved
        } else {
            configuration = ThemeConfiguration()
        }
    }

    var name: String { configuration.name }
    var hue: Double { configuration.hue }

    var palette: PerlogPalette {
        switch configuration.name {
        case "Black":
            return PerlogPalette(
                background: .black,
                glassTint: .white,
                primary: .white,
                secondary: .white.opacity(0.65),
                accent: Color(hex: configuration.accentHex),
                isDark: true
            )
        case "White":
            return PerlogPalette(
                background: Color(white: 0.965),
                glassTint: .white,
                primary: Color(white: 0.08),
                secondary: Color(white: 0.38),
                accent: Color(hex: configuration.accentHex),
                isDark: false
            )
        case "Iridescent":
            let base = Color(hue: configuration.hue / 360.0, saturation: 0.11, brightness: 0.96)
            return PerlogPalette(
                background: base,
                glassTint: .white,
                primary: Color(white: 0.09),
                secondary: Color(white: 0.38),
                accent: Color(hue: configuration.hue / 360.0, saturation: 0.72, brightness: 0.98),
                isDark: false
            )
        case "Custom":
            return PerlogPalette(
                background: Color(hex: configuration.backgroundHex),
                glassTint: Color(hex: configuration.glassHex),
                primary: Color(hex: configuration.primaryHex),
                secondary: Color(hex: configuration.secondaryHex),
                accent: Color(hex: configuration.accentHex),
                isDark: luminance(hex: configuration.backgroundHex) < 0.42
            )
        default:
            return PerlogPalette(
                background: Color(hex: "#E6E9EF"),
                glassTint: .white,
                primary: Color(hex: "#14161B"),
                secondary: Color(hex: "#646A76"),
                accent: Color(hex: "#5D8DFF"),
                isDark: false
            )
        }
    }

    func select(_ name: String) {
        configuration.name = name
        if name == "Iridescent" && configuration.hue == 0 { configuration.hue = 215 }
    }

    func restoreDefaults() {
        configuration = ThemeConfiguration()
    }

    func setColor(_ color: Color, keyPath: WritableKeyPath<ThemeConfiguration, String>) {
        configuration[keyPath: keyPath] = color.hexString
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(configuration) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func luminance(hex: String) -> Double {
        let c = Color(hex: hex).components
        return 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let value = UInt64(cleaned, radix: 16) ?? 0
        self.init(
            red: Double((value >> 16) & 255) / 255.0,
            green: Double((value >> 8) & 255) / 255.0,
            blue: Double(value & 255) / 255.0
        )
    }

    var hexString: String {
        #if os(iOS)
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if ui.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        }
        #endif
        return "#5D8DFF"
    }

    var components: (r: Double, g: Double, b: Double) {
        #if os(iOS)
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if ui.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (Double(r), Double(g), Double(b))
        }
        #endif
        return (0.5, 0.5, 0.5)
    }
}

// MARK: - Glass Design System

struct GlassSurface<Content: View>: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    let content: Content
    var radius: CGFloat = 26

    init(radius: CGFloat = 26, @ViewBuilder content: () -> Content) {
        self.radius = radius
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(
                reduceTransparency
                    ? AnyShapeStyle(theme.palette.glassTint.opacity(0.92))
                    : AnyShapeStyle(.ultraThinMaterial)
            , in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(.white.opacity(theme.palette.isDark ? 0.16 : 0.56), lineWidth: 1)
            )
            .shadow(color: .black.opacity(theme.palette.isDark ? 0.28 : 0.11), radius: 20, y: 8)
    }
}

struct AmbientBackground: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            theme.palette.background.ignoresSafeArea()
            Circle()
                .fill(theme.palette.accent.opacity(0.13))
                .frame(width: 330)
                .blur(radius: 80)
                .offset(x: 150, y: -320)
            Circle()
                .fill(Color.purple.opacity(0.055))
                .frame(width: 280)
                .blur(radius: 85)
                .offset(x: -160, y: 300)
            if !reduceMotion {
                Circle()
                    .fill(theme.palette.accent.opacity(0.045))
                    .frame(width: 210)
                    .blur(radius: 70)
                    .offset(x: -40, y: -30)
            }
        }
    }
}

// MARK: - Root

struct PerlogRootView: View {
    @EnvironmentObject private var theme: ThemeStore
    var body: some View {
        TabView {
            TimelineView().tabItem { Label("Timeline", systemImage: "clock") }
            MemoriesView().tabItem { Label("Memories", systemImage: "sparkles") }
            SummaryView().tabItem { Label("Summary", systemImage: "chart.xyaxis.line") }
            MeView().tabItem { Label("Me", systemImage: "person.crop.circle") }
        }
        .tint(theme.palette.accent)
        .preferredColorScheme(theme.palette.isDark ? .dark : .light)
    }
}

// MARK: - Timeline

struct TimelineView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: [SortDescriptor<LogEntry>(\.occurredAt, order: .reverse)]) private var entries: [LogEntry]

    @State private var searchText = ""
    @State private var selectedType: LogType?
    @State private var showingEditor = false
    @State private var editingEntry: LogEntry?
    @State private var showingFilter = false
    @State private var showingDeleteConfirmation = false
    @State private var pendingDelete: LogEntry?
    @State private var showingUndo = false
    @State private var undoEntry: LogEntry?

    private var shown: [LogEntry] {
        entries.filter { entry in
            let typeMatches = selectedType == nil || entry.kind == selectedType
            let searchable = [entry.title, entry.bodyText, entry.location ?? "", entry.tags.joined(separator: " "), entry.urlString ?? ""].joined(separator: " ")
            return typeMatches && (searchText.isEmpty || searchable.localizedCaseInsensitiveContains(searchText))
        }
    }

    private var days: [Date] {
        Array(Set(shown.map { Calendar.current.startOfDay(for: $0.occurredAt) })).sorted(by: >)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AmbientBackground()
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 18) {
                        header
                        searchBar
                        typeChips
                        if shown.isEmpty { emptyState }
                        ForEach(days, id: \.self) { day in
                            daySection(day)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 104)
                }
                quickAddButton
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingEditor) {
                EntryEditorView(entry: editingEntry)
            }
            .sheet(isPresented: $showingFilter) {
                FilterView(selection: $selectedType)
            }
            .confirmationDialog("Delete this Perlog?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) { performDelete() }
                Button("Cancel", role: .cancel) { pendingDelete = nil }
            } message: {
                Text("The record will be removed. You can undo immediately afterward.")
            }
            .overlay(alignment: .bottom) {
                if showingUndo {
                    undoBanner
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 12)
                }
            }
        }
        .task { SeedEntries.seedIfNeeded(context: context, existingCount: entries.count) }
        .animation(reduceMotion ? nil : .snappy, value: showingUndo)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text(greeting).font(.system(size: 32, weight: .bold, design: .rounded))
                Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(.subheadline)
                    .foregroundStyle(theme.palette.secondary)
                Text("Your life, logged.")
                    .font(.caption)
                    .foregroundStyle(theme.palette.secondary)
            }
            Spacer(minLength: 12)
            HStack(spacing: 8) {
                Button { showingFilter = true } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.title3)
                        .frame(width: 42, height: 42)
                }
                .accessibilityLabel("Filter records")
                Button { editingEntry = nil; showingEditor = true } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.title3)
                        .frame(width: 42, height: 42)
                }
                .accessibilityLabel("New Perlog")
            }
            .background(.ultraThinMaterial, in: Capsule())
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
            TextField("Search your life…", text: $searchText)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled(false)
            if !searchText.isEmpty {
                Button { searchText = "" } label: { Image(systemName: "xmark.circle.fill") }
                    .accessibilityLabel("Clear search")
            }
        }
        .foregroundStyle(theme.palette.secondary)
        .padding(.horizontal, 15)
        .frame(minHeight: 48)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.35), lineWidth: 1))
    }

    private var typeChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(nil, "Everything", "square.grid.2x2")
                ForEach(LogType.allCases) { type in chip(type, type.title, type.icon) }
            }
        }
        .scrollIndicators(.hidden)
    }

    private func chip(_ type: LogType?, _ title: String, _ icon: String) -> some View {
        let selected = selectedType == type
        return Button {
            selectedType = selected ? nil : type
        } label: {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(selected ? theme.palette.accent.opacity(0.20) : Color.primary.opacity(0.055), in: Capsule())
                .overlay(Capsule().stroke(selected ? theme.palette.accent.opacity(0.42) : .white.opacity(0.20), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func daySection(_ day: Date) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(day.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.headline)
                .foregroundStyle(theme.palette.primary)
                .padding(.leading, 3)
            ForEach(shown.filter { Calendar.current.isDate($0.occurredAt, inSameDayAs: day) }) { entry in
                EntryCard(entry: entry, onEdit: {
                    editingEntry = entry
                    showingEditor = true
                }, onDelete: {
                    pendingDelete = entry
                    showingDeleteConfirmation = true
                })
            }
        }
    }

    private var emptyState: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "book.closed")
                    .font(.largeTitle)
                    .foregroundStyle(theme.palette.accent)
                Text(searchText.isEmpty ? "Your personal log is ready." : "No matching Perlogs.")
                    .font(.headline)
                Text(searchText.isEmpty ? "Capture a thought, moment, photo, place, mood, activity, or anything else worth remembering." : "Try another search or clear the current filter.")
                    .foregroundStyle(theme.palette.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var quickAddButton: some View {
        Button { editingEntry = nil; showingEditor = true } label: {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundStyle(theme.palette.primary)
                .frame(width: 60, height: 60)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.58), lineWidth: 1))
                .shadow(color: .black.opacity(0.20), radius: 18, y: 8)
        }
        .accessibilityLabel("Add a Perlog")
        .padding(18)
    }

    private var undoBanner: some View {
        HStack {
            Text("Perlog deleted")
                .font(.subheadline.weight(.semibold))
            Spacer()
            Button("Undo") { undoDelete() }
                .font(.subheadline.bold())
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 50)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.45), lineWidth: 1))
        .shadow(radius: 18, y: 8)
        .padding(.horizontal, 20)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        return hour < 12 ? "Good morning" : hour < 18 ? "Good afternoon" : "Good evening"
    }

    private func performDelete() {
        guard let entry = pendingDelete else { return }
        undoEntry = LogEntry(
            kind: entry.kind,
            occurredAt: entry.occurredAt,
            title: entry.title,
            bodyText: entry.bodyText,
            mood: entry.mood,
            tags: entry.tags,
            location: entry.location,
            value: entry.value,
            unit: entry.unit,
            done: entry.done,
            photos: entry.photos,
            urlString: entry.urlString,
            reminderDate: entry.reminderDate,
            dividerLabel: entry.dividerLabel
        )
        context.delete(entry)
        try? context.save()
        pendingDelete = nil
        showingUndo = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            showingUndo = false
            undoEntry = nil
        }
    }

    private func undoDelete() {
        guard let restored = undoEntry else { return }
        context.insert(restored)
        try? context.save()
        showingUndo = false
        undoEntry = nil
    }
}

// MARK: - Entry Card

struct EntryCard: View {
    @EnvironmentObject private var theme: ThemeStore
    let entry: LogEntry
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onEdit) {
            GlassSurface {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: entry.kind.icon)
                        .font(.headline)
                        .foregroundStyle(theme.palette.accent)
                        .frame(width: 26, height: 26)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 7) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(entry.kind.title).font(.subheadline.weight(.bold))
                            Spacer(minLength: 8)
                            Text(entry.occurredAt.formatted(date: .omitted, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(theme.palette.secondary)
                        }
                        if !entry.title.isEmpty { Text(entry.title).font(.headline) }
                        if let mood = entry.mood { Text("\(mood.emoji) \(mood.rawValue.capitalized)").font(.caption).foregroundStyle(theme.palette.secondary) }
                        if !entry.bodyText.isEmpty { Text(entry.bodyText).lineLimit(7).frame(maxWidth: .infinity, alignment: .leading) }
                        if let value = entry.value { Text("\(value.formatted()) \(entry.unit ?? "")").font(.title3.bold()) }
                        if let location = entry.location, !location.isEmpty { Label(location, systemImage: "mappin").font(.caption).foregroundStyle(theme.palette.secondary) }
                        if !entry.tags.isEmpty { Text(entry.tags.map { "#\($0)" }.joined(separator: "  ")).font(.caption).foregroundStyle(theme.palette.accent) }
                        if !entry.photos.isEmpty { PhotoStrip(data: entry.photos, height: 82) }
                        if entry.done { Label("Completed", systemImage: "checkmark.circle.fill").font(.caption).foregroundStyle(.green) }
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Edit", systemImage: "pencil", action: onEdit)
            Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
        }
    }
}

// MARK: - Editor

struct EntryEditorView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let entry: LogEntry?
    @State private var type: LogType = .journal
    @State private var title = ""
    @State private var bodyText = ""
    @State private var date = Date.now
    @State private var mood: Mood?
    @State private var tagsText = ""
    @State private var location = ""
    @State private var valueText = ""
    @State private var unit = ""
    @State private var done = false
    @State private var urlString = ""
    @State private var reminderEnabled = false
    @State private var reminderDate = Date.now.addingTimeInterval(3600)
    @State private var dividerLabel = ""
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var photos: [Data] = []
    @State private var loaded = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Record") {
                    Picker("Type", selection: $type) {
                        ForEach(LogType.allCases) { item in Text(item.title).tag(item) }
                    }
                    TextField("Title", text: $title)
                    TextEditor(text: $bodyText).frame(minHeight: 135)
                }

                if type == .mood || type == .journal {
                    Section("Mood") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Mood.allCases) { item in
                                    Button("\(item.emoji) \(item.rawValue.capitalized)") {
                                        mood = mood == item ? nil : item
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(mood == item ? theme.palette.accent : .secondary)
                                }
                            }
                        }
                    }
                }

                if [.weight, .steps, .sleep].contains(type) {
                    Section("Value") {
                        TextField("Value", text: $valueText).keyboardType(.decimalPad)
                        TextField("Unit", text: $unit)
                    }
                }

                if type == .todo {
                    Section { Toggle("Completed", isOn: $done) }
                }

                if type == .divider {
                    Section("Divider") { TextField("Label", text: $dividerLabel) }
                }

                Section("Photos") {
                    PhotosPicker(selection: $photoItems, maxSelectionCount: 24, matching: .images) {
                        Label("Add photos", systemImage: "photo.on.rectangle")
                    }
                    if !photos.isEmpty { PhotoStrip(data: photos, height: 95) }
                }

                Section("When") { DatePicker("Date & time", selection: $date) }

                Section("Place & tags") {
                    TextField("Location", text: $location)
                    TextField("Tags, comma separated", text: $tagsText)
                }

                Section("Link") {
                    TextField("https://…", text: $urlString)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Reminder") {
                    Toggle("Local reminder", isOn: $reminderEnabled)
                    if reminderEnabled { DatePicker("Remind me", selection: $reminderDate, in: Date.now...) }
                }
            }
            .scrollContentBackground(.hidden)
            .background(theme.palette.background)
            .tint(theme.palette.accent)
            .navigationTitle(entry == nil ? "New Perlog" : "Edit Perlog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save", action: save).fontWeight(.semibold) }
            }
            .task {
                if !loaded { loadEntry(); loaded = true }
            }
            .onChange(of: photoItems) { _, newItems in
                Task {
                    var loadedData: [Data] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self) { loadedData.append(data) }
                    }
                    await MainActor.run { photos = loadedData }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.ultraThinMaterial)
        .animation(reduceMotion ? nil : .snappy, value: type)
    }

    private func loadEntry() {
        guard let entry else { return }
        type = entry.kind
        title = entry.title
        bodyText = entry.bodyText
        date = entry.occurredAt
        mood = entry.mood
        tagsText = entry.tags.joined(separator: ", ")
        location = entry.location ?? ""
        valueText = entry.value.map { String(describing: $0) } ?? ""
        unit = entry.unit ?? ""
        done = entry.done
        photos = entry.photos
        urlString = entry.urlString ?? ""
        reminderEnabled = entry.reminderDate != nil
        reminderDate = entry.reminderDate ?? Date.now.addingTimeInterval(3600)
        dividerLabel = entry.dividerLabel ?? ""
    }

    private func save() {
        let cleanTags = tagsText
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let cleanLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanUnit = unit.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        let numericValue = Double(valueText)
        let reminder = reminderEnabled ? reminderDate : nil

        if let entry {
            entry.kind = type
            entry.title = title
            entry.bodyText = bodyText
            entry.occurredAt = date
            entry.updatedAt = .now
            entry.mood = mood
            entry.tags = cleanTags
            entry.location = cleanLocation.isEmpty ? nil : cleanLocation
            entry.value = numericValue
            entry.unit = cleanUnit.isEmpty ? nil : cleanUnit
            entry.done = done
            entry.photos = photos
            entry.urlString = cleanURL.isEmpty ? nil : cleanURL
            entry.reminderDate = reminder
            entry.dividerLabel = dividerLabel.isEmpty ? nil : dividerLabel
        } else {
            context.insert(LogEntry(
                kind: type,
                occurredAt: date,
                title: title,
                bodyText: bodyText,
                mood: mood,
                tags: cleanTags,
                location: cleanLocation.isEmpty ? nil : cleanLocation,
                value: numericValue,
                unit: cleanUnit.isEmpty ? nil : cleanUnit,
                done: done,
                photos: photos,
                urlString: cleanURL.isEmpty ? nil : cleanURL,
                reminderDate: reminder,
                dividerLabel: dividerLabel.isEmpty ? nil : dividerLabel
            ))
        }
        try? context.save()
        dismiss()
    }
}

struct PhotoStrip: View {
    let data: [Data]
    var height: CGFloat
    init(data: [Data], height: CGFloat = 85) { self.data = data; self.height = height }
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 9) {
                ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                    if let image = UIImage(data: item) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: height * 1.28, height: height)
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - Filter

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: LogType?
    var body: some View {
        NavigationStack {
            List {
                Button("Everything") { selection = nil; dismiss() }
                ForEach(LogType.allCases) { item in
                    Button { selection = item; dismiss() } label: { Label(item.title, systemImage: item.icon) }
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Memories

struct MemoriesView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Query(sort: [SortDescriptor<LogEntry>(\.occurredAt, order: .reverse)]) private var entries: [LogEntry]

    private var past: [LogEntry] { entries.filter { !Calendar.current.isDate($0.occurredAt, inSameDayAs: .now) }.prefix(18).map { $0 } }

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        Text("Memories").font(.largeTitle.bold())
                        Text("Rediscover moments from your personal log.").foregroundStyle(theme.palette.secondary)
                        if past.isEmpty {
                            GlassSurface { Text("Your memories will appear here as your personal log grows.").foregroundStyle(theme.palette.secondary) }
                        } else {
                            ForEach(past) { entry in
                                GlassSurface {
                                    VStack(alignment: .leading, spacing: 7) {
                                        Text(entry.occurredAt.formatted(date: .long, time: .shortened)).font(.caption).foregroundStyle(theme.palette.secondary)
                                        Text(entry.title.isEmpty ? entry.kind.title : entry.title).font(.headline)
                                        if !entry.bodyText.isEmpty { Text(entry.bodyText).lineLimit(5) }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                    .padding(18)
                    .padding(.bottom, 30)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Summary

struct SummaryView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Query private var entries: [LogEntry]

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Summary").font(.largeTitle.bold())
                        Text("A view of the life you have logged.").foregroundStyle(theme.palette.secondary)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            stat("\(entries.count)", "Perlogs", "clock")
                            stat("\(entries.filter { $0.kind == .journal }.count)", "Journal", "book.pages")
                            stat("\(entries.filter { !$0.photos.isEmpty }.count)", "Photos", "photo")
                            stat("\(entries.filter { $0.kind == .place }.count)", "Places", "mappin")
                            stat("\(entries.filter { $0.mood != nil }.count)", "Mood", "face.smiling")
                            stat("\(entries.filter { $0.kind == .todo }.count)", "To-Dos", "checklist")
                            stat("\(entries.filter { $0.kind == .meal }.count)", "Meals", "fork.knife")
                            stat("\(entries.filter { $0.kind == .music }.count)", "Music", "music.note")
                        }
                        GlassSurface {
                            VStack(alignment: .leading, spacing: 7) {
                                Text("Private by design").font(.headline)
                                Text("Your records are stored locally on this device. Perlog does not require an account or impose a record limit.").foregroundStyle(theme.palette.secondary)
                            }
                        }
                    }
                    .padding(18)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func stat(_ value: String, _ title: String, _ icon: String) -> some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 5) {
                Image(systemName: icon).foregroundStyle(theme.palette.accent)
                Text(value).font(.system(size: 28, weight: .bold, design: .rounded))
                Text(title).font(.caption).foregroundStyle(theme.palette.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Me / Theme Studio

struct MeView: View {
    @EnvironmentObject private var theme: ThemeStore
    @State private var showingThemeStudio = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Perlog").font(.largeTitle.bold())
                    Text("Your life, logged.").foregroundStyle(.secondary)
                }
                Section("Appearance") {
                    Button { showingThemeStudio = true } label: {
                        Label("Theme Studio · \(theme.name)", systemImage: "circle.lefthalf.filled")
                    }
                }
                Section("Data & privacy") {
                    Label("Local-first storage", systemImage: "internaldrive")
                    Label("No account required", systemImage: "person.crop.circle.badge.checkmark")
                    Label("No ads or tracking", systemImage: "eye.slash")
                    Text("Import/export and optional iCloud synchronization can be added without making the core personal log dependent on an account.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("About") {
                    Text("Perlog is a personal log: a unified chronological record for thoughts, moods, photos, places, meals, measurements, music, shopping, tasks, links, and moments worth remembering.")
                        .font(.footnote)
                }
            }
            .navigationTitle("Me")
            .sheet(isPresented: $showingThemeStudio) { ThemeStudioView() }
        }
    }
}

struct ThemeStudioView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityIncreaseContrast) private var increaseContrast
    @State private var accentColor = Color.blue
    @State private var backgroundColor = Color.white
    @State private var glassColor = Color.white
    @State private var primaryColor = Color.black
    @State private var secondaryColor = Color.gray

    private let names = ["Grey", "White", "Black", "Iridescent", "Custom"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Themes") {
                    ForEach(names, id: \.self) { name in
                        Button { theme.select(name); syncColors() } label: {
                            HStack(spacing: 12) {
                                Circle().fill(previewColor(name)).frame(width: 28, height: 28)
                                VStack(alignment: .leading) { Text(name); Text(description(name)).font(.caption).foregroundStyle(.secondary) }
                                Spacer()
                                if theme.name == name { Image(systemName: "checkmark.circle.fill") }
                            }
                        }
                    }
                }

                if theme.name == "Iridescent" {
                    Section("Iridescent hue") {
                        Slider(value: Binding(get: { theme.configuration.hue }, set: { theme.configuration.hue = $0 }), in: 0...360)
                        HStack { Text("Base hue"); Spacer(); Text("\(Int(theme.configuration.hue))°") }
                            .font(.caption)
                        Button("Reset hue") { theme.configuration.hue = 215 }
                    }
                }

                if theme.name == "Custom" {
                    Section("Custom palette") {
                        ColorPicker("Accent", selection: $accentColor, supportsOpacity: false)
                            .onChange(of: accentColor) { _, color in theme.setColor(color, keyPath: \.accentHex) }
                        ColorPicker("Background", selection: $backgroundColor, supportsOpacity: false)
                            .onChange(of: backgroundColor) { _, color in theme.setColor(color, keyPath: \.backgroundHex) }
                        ColorPicker("Glass tint", selection: $glassColor, supportsOpacity: false)
                            .onChange(of: glassColor) { _, color in theme.setColor(color, keyPath: \.glassHex) }
                        ColorPicker("Primary text", selection: $primaryColor, supportsOpacity: false)
                            .onChange(of: primaryColor) { _, color in theme.setColor(color, keyPath: \.primaryHex) }
                        ColorPicker("Secondary text", selection: $secondaryColor, supportsOpacity: false)
                            .onChange(of: secondaryColor) { _, color in theme.setColor(color, keyPath: \.secondaryHex) }
                        Text(increaseContrast ? "Higher contrast is enabled by the system." : "Choose readable text and surface combinations.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button("Restore defaults", role: .destructive) { theme.restoreDefaults(); syncColors() }
                    }
                }

                Section("Preview") {
                    GlassSurface {
                        HStack {
                            Image(systemName: "sparkles").foregroundStyle(theme.palette.accent)
                            VStack(alignment: .leading) { Text("Perlog").font(.headline); Text("Your life, logged.").font(.caption).foregroundStyle(theme.palette.secondary) }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(theme.palette.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Theme Studio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
            .task { syncColors() }
        }
        .presentationDetents([.large])
    }

    private func syncColors() {
        accentColor = Color(hex: theme.configuration.accentHex)
        backgroundColor = Color(hex: theme.configuration.backgroundHex)
        glassColor = Color(hex: theme.configuration.glassHex)
        primaryColor = Color(hex: theme.configuration.primaryHex)
        secondaryColor = Color(hex: theme.configuration.secondaryHex)
    }

    private func previewColor(_ name: String) -> Color {
        switch name {
        case "Black": return .black
        case "White": return Color(white: 0.95)
        case "Iridescent": return Color(hue: theme.configuration.hue / 360.0, saturation: 0.5, brightness: 0.95)
        case "Custom": return Color(hex: theme.configuration.accentHex)
        default: return Color(hex: "#E6E9EF")
        }
    }

    private func description(_ name: String) -> String {
        switch name {
        case "Black": return "Deep, high-contrast glass"
        case "White": return "Bright and frosted"
        case "Iridescent": return "Soft hue-shifting glass"
        case "Custom": return "Build your own palette"
        default: return "Neutral frosted glass"
        }
    }
}

// MARK: - First-launch samples

enum SeedEntries {
    private static let key = "Perlog.DidSeedSamples.v2"

    static func seedIfNeeded(context: ModelContext, existingCount: Int) {
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        guard existingCount == 0 else {
            UserDefaults.standard.set(true, forKey: key)
            return
        }

        let calendar = Calendar.current
        let now = Date.now
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now) ?? now
        let morning = calendar.date(bySettingHour: 9, minute: 15, second: 0, of: yesterday) ?? yesterday
        let evening = calendar.date(bySettingHour: 18, minute: 30, second: 0, of: yesterday) ?? yesterday

        context.insert(LogEntry(
            kind: .journal,
            occurredAt: morning,
            title: "Morning pages",
            bodyText: "Woke up early today. A small thought is still worth logging.",
            mood: .calm,
            tags: ["sample", "journal"]
        ))
        context.insert(LogEntry(
            kind: .mood,
            occurredAt: evening,
            title: "A good day",
            bodyText: "Felt present and noticed a few small things I want to remember.",
            mood: .happy,
            tags: ["sample", "mood"]
        ))
        try? context.save()
        UserDefaults.standard.set(true, forKey: key)
    }
}
