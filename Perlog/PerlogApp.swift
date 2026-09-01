import SwiftUI
import SwiftData
import PhotosUI

@main
struct PerlogApp: App {
    var body: some Scene {
        WindowGroup { RootView() }
            .modelContainer(for: LogEntry.self)
    }
}

enum LogType: String, Codable, CaseIterable, Identifiable {
    case journal, mood, photo, meal, shopping, place, music, weight, steps, sleep, todo
    var id: String { rawValue }
    var title: String { rawValue == "todo" ? "To-Do" : rawValue.capitalized }
    var icon: String {
        switch self {
        case .journal: "book.pages"
        case .mood: "face.smiling"
        case .photo: "photo"
        case .meal: "fork.knife"
        case .shopping: "bag"
        case .place: "mappin.and.ellipse"
        case .music: "music.note"
        case .weight: "scalemass"
        case .steps: "figure.walk"
        case .sleep: "bed.double"
        case .todo: "checklist"
        }
    }
}

enum Mood: String, Codable, CaseIterable, Identifiable {
    case radiant, happy, excited, calm, neutral, tired, anxious, annoyed, sad
    var id: String { rawValue }
    var emoji: String {
        switch self {
        case .radiant: "☀️"
        case .happy: "🙂"
        case .excited: "✨"
        case .calm: "🌿"
        case .neutral: "😐"
        case .tired: "😪"
        case .anxious: "😟"
        case .annoyed: "😤"
        case .sad: "😢"
        }
    }
}

@Model
final class LogEntry {
    var id: UUID
    var date: Date
    var typeRaw: String
    var title: String
    var bodyText: String
    var moodRaw: String?
    var tags: [String]
    var location: String?
    var value: Double?
    var unit: String?
    var done: Bool
    var photos: [Data]

    init(type: LogType = .journal, date: Date = Date(), title: String = "", bodyText: String = "", mood: Mood? = nil, tags: [String] = [], location: String? = nil, value: Double? = nil, unit: String? = nil, done: Bool = false, photos: [Data] = []) {
        id = UUID(); self.date = date; typeRaw = type.rawValue; self.title = title; self.bodyText = bodyText; moodRaw = mood?.rawValue; self.tags = tags; self.location = location; self.value = value; self.unit = unit; self.done = done; self.photos = photos
    }
    var type: LogType {
        get { LogType(rawValue: typeRaw) ?? .journal }
        set { typeRaw = newValue.rawValue }
    }
    var mood: Mood? {
        get { moodRaw.flatMap { Mood(rawValue: $0) } }
        set { moodRaw = newValue?.rawValue }
    }
}

struct Palette {
    let background: Color
    let primary: Color
    let secondary: Color
    let accent: Color
    let dark: Bool
}

final class ThemeStore: ObservableObject {
    @Published var theme = "Grey"
    @Published var hue: Double = 215
    var palette: Palette {
        switch theme {
        case "Black":
            Palette(background: .black, primary: .white, secondary: .gray, accent: Color(hue: hue / 360, saturation: 0.45, brightness: 1), dark: true)
        case "White":
            Palette(background: Color(white: 0.97), primary: .black, secondary: .gray, accent: Color(hue: hue / 360, saturation: 0.60, brightness: 1), dark: false)
        case "Iridescent":
            Palette(background: Color(hue: hue / 360, saturation: 0.08, brightness: 0.98), primary: Color(white: 0.08), secondary: .gray, accent: Color(hue: hue / 360, saturation: 0.70, brightness: 1), dark: false)
        default:
            Palette(background: Color(hex: "#E6E9EF"), primary: Color(hex: "#14161B"), secondary: Color(hex: "#646A76"), accent: Color(hex: "#5D8DFF"), dark: false)
        }
    }
}

extension Color {
    init(hex: String) {
        let s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let v = UInt64(s, radix: 16) ?? 0
        self.init(red: Double((v >> 16) & 255) / 255, green: Double((v >> 8) & 255) / 255, blue: Double(v & 255) / 255)
    }
}

struct GlassCard<Content: View>: View {
    @EnvironmentObject private var theme: ThemeStore
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content.padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(.white.opacity(theme.palette.dark ? 0.14 : 0.55), lineWidth: 1))
            .shadow(color: .black.opacity(0.10), radius: 18, y: 8)
    }
}

struct AmbientBackground: View {
    @EnvironmentObject private var theme: ThemeStore
    var body: some View {
        ZStack {
            theme.palette.background.ignoresSafeArea()
            Circle().fill(theme.palette.accent.opacity(0.12)).frame(width: 320).blur(radius: 75).offset(x: 150, y: -300)
            Circle().fill(Color.purple.opacity(0.06)).frame(width: 280).blur(radius: 80).offset(x: -150, y: 300)
        }
    }
}

struct RootView: View {
    @StateObject private var theme = ThemeStore()
    var body: some View {
        TabView {
            TimelineView().tabItem { Label("Timeline", systemImage: "clock") }
            MemoriesView().tabItem { Label("Memories", systemImage: "sparkles") }
            SummaryView().tabItem { Label("Summary", systemImage: "chart.xyaxis.line") }
            MeView().tabItem { Label("Me", systemImage: "person.crop.circle") }
        }
        .environmentObject(theme)
        .tint(theme.palette.accent)
    }
}

struct TimelineView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor<LogEntry>(\.date, order: .reverse)]) private var entries: [LogEntry]
    @State private var searchText = ""
    @State private var selectedType: LogType?
    @State private var showingEditor = false
    @State private var editingEntry: LogEntry?
    @State private var showingFilter = false

    private var filtered: [LogEntry] {
        entries.filter { entry in
            let typeOK = selectedType == nil || entry.type == selectedType
            let text = [entry.title, entry.bodyText, entry.location ?? "", entry.tags.joined(separator: " ")].joined(separator: " ")
            return typeOK && (searchText.isEmpty || text.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AmbientBackground()
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 18) {
                        header
                        search
                        filters
                        if filtered.isEmpty { emptyState }
                        ForEach(groupedDays, id: \.self) { day in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(day.formatted(.dateTime.weekday(.wide).month(.wide).day())).font(.headline)
                                ForEach(filtered.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }) { entry in
                                    EntryCard(entry: entry, onEdit: { edit(entry) }, onDelete: { delete(entry) })
                                }
                            }
                        }
                    }.padding(18).padding(.bottom, 90)
                }
                Button { edit(nil) } label: {
                    Image(systemName: "plus").font(.title2.bold()).frame(width: 58, height: 58)
                }
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.55), lineWidth: 1))
                .shadow(radius: 14, y: 6).padding(20)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingEditor) { EntryEditorView(entry: editingEntry) }
            .sheet(isPresented: $showingFilter) { FilterView(selection: $selectedType) }
        }
    }

    private var groupedDays: [Date] { Array(Set(filtered.map { Calendar.current.startOfDay(for: $0.date) })).sorted(by: >) }
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(greeting).font(.system(size: 32, weight: .bold, design: .rounded))
                Text("Your life, logged.").foregroundStyle(theme.palette.secondary)
            }
            Spacer()
            Button { showingFilter = true } label: { Image(systemName: "line.3.horizontal.decrease.circle").font(.title2) }
        }
    }
    private var search: some View {
        HStack { Image(systemName: "magnifyingglass"); TextField("Search your life…", text: $searchText) }
            .padding(14).background(.ultraThinMaterial, in: Capsule())
    }
    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 8) {
            chip(nil, "Everything", "square.grid.2x2")
            ForEach(LogType.allCases) { type in chip(type, type.title, type.icon) }
        }}
    }
    private func chip(_ type: LogType?, _ title: String, _ icon: String) -> some View {
        Button { selectedType = selectedType == type ? nil : type } label: {
            Label(title, systemImage: icon).font(.caption.bold()).padding(.horizontal, 12).padding(.vertical, 8)
                .background((selectedType == type ? theme.palette.accent.opacity(0.18) : Color.primary.opacity(0.06)), in: Capsule())
        }.buttonStyle(.plain)
    }
    private var emptyState: some View {
        GlassCard { VStack(alignment: .leading, spacing: 10) { Image(systemName: "book.closed").font(.largeTitle).foregroundStyle(theme.palette.accent); Text("Your personal log is ready.").font(.headline); Text("Capture a thought, moment, photo, place, mood, activity, or anything else worth remembering.").foregroundStyle(theme.palette.secondary) } }
    }
    private var greeting: String { let h = Calendar.current.component(.hour, from: Date()); return h < 12 ? "Good morning" : h < 18 ? "Good afternoon" : "Good evening" }
    private func edit(_ entry: LogEntry?) { editingEntry = entry; showingEditor = true }
    private func delete(_ entry: LogEntry) { context.delete(entry); try? context.save() }
}

struct EntryCard: View {
    @EnvironmentObject private var theme: ThemeStore
    let entry: LogEntry
    let onEdit: () -> Void
    let onDelete: () -> Void
    var body: some View {
        Button(action: onEdit) {
            GlassCard {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: entry.type.icon).foregroundStyle(theme.palette.accent).frame(width: 24)
                    VStack(alignment: .leading, spacing: 7) {
                        HStack { Text(entry.type.title).font(.subheadline.bold()); Spacer(); Text(entry.date.formatted(date: .omitted, time: .shortened)).font(.caption).foregroundStyle(theme.palette.secondary) }
                        if !entry.title.isEmpty { Text(entry.title).font(.headline) }
                        if let mood = entry.mood { Text("\(mood.emoji) \(mood.rawValue.capitalized)").font(.caption).foregroundStyle(theme.palette.secondary) }
                        if !entry.bodyText.isEmpty { Text(entry.bodyText).lineLimit(7) }
                        if let value = entry.value { Text("\(value.formatted()) \(entry.unit ?? "")").font(.title3.bold()) }
                        if let location = entry.location, !location.isEmpty { Label(location, systemImage: "mappin").font(.caption).foregroundStyle(theme.palette.secondary) }
                        if !entry.tags.isEmpty { Text(entry.tags.map { "#\($0)" }.joined(separator: "  ")).font(.caption).foregroundStyle(theme.palette.accent) }
                    }
                }
            }
        }.buttonStyle(.plain).contextMenu { Button("Delete", role: .destructive, action: onDelete) }
    }
}

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: LogType?
    var body: some View {
        NavigationStack { List {
            Button("Everything") { selection = nil; dismiss() }
            ForEach(LogType.allCases) { type in Button { selection = type; dismiss() } label: { Label(type.title, systemImage: type.icon) } }
        }.navigationTitle("Filter") }
    }
}

struct EntryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    let entry: LogEntry?
    @State private var type: LogType = .journal
    @State private var title = ""
    @State private var bodyText = ""
    @State private var date = Date()
    @State private var mood: Mood?
    @State private var tagsText = ""
    @State private var location = ""
    @State private var valueText = ""
    @State private var unit = ""
    @State private var done = false
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var photos: [Data] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Record") {
                    Picker("Type", selection: $type) { ForEach(LogType.allCases) { Text($0.title).tag($0) } }
                    TextField("Title", text: $title)
                    TextEditor(text: $bodyText).frame(minHeight: 130)
                }
                Section("Mood") {
                    ScrollView(.horizontal, showsIndicators: false) { HStack { ForEach(Mood.allCases) { m in Button("\(m.emoji) \(m.rawValue.capitalized)") { mood = mood == m ? nil : m }.buttonStyle(.bordered) } } }
                }
                if [.weight, .steps, .sleep].contains(type) { Section("Value") { TextField("Value", text: $valueText).keyboardType(.decimalPad); TextField("Unit", text: $unit) } }
                if type == .todo { Section { Toggle("Completed", isOn: $done) } }
                Section("Photos") { PhotosPicker(selection: $photoItems, maxSelectionCount: 12, matching: .images) { Label("Add photos", systemImage: "photo.on.rectangle") }; PhotoStrip(data: photos) }
                Section("When") { DatePicker("Date & time", selection: $date) }
                Section("Place & tags") { TextField("Location", text: $location); TextField("Tags, comma separated", text: $tagsText) }
            }
            .navigationTitle(entry == nil ? "New Perlog" : "Edit Perlog")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }; ToolbarItem(placement: .confirmationAction) { Button("Save", action: save) } }
            .task { loadEntry() }
            .onChange(of: photoItems) { _, newItems in Task { var loaded: [Data] = []; for item in newItems { if let data = try? await item.loadTransferable(type: Data.self) { loaded.append(data) } }; photos = loaded } }
        }
    }
    private func loadEntry() {
        guard let entry else { return }
        type = entry.type; title = entry.title; bodyText = entry.bodyText; date = entry.date; mood = entry.mood; tagsText = entry.tags.joined(separator: ", "); location = entry.location ?? ""; valueText = entry.value.map { String($0) } ?? ""; unit = entry.unit ?? ""; done = entry.done; photos = entry.photos
    }
    private func save() {
        let tags = tagsText.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let place = location.trimmingCharacters(in: .whitespacesAndNewlines)
        let measurementUnit = unit.trimmingCharacters(in: .whitespacesAndNewlines)
        let number = Double(valueText)
        if let entry {
            entry.type = type; entry.title = title; entry.bodyText = bodyText; entry.date = date; entry.mood = mood; entry.tags = tags; entry.location = place.isEmpty ? nil : place; entry.value = number; entry.unit = measurementUnit.isEmpty ? nil : measurementUnit; entry.done = done; entry.photos = photos
        } else {
            context.insert(LogEntry(type: type, date: date, title: title, bodyText: bodyText, mood: mood, tags: tags, location: place.isEmpty ? nil : place, value: number, unit: measurementUnit.isEmpty ? nil : measurementUnit, done: done, photos: photos))
        }
        try? context.save(); dismiss()
    }
}

struct PhotoStrip: View {
    let data: [Data]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 10) { ForEach(Array(data.enumerated()), id: \.offset) { _, data in if let image = UIImage(data: data) { Image(uiImage: image).resizable().scaledToFill().frame(width: 110, height: 85).clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous)) } } } }
    }
}

struct MemoriesView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Query(sort: [SortDescriptor<LogEntry>(\.date, order: .reverse)]) private var entries: [LogEntry]
    var body: some View {
        NavigationStack { ZStack { AmbientBackground(); ScrollView { VStack(alignment: .leading, spacing: 18) { Text("Memories").font(.largeTitle.bold()); Text("Rediscover moments from your personal log.").foregroundStyle(theme.palette.secondary); ForEach(entries.prefix(12)) { entry in GlassCard { VStack(alignment: .leading, spacing: 7) { Text(entry.date.formatted(date: .long, time: .shortened)).font(.caption).foregroundStyle(theme.palette.secondary); Text(entry.title.isEmpty ? entry.type.title : entry.title).font(.headline); if !entry.bodyText.isEmpty { Text(entry.bodyText).lineLimit(5) } } } } }.padding(18) } } }.toolbar(.hidden, for: .navigationBar)
    }
}

struct SummaryView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Query private var entries: [LogEntry]
    var body: some View {
        NavigationStack { ZStack { AmbientBackground(); ScrollView { VStack(alignment: .leading, spacing: 18) { Text("Summary").font(.largeTitle.bold()); Text("A view of the life you have logged.").foregroundStyle(theme.palette.secondary); LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) { stat("\(entries.count)", "Perlogs", "clock"); stat("\(entries.filter { $0.type == .journal }.count)", "Journal", "book.pages"); stat("\(entries.filter { !$0.photos.isEmpty }.count)", "Photos", "photo"); stat("\(entries.filter { $0.type == .place }.count)", "Places", "mappin"); stat("\(entries.filter { $0.mood != nil }.count)", "Mood", "face.smiling"); stat("\(entries.filter { $0.type == .todo }.count)", "To-Dos", "checklist") }; GlassCard { Text("Your history is stored locally. There is no app-imposed record limit.").foregroundStyle(theme.palette.secondary) } }.padding(18) } } }.toolbar(.hidden, for: .navigationBar)
    }
    private func stat(_ value: String, _ title: String, _ icon: String) -> some View { GlassCard { VStack(alignment: .leading, spacing: 5) { Image(systemName: icon).foregroundStyle(theme.palette.accent); Text(value).font(.system(size: 28, weight: .bold, design: .rounded)); Text(title).font(.caption).foregroundStyle(theme.palette.secondary) }.frame(maxWidth: .infinity, alignment: .leading) } }
}

struct MeView: View {
    @EnvironmentObject private var theme: ThemeStore
    @State private var showingTheme = false
    var body: some View {
        NavigationStack { List { Section { Text("Perlog").font(.largeTitle.bold()); Text("Your life, logged.").foregroundStyle(.secondary) }; Section("Appearance") { Button { showingTheme = true } label: { Label("Theme Studio · \(theme.theme)", systemImage: "circle.lefthalf.filled") } }; Section("Data & privacy") { Label("Local-first storage", systemImage: "internaldrive"); Label("No account required", systemImage: "person.crop.circle.badge.checkmark"); Label("No ads or tracking", systemImage: "eye.slash") }; Section("About") { Text("Perlog is a personal log: a unified chronological record for thoughts, moods, photos, places, meals, measurements, music, shopping and tasks.").font(.footnote) } }.navigationTitle("Me").sheet(isPresented: $showingTheme) { ThemeStudioView() } }
    }
}

struct ThemeStudioView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeStore
    var body: some View {
        NavigationStack { Form { Section("Themes") { ForEach(["Grey", "White", "Black", "Iridescent"], id: \.self) { option in Button { theme.theme = option } label: { HStack { Text(option); Spacer(); if theme.theme == option { Image(systemName: "checkmark") } } } } }; if theme.theme == "Iridescent" { Section("Hue") { Slider(value: $theme.hue, in: 0...360); Text("\(Int(theme.hue))°") } } }.navigationTitle("Theme Studio").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } } }
    }
}
