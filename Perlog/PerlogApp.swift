import SwiftUI
import SwiftData
import UIKit
import PhotosUI
import UniformTypeIdentifiers

// MARK: - App

@main
struct PerlogApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
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
        case .todo: return "To-Do"
        case .divider: return "Divider"
        default: return rawValue.capitalized
        }
    }

    var icon: String {
        switch self {
        case .journal: return "book.closed.fill"
        case .mood: return "face.smiling.fill"
        case .photo: return "photo.fill"
        case .meal: return "fork.knife"
        case .shopping: return "bag.fill"
        case .place: return "mappin.circle.fill"
        case .music: return "music.note"
        case .weight: return "scalemass.fill"
        case .steps: return "figure.walk"
        case .sleep: return "bed.double.fill"
        case .todo: return "checklist"
        case .divider: return "rectangle.split.3x1.fill"
        }
    }

    var accent: Color {
        switch self {
        case .journal: return .blue
        case .mood: return .yellow
        case .photo: return .purple
        case .meal: return .orange
        case .shopping: return .pink
        case .place: return .green
        case .music: return .purple
        case .weight: return .cyan
        case .steps: return .blue
        case .sleep: return .indigo
        case .todo: return .mint
        case .divider: return .orange
        }
    }
}

enum Mood: String, Codable, CaseIterable, Identifiable {
    case radiant, happy, excited, calm, neutral, tired, anxious, annoyed, sad

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .radiant: return "☀️"
        case .happy: return "🙂"
        case .excited: return "✨"
        case .calm: return "🌿"
        case .neutral: return "😐"
        case .tired: return "😪"
        case .anxious: return "😟"
        case .annoyed: return "😤"
        case .sad: return "😢"
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

    init(
        type: LogType = .journal,
        date: Date = .now,
        title: String = "",
        bodyText: String = "",
        mood: Mood? = nil,
        tags: [String] = [],
        location: String? = nil,
        value: Double? = nil,
        unit: String? = nil,
        done: Bool = false,
        photos: [Data] = []
    ) {
        self.id = UUID()
        self.date = date
        self.typeRaw = type.rawValue
        self.title = title
        self.bodyText = bodyText
        self.moodRaw = mood?.rawValue
        self.tags = tags
        self.location = location
        self.value = value
        self.unit = unit
        self.done = done
        self.photos = photos
    }

    var type: LogType {
        get { LogType(rawValue: typeRaw) ?? .journal }
        set { typeRaw = newValue.rawValue }
    }

    var mood: Mood? {
        get { moodRaw.flatMap(Mood.init(rawValue:)) }
        set { moodRaw = newValue?.rawValue }
    }
}

// MARK: - Theme

enum PerlogThemeName: String, CaseIterable, Identifiable {
    case black = "Black"
    case grey = "Grey"
    case white = "White"
    case iridescent = "Iridescent"
    case custom = "Custom"

    var id: String { rawValue }
}

struct PerlogPalette {
    let background: Color
    let backgroundSecondary: Color
    let surface: Color
    let surfaceStrong: Color
    let text: Color
    let secondaryText: Color
    let accent: Color
    let border: Color
    let isDark: Bool
}

@MainActor
final class ThemeStore: ObservableObject {
    @Published var name: PerlogThemeName
    @Published var hue: Double
    @Published var customAccent: Color
    @Published var customBackground: Color
    @Published var customGlass: Color
    @Published var customText: Color
    @Published var customSecondaryText: Color

    private let defaults = UserDefaults.standard

    init() {
        let raw = UserDefaults.standard.string(forKey: "perlog.theme") ?? PerlogThemeName.black.rawValue
        name = PerlogThemeName(rawValue: raw) ?? .black
        hue = UserDefaults.standard.object(forKey: "perlog.hue") as? Double ?? 220
        customAccent = Color(hex: UserDefaults.standard.string(forKey: "perlog.customAccent") ?? "5B8CFF")
        customBackground = Color(hex: UserDefaults.standard.string(forKey: "perlog.customBackground") ?? "101217")
        customGlass = Color(hex: UserDefaults.standard.string(forKey: "perlog.customGlass") ?? "1C2230")
        customText = Color(hex: UserDefaults.standard.string(forKey: "perlog.customText") ?? "FFFFFF")
        customSecondaryText = Color(hex: UserDefaults.standard.string(forKey: "perlog.customSecondaryText") ?? "AEB5C3")
    }

    var palette: PerlogPalette {
        switch name {
        case .black:
            return PerlogPalette(
                background: Color(hex: "080A0F"),
                backgroundSecondary: Color(hex: "10141C"),
                surface: Color.white.opacity(0.075),
                surfaceStrong: Color.white.opacity(0.115),
                text: .white,
                secondaryText: Color(hex: "AEB5C3"),
                accent: Color(hue: hue / 360.0, saturation: 0.62, brightness: 1.0),
                border: Color.white.opacity(0.15),
                isDark: true
            )
        case .grey:
            return PerlogPalette(
                background: Color(hex: "171A20"),
                backgroundSecondary: Color(hex: "22262E"),
                surface: Color.white.opacity(0.09),
                surfaceStrong: Color.white.opacity(0.13),
                text: .white,
                secondaryText: Color(hex: "B7BCC6"),
                accent: Color(hue: hue / 360.0, saturation: 0.55, brightness: 1),
                border: Color.white.opacity(0.17),
                isDark: true
            )
        case .white:
            return PerlogPalette(
                background: Color(hex: "F4F6FA"),
                backgroundSecondary: Color(hex: "E9EDF4"),
                surface: Color.white.opacity(0.74),
                surfaceStrong: Color.white.opacity(0.9),
                text: Color(hex: "12151B"),
                secondaryText: Color(hex: "626977"),
                accent: Color(hue: hue / 360.0, saturation: 0.62, brightness: 0.95),
                border: Color.white.opacity(0.9),
                isDark: false
            )
        case .iridescent:
            let c = Color(hue: hue / 360.0, saturation: 0.68, brightness: 1)
            return PerlogPalette(
                background: Color(hex: "0B0D14"),
                backgroundSecondary: Color(hex: "151224"),
                surface: c.opacity(0.09),
                surfaceStrong: c.opacity(0.15),
                text: .white,
                secondaryText: Color(hex: "C1C5D2"),
                accent: c,
                border: c.opacity(0.25),
                isDark: true
            )
        case .custom:
            let dark = customBackground.relativeLuminance < 0.45
            return PerlogPalette(
                background: customBackground,
                backgroundSecondary: customBackground.opacity(0.78),
                surface: customGlass.opacity(0.48),
                surfaceStrong: customGlass.opacity(0.70),
                text: customText,
                secondaryText: customSecondaryText,
                accent: customAccent,
                border: customText.opacity(dark ? 0.16 : 0.12),
                isDark: dark
            )
        }
    }

    func select(_ value: PerlogThemeName) {
        name = value
        persist()
    }

    func setHue(_ value: Double) {
        hue = value
        defaults.set(value, forKey: "perlog.hue")
    }

    func setCustomAccent(_ color: Color) { customAccent = color; persistCustom() }
    func setCustomBackground(_ color: Color) { customBackground = color; persistCustom() }
    func setCustomGlass(_ color: Color) { customGlass = color; persistCustom() }
    func setCustomText(_ color: Color) { customText = color; persistCustom() }
    func setCustomSecondaryText(_ color: Color) { customSecondaryText = color; persistCustom() }

    func resetCustom() {
        customAccent = Color(hex: "5B8CFF")
        customBackground = Color(hex: "101217")
        customGlass = Color(hex: "1C2230")
        customText = Color(hex: "FFFFFF")
        customSecondaryText = Color(hex: "AEB5C3")
        persistCustom()
    }

    func resetIridescent() { setHue(220) }

    private func persist() { defaults.set(name.rawValue, forKey: "perlog.theme") }

    private func persistCustom() {
        defaults.set(customAccent.hexString, forKey: "perlog.customAccent")
        defaults.set(customBackground.hexString, forKey: "perlog.customBackground")
        defaults.set(customGlass.hexString, forKey: "perlog.customGlass")
        defaults.set(customText.hexString, forKey: "perlog.customText")
        defaults.set(customSecondaryText.hexString, forKey: "perlog.customSecondaryText")
        objectWillChange.send()
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.replacingOccurrences(of: "#", with: "")
        let value = UInt64(cleaned, radix: 16) ?? 0
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }

    var hexString: String {
        let resolved = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        guard resolved.getRed(&r, green: &g, blue: &b, alpha: &a) else { return "FFFFFF" }
        return String(format: "%02X%02X%02X", Int(max(0, min(1, r)) * 255), Int(max(0, min(1, g)) * 255), Int(max(0, min(1, b)) * 255))
    }

    var relativeLuminance: Double {
        #if canImport(UIKit)
        let resolved = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if resolved.getRed(&r, green: &g, blue: &b, alpha: &a) {
            func linear(_ v: CGFloat) -> Double { let x = Double(v); return x <= 0.03928 ? x / 12.92 : pow((x + 0.055) / 1.055, 2.4) }
            return 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)
        }
        #endif
        return 0.15
    }
}

// MARK: - Reusable visual system

struct PerlogBackground: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                theme.palette.background
                    .ignoresSafeArea()

                if !reduceTransparency {
                    Circle()
                        .fill(theme.palette.accent.opacity(theme.name == .iridescent ? 0.22 : 0.10))
                        .frame(width: min(proxy.size.width * 0.95, 390))
                        .blur(radius: 70)
                        .offset(x: proxy.size.width * 0.38, y: -proxy.size.height * 0.35)

                    Circle()
                        .fill(Color.purple.opacity(theme.name == .iridescent ? 0.13 : 0.055))
                        .frame(width: min(proxy.size.width * 0.8, 330))
                        .blur(radius: 80)
                        .offset(x: -proxy.size.width * 0.4, y: proxy.size.height * 0.25)
                }

                if theme.name == .iridescent && !reduceTransparency {
                    LinearGradient(
                        colors: [
                            theme.palette.accent.opacity(0.10),
                            Color.purple.opacity(0.06),
                            Color.cyan.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct GlassCard<Content: View>: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .background {
                if reduceTransparency {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(theme.palette.surfaceStrong)
                } else {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(theme.palette.surface))
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(theme.palette.border, lineWidth: 0.8)
            )
            .shadow(color: .black.opacity(theme.palette.isDark ? 0.30 : 0.08), radius: 18, y: 9)
    }
}

struct GlassPill: View {
    @EnvironmentObject private var theme: ThemeStore
    let title: String
    let systemImage: String?
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title).lineLimit(1)
            }
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(selected ? theme.palette.text : theme.palette.secondaryText)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(selected ? theme.palette.accent.opacity(0.26) : theme.palette.surface, in: Capsule())
            .overlay(Capsule().stroke(selected ? theme.palette.accent.opacity(0.45) : theme.palette.border, lineWidth: 0.7))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Root

struct RootView: View {
    @StateObject private var theme = ThemeStore()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TabView {
            TimelineView()
                .tabItem { Label("Timeline", systemImage: "clock") }
            MemoriesView()
                .tabItem { Label("Memories", systemImage: "sparkles") }
            SummaryView()
                .tabItem { Label("Summary", systemImage: "chart.xyaxis.line") }
            MeView()
                .tabItem { Label("Me", systemImage: "person.crop.circle") }
        }
        .environmentObject(theme)
        .tint(theme.palette.accent)
        .preferredColorScheme(theme.palette.isDark ? .dark : .light)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: theme.name)
    }
}

// MARK: - Timeline

struct TimelineView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: [SortDescriptor<LogEntry>(\.date, order: .reverse)]) private var entries: [LogEntry]

    @State private var searchText = ""
    @State private var selectedType: LogType?
    @State private var showingEditor = false
    @State private var editingEntry: LogEntry?
    @State private var showingFilter = false
    @State private var showingThemeStudio = false
    @State private var deletedEntry: LogEntry?
    @State private var showingDeleteAlert = false
    @State private var showingQuickAdd = false

    private var filteredEntries: [LogEntry] {
        entries.filter { entry in
            let matchesType = selectedType == nil || entry.type == selectedType
            guard !searchText.isEmpty else { return matchesType }
            let haystack = [entry.title, entry.bodyText, entry.location ?? "", entry.tags.joined(separator: " ")].joined(separator: " ")
            return matchesType && haystack.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groupedDays: [Date] {
        Array(Set(filteredEntries.map { Calendar.current.startOfDay(for: $0.date) })).sorted(by: >)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ZStack(alignment: .bottomTrailing) {
                    PerlogBackground()

                    ScrollView(.vertical) {
                        LazyVStack(alignment: .leading, spacing: 15) {
                            topBar
                            dayHeader
                            searchBar
                            quickContext
                            filterStrip

                            if filteredEntries.isEmpty {
                                emptyState
                            } else {
                                ForEach(groupedDays, id: \.self) { day in
                                    daySection(day)
                                }
                            }
                        }
                        .frame(maxWidth: min(proxy.size.width, 760))
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, horizontalPadding(for: proxy.size.width))
                        .padding(.top, 10)
                        .padding(.bottom, 112)
                    }
                    .scrollIndicators(.hidden)

                    quickAddButton
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingEditor) {
                EntryEditorView(entry: editingEntry)
                    .environmentObject(theme)
            }
            .sheet(isPresented: $showingQuickAdd) {
                QuickAddView { type in
                    showingQuickAdd = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        editingEntry = nil
                        selectedType = type
                        showingEditor = true
                    }
                }
                .environmentObject(theme)
                .presentationDetents([.height(300), .medium])
            }
            .sheet(isPresented: $showingFilter) {
                FilterView(selection: $selectedType)
                    .environmentObject(theme)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showingThemeStudio) {
                ThemeStudioView()
                    .environmentObject(theme)
            }
            .alert("Delete this record?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let deletedEntry { performDelete(deletedEntry) }
                }
                Button("Cancel", role: .cancel) { }
            }
            .overlay(alignment: .bottom) {
                if let deletedEntry {
                    UndoBanner {
                        context.insert(deletedEntry)
                        self.deletedEntry = nil
                        try? context.save()
                    } onDismiss: {
                        self.deletedEntry = nil
                    }
                    .padding(.bottom, 82)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }

    private func horizontalPadding(for width: CGFloat) -> CGFloat {
        width < 360 ? 12 : 18
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Text("Perlog")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Spacer(minLength: 0)
                Button { } label: { Image(systemName: "magnifyingglass") }
                    .accessibilityLabel("Search")
                Button { showingThemeStudio = true } label: { Image(systemName: "ellipsis") }
                    .accessibilityLabel("Open Theme Studio")
            }
            .foregroundStyle(theme.palette.text)
            .padding(.horizontal, 12)
            .frame(height: 38)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(theme.palette.border, lineWidth: 0.8))
        }
    }

    private var dayHeader: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 3) {
                Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.palette.text)
                HStack(spacing: 5) {
                    Text("☀️")
                    Text("Happy")
                    Text("•")
                    Text("\(entries.count) records")
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(theme.palette.secondaryText)
            }
            Spacer()
        }
        .padding(.top, 5)
    }

    private var searchBar: some View {
        HStack(spacing: 9) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(theme.palette.secondaryText)
            TextField("Search your log", text: $searchText)
                .textInputAutocapitalization(.never)
                .foregroundStyle(theme.palette.text)
            if !searchText.isEmpty {
                Button { searchText = "" } label: { Image(systemName: "xmark.circle.fill") }
                    .foregroundStyle(theme.palette.secondaryText)
            }
        }
        .font(.system(size: 14))
        .padding(.horizontal, 14)
        .frame(height: 42)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(theme.palette.border, lineWidth: 0.8))
    }

    private var quickContext: some View {
        GlassCard {
            HStack(spacing: 10) {
                Image(systemName: "wand.and.stars")
                    .foregroundStyle(theme.palette.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your personal log")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                    Text("Capture anything worth remembering.")
                        .font(.system(size: 11))
                        .foregroundStyle(theme.palette.secondaryText)
                }
                Spacer()
                Button("Theme") { showingThemeStudio = true }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(theme.palette.accent)
            }
        }
    }

    private var filterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                GlassPill(title: "Everything", systemImage: "square.grid.2x2.fill", selected: selectedType == nil) {
                    selectedType = nil
                }
                ForEach(LogType.allCases) { type in
                    GlassPill(title: type.title, systemImage: type.icon, selected: selectedType == type) {
                        selectedType = selectedType == type ? nil : type
                    }
                }
            }
        }
    }

    private func daySection(_ day: Date) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(day.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(theme.palette.secondaryText)
                .padding(.horizontal, 3)

            ForEach(filteredEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }) { entry in
                EntryCard(entry: entry, onEdit: { edit(entry) }, onDelete: { askDelete(entry) })
            }
        }
    }

    private var emptyState: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: selectedType == nil ? "plus.circle" : selectedType!.icon)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(theme.palette.accent)
                Text(selectedType == nil ? "Your personal log is ready." : "No \(selectedType!.title.lowercased()) records yet.")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.palette.text)
                Text("Capture a thought, photo, place, mood, activity, task, or anything else worth keeping.")
                    .font(.system(size: 13))
                    .foregroundStyle(theme.palette.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var quickAddButton: some View {
        Button { showingQuickAdd = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                Text("Log")
            }
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .frame(height: 52)
            .background(theme.palette.accent, in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.30), lineWidth: 0.8))
            .shadow(color: theme.palette.accent.opacity(0.30), radius: 18, y: 7)
        }
        .accessibilityLabel("Add record")
        .padding(.trailing, 18)
        .padding(.bottom, 18)
    }

    private func edit(_ entry: LogEntry?) {
        editingEntry = entry
        showingEditor = true
    }

    private func askDelete(_ entry: LogEntry) {
        editingEntry = nil
        deletedEntry = entry
        showingDeleteAlert = true
    }

    private func performDelete(_ entry: LogEntry) {
        context.delete(entry)
        try? context.save()
        withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.9)) { }
    }
}

// MARK: - Entry Card / Detail

struct EntryCard: View {
    @EnvironmentObject private var theme: ThemeStore
    let entry: LogEntry
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onEdit) {
            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .center, spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(entry.type.accent.opacity(0.18))
                            Image(systemName: entry.type.icon)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(entry.type.accent)
                        }
                        .frame(width: 30, height: 30)

                        Text(entry.type.title)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.palette.text)
                        Spacer()
                        Text(entry.date.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(theme.palette.secondaryText)
                        Image(systemName: "ellipsis")
                            .foregroundStyle(theme.palette.secondaryText)
                    }

                    if !entry.title.isEmpty {
                        Text(entry.title)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.palette.text)
                    }

                    if let mood = entry.mood {
                        Text("\(mood.emoji)  \(mood.rawValue.capitalized)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(theme.palette.secondaryText)
                    }

                    if !entry.bodyText.isEmpty {
                        Text(entry.bodyText)
                            .font(.system(size: 13))
                            .foregroundStyle(theme.palette.text.opacity(0.92))
                            .lineLimit(5)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if !entry.photos.isEmpty {
                        PhotoStrip(data: entry.photos, height: 86)
                    }

                    HStack(spacing: 7) {
                        if let value = entry.value {
                            Label("\(value.formatted()) \(entry.unit ?? "")", systemImage: entry.type.icon)
                        }
                        if let location = entry.location, !location.isEmpty {
                            Label(location, systemImage: "mappin")
                        }
                        if entry.done {
                            Label("Done", systemImage: "checkmark.circle.fill")
                        }
                        Spacer(minLength: 0)
                    }
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(theme.palette.secondaryText)

                    if !entry.tags.isEmpty {
                        Text(entry.tags.map { "#\($0)" }.joined(separator: "   "))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(theme.palette.accent)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button { onEdit() } label: { Label("Edit", systemImage: "pencil") }
            Button(role: .destructive) { onDelete() } label: { Label("Delete", systemImage: "trash") }
        }
    }
}

struct RecordDetailView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.dismiss) private var dismiss
    let entry: LogEntry
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                PerlogBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        if !entry.photos.isEmpty {
                            PhotoStrip(data: entry.photos, height: 240, cornerRadius: 20)
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Label(entry.type.title, systemImage: entry.type.icon)
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundStyle(entry.type.accent)
                                    Spacer()
                                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(theme.palette.secondaryText)
                                }
                                if !entry.title.isEmpty { Text(entry.title).font(.title2.bold()) }
                                if !entry.bodyText.isEmpty { Text(entry.bodyText).font(.body) }
                                if let mood = entry.mood { Text("\(mood.emoji)  \(mood.rawValue.capitalized)") }
                                if let location = entry.location { Label(location, systemImage: "mappin.circle.fill") }
                                if let value = entry.value { Text("\(value.formatted()) \(entry.unit ?? "")").font(.title3.bold()) }
                                if !entry.tags.isEmpty { Text(entry.tags.map { "#\($0)" }.joined(separator: "  ")).foregroundStyle(theme.palette.accent) }
                            }
                        }

                        HStack(spacing: 10) {
                            Button { onEdit() } label: {
                                Label("Edit", systemImage: "pencil")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PerlogSecondaryButtonStyle())

                            Button(role: .destructive) { onDelete() } label: {
                                Label("Delete", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PerlogSecondaryButtonStyle())
                        }
                    }
                    .padding(18)
                }
            }
            .navigationTitle("Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
            }
        }
    }
}

// MARK: - Add / Edit

struct QuickAddView: View {
    @EnvironmentObject private var theme: ThemeStore
    let onSelect: (LogType) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                PerlogBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("New record")
                            .font(.title2.bold())
                            .padding(.horizontal, 18)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 10)], spacing: 10) {
                            ForEach(LogType.allCases) { type in
                                Button { onSelect(type) } label: {
                                    VStack(spacing: 7) {
                                        Image(systemName: type.icon)
                                            .font(.title3.bold())
                                            .foregroundStyle(type.accent)
                                        Text(type.title)
                                            .font(.caption.bold())
                                            .foregroundStyle(theme.palette.text)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 70)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(theme.palette.border, lineWidth: 0.7))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 18)
                    }
                    .padding(.vertical, 14)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct EntryEditorView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let entry: LogEntry?

    @State private var type: LogType
    @State private var title = ""
    @State private var bodyText = ""
    @State private var date = Date.now
    @State private var mood: Mood?
    @State private var tagsText = ""
    @State private var location = ""
    @State private var valueText = ""
    @State private var unit = ""
    @State private var done = false
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var photos: [Data] = []
    @State private var initialized = false

    init(entry: LogEntry?) {
        self.entry = entry
        _type = State(initialValue: entry?.type ?? .journal)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PerlogBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        typeSelector
                        contentCard
                        metadataCard
                        photoCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(entry == nil ? "New Record" : "Edit Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.bold)
                }
            }
            .task {
                guard !initialized else { return }
                initialized = true
                loadEntry()
            }
            .onChange(of: photoItems) { _, newItems in
                Task {
                    var loaded: [Data] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            loaded.append(data)
                        }
                    }
                    await MainActor.run { photos = loaded }
                }
            }
        }
        .presentationBackground(.clear)
        .presentationDragIndicator(.visible)
    }

    private var typeSelector: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Record type")
                .font(.caption.bold())
                .foregroundStyle(theme.palette.secondaryText)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(LogType.allCases) { option in
                        GlassPill(title: option.title, systemImage: option.icon, selected: type == option) {
                            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) { type = option }
                        }
                    }
                }
            }
        }
    }

    private var contentCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 13) {
                TextField("Title", text: $title)
                    .font(.headline)
                    .foregroundStyle(theme.palette.text)
                TextEditor(text: $bodyText)
                    .frame(minHeight: 145)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(theme.palette.text)
                    .overlay(alignment: .topLeading) {
                        if bodyText.isEmpty {
                            Text(type == .todo ? "What needs to be done?" : "Write anything worth remembering…")
                                .foregroundStyle(theme.palette.secondaryText.opacity(0.75))
                                .allowsHitTesting(false)
                                .padding(.top, 8)
                        }
                    }
            }
        }
    }

    private var metadataCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("When", systemImage: "calendar")
                    Spacer()
                    DatePicker("", selection: $date)
                        .labelsHidden()
                }

                if type == .mood || mood != nil {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mood").font(.caption.bold()).foregroundStyle(theme.palette.secondaryText)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 7) {
                                ForEach(Mood.allCases) { option in
                                    GlassPill(title: "\(option.emoji) \(option.rawValue.capitalized)", systemImage: nil, selected: mood == option) {
                                        mood = mood == option ? nil : option
                                    }
                                }
                            }
                        }
                    }
                }

                if [.weight, .steps, .sleep].contains(type) {
                    HStack(spacing: 9) {
                        TextField("Value", text: $valueText)
                            .keyboardType(.decimalPad)
                        TextField("Unit", text: $unit)
                            .frame(width: 90)
                    }
                    .textFieldStyle(.roundedBorder)
                }

                if type == .todo {
                    Toggle("Completed", isOn: $done)
                }

                TextField("Location (optional)", text: $location)
                    .textFieldStyle(.roundedBorder)

                TextField("Tags, comma separated", text: $tagsText)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }

    private var photoCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                PhotosPicker(selection: $photoItems, maxSelectionCount: 50, matching: .images) {
                    Label("Add photos", systemImage: "photo.on.rectangle.angled")
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PerlogSecondaryButtonStyle())

                if !photos.isEmpty {
                    PhotoStrip(data: photos, height: 90)
                }
            }
        }
    }

    private func loadEntry() {
        guard let entry else { return }
        type = entry.type
        title = entry.title
        bodyText = entry.bodyText
        date = entry.date
        mood = entry.mood
        tagsText = entry.tags.joined(separator: ", ")
        location = entry.location ?? ""
        valueText = entry.value.map { String($0) } ?? ""
        unit = entry.unit ?? ""
        done = entry.done
        photos = entry.photos
    }

    private func save() {
        let tags = tagsText
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUnit = unit.trimmingCharacters(in: .whitespacesAndNewlines)
        let number = Double(valueText.trimmingCharacters(in: .whitespacesAndNewlines))

        if let entry {
            entry.type = type
            entry.title = title
            entry.bodyText = bodyText
            entry.date = date
            entry.mood = mood
            entry.tags = tags
            entry.location = trimmedLocation.isEmpty ? nil : trimmedLocation
            entry.value = number
            entry.unit = trimmedUnit.isEmpty ? nil : trimmedUnit
            entry.done = done
            entry.photos = photos
        } else {
            context.insert(LogEntry(
                type: type,
                date: date,
                title: title,
                bodyText: bodyText,
                mood: mood,
                tags: tags,
                location: trimmedLocation.isEmpty ? nil : trimmedLocation,
                value: number,
                unit: trimmedUnit.isEmpty ? nil : trimmedUnit,
                done: done,
                photos: photos
            ))
        }

        try? context.save()
        dismiss()
    }
}

struct PhotoStrip: View {
    let data: [Data]
    var height: CGFloat = 90
    var cornerRadius: CGFloat = 15

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 9) {
                ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                    if let image = UIImage(data: item) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: height * 1.28, height: height)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    }
                }
            }
        }
    }
}

// MARK: - Filter / Undo

struct FilterView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: LogType?

    var body: some View {
        NavigationStack {
            List {
                Button { selection = nil; dismiss() } label: {
                    Label("Everything", systemImage: "square.grid.2x2.fill")
                }
                ForEach(LogType.allCases) { type in
                    Button { selection = type; dismiss() } label: {
                        Label(type.title, systemImage: type.icon)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(PerlogBackground())
            .navigationTitle("Filter")
        }
    }
}

struct UndoBanner: View {
    @EnvironmentObject private var theme: ThemeStore
    let onUndo: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "trash")
            Text("Record deleted")
                .font(.subheadline.weight(.semibold))
            Spacer()
            Button("Undo", action: onUndo)
                .font(.subheadline.bold())
                .foregroundStyle(theme.palette.accent)
            Button(action: onDismiss) {
                Image(systemName: "xmark")
            }
            .accessibilityLabel("Dismiss")
        }
        .foregroundStyle(theme.palette.text)
        .padding(.horizontal, 16)
        .frame(minHeight: 50)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(theme.palette.border, lineWidth: 0.8))
        .padding(.horizontal, 18)
        .shadow(radius: 15)
    }
}

// MARK: - Memories

struct MemoriesView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Query(sort: [SortDescriptor<LogEntry>(\.date, order: .reverse)]) private var entries: [LogEntry]

    private var memoryEntries: [LogEntry] {
        Array(entries.dropFirst(min(3, entries.count)).prefix(12))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PerlogBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        pageTitle("Memories", subtitle: "Rediscover moments from your personal log.")
                        if memoryEntries.isEmpty {
                            GlassCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .foregroundStyle(theme.palette.accent)
                                    Text("Your memories will appear here.").font(.headline)
                                    Text("As your personal log grows, Perlog will surface older moments for rediscovery.")
                                        .foregroundStyle(theme.palette.secondaryText)
                                }
                            }
                        } else {
                            ForEach(memoryEntries) { entry in
                                EntryCard(entry: entry, onEdit: {}, onDelete: {})
                            }
                        }
                    }
                    .padding(18)
                    .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
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
                PerlogBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        pageTitle("Summary", subtitle: "A view of the life you have logged.")

                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                            stat("\(entries.count)", "Records", "clock")
                            stat("\(entries.filter { $0.type == .journal }.count)", "Journal", "book.closed.fill")
                            stat("\(entries.filter { !$0.photos.isEmpty }.count)", "Photos", "photo.fill")
                            stat("\(entries.filter { $0.type == .place }.count)", "Places", "mappin.circle.fill")
                            stat("\(entries.filter { $0.mood != nil }.count)", "Mood", "face.smiling.fill")
                            stat("\(entries.filter { $0.type == .todo }.count)", "To-Dos", "checklist")
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your history")
                                    .font(.headline)
                                Text("Perlog keeps the full record locally. There is no Perlog-imposed limit on the number of records or photos.")
                                    .font(.subheadline)
                                    .foregroundStyle(theme.palette.secondaryText)
                            }
                        }
                    }
                    .padding(18)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func stat(_ value: String, _ title: String, _ icon: String) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 5) {
                Image(systemName: icon)
                    .foregroundStyle(theme.palette.accent)
                Text(value)
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                Text(title)
                    .font(.caption)
                    .foregroundStyle(theme.palette.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Me / Theme Studio

struct MeView: View {
    @EnvironmentObject private var theme: ThemeStore
    @State private var showingThemeStudio = false
    @State private var showingAbout = false

    var body: some View {
        NavigationStack {
            ZStack {
                PerlogBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        pageTitle("Perlog", subtitle: "Your life, logged.")

                        GlassCard {
                            VStack(alignment: .leading, spacing: 9) {
                                Text("Personal Log")
                                    .font(.system(size: 21, weight: .bold, design: .rounded))
                                Text("Everything worth remembering, in one continuous record.")
                                    .font(.subheadline)
                                    .foregroundStyle(theme.palette.secondaryText)
                            }
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Button { showingThemeStudio = true } label: {
                                    HStack {
                                        Label("Theme Studio", systemImage: "circle.lefthalf.filled")
                                        Spacer()
                                        Text(theme.name.rawValue)
                                            .foregroundStyle(theme.palette.secondaryText)
                                        Image(systemName: "chevron.right")
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Local-first storage", systemImage: "internaldrive.fill")
                                Label("No account required", systemImage: "person.crop.circle.badge.checkmark")
                                Label("No ads or tracking", systemImage: "eye.slash.fill")
                                Label("Fully free", systemImage: "gift.fill")
                            }
                            .font(.subheadline)
                            .foregroundStyle(theme.palette.text)
                        }
                    }
                    .padding(18)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingThemeStudio) {
                ThemeStudioView()
                    .environmentObject(theme)
            }
        }
    }
}

struct ThemeStudioView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            ZStack {
                PerlogBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Theme Studio")
                            .font(.system(size: 27, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.palette.text)

                        Text("Make Perlog feel like yours.")
                            .font(.subheadline)
                            .foregroundStyle(theme.palette.secondaryText)

                        themeCards

                        if theme.name == .iridescent {
                            iridescentControls
                        }

                        if theme.name == .custom {
                            customControls
                        }

                        previewCard
                    }
                    .padding(18)
                    .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Theme Studio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }

    private var themeCards: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            ForEach(PerlogThemeName.allCases) { option in
                Button {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.18)) { theme.select(option) }
                } label: {
                    VStack(alignment: .leading, spacing: 9) {
                        HStack {
                            Circle()
                                .fill(themePreviewColor(option))
                                .frame(width: 14, height: 14)
                            Text(option.rawValue)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.palette.text)
                            Spacer()
                            if theme.name == option { Image(systemName: "checkmark.circle.fill").foregroundStyle(theme.palette.accent) }
                        }
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(themePreviewFill(option))
                            .frame(height: 32)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).stroke(theme.palette.border, lineWidth: 0.8))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var iridescentControls: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Base hue")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(theme.hue.rounded()))°")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(theme.palette.secondaryText)
                }
                Slider(value: Binding(get: { theme.hue }, set: { theme.setHue($0) }), in: 0...360)
                    .tint(theme.palette.accent)
                HStack {
                    Text("0°")
                    Spacer()
                    Text("360°")
                }
                .font(.caption2)
                .foregroundStyle(theme.palette.secondaryText)
                Button("Restore default hue") { theme.resetIridescent() }
                    .font(.caption.bold())
            }
        }
    }

    private var customControls: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Custom palette")
                    .font(.headline)
                colorRow("Accent", theme.customAccent) { theme.setCustomAccent($0) }
                colorRow("Background", theme.customBackground) { theme.setCustomBackground($0) }
                colorRow("Glass tint", theme.customGlass) { theme.setCustomGlass($0) }
                colorRow("Primary text", theme.customText) { theme.setCustomText($0) }
                colorRow("Secondary text", theme.customSecondaryText) { theme.setCustomSecondaryText($0) }
                Text("Contrast preview: \(contrastLabel)")
                    .font(.caption)
                    .foregroundStyle(theme.palette.secondaryText)
                Button("Restore custom defaults") { theme.resetCustom() }
                    .font(.caption.bold())
            }
        }
    }

    private func colorRow(_ title: String, _ color: Color, onChange: @escaping (Color) -> Void) -> some View {
        HStack {
            Text(title)
            Spacer()
            ColorPicker("", selection: Binding(get: { color }, set: { onChange($0) }))
                .labelsHidden()
        }
    }

    private var contrastLabel: String {
        theme.palette.isDark ? "Dark surface / light text" : "Light surface / dark text"
    }

    private var previewCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 9) {
                Text("Live preview")
                    .font(.caption.bold())
                    .foregroundStyle(theme.palette.secondaryText)
                HStack(spacing: 10) {
                    Image(systemName: "book.closed.fill")
                        .foregroundStyle(theme.palette.accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Morning pages")
                            .font(.headline)
                        Text("Everything worth remembering.")
                            .font(.caption)
                            .foregroundStyle(theme.palette.secondaryText)
                    }
                    Spacer()
                }
            }
        }
    }

    private func themePreviewColor(_ option: PerlogThemeName) -> Color {
        switch option {
        case .black: return .blue
        case .grey: return .gray
        case .white: return .purple
        case .iridescent: return Color(hue: theme.hue / 360, saturation: 0.7, brightness: 1)
        case .custom: return theme.customAccent
        }
    }

    private func themePreviewFill(_ option: PerlogThemeName) -> Color {
        switch option {
        case .black: return Color.white.opacity(0.08)
        case .grey: return Color.gray.opacity(0.18)
        case .white: return Color.white.opacity(0.9)
        case .iridescent: return theme.palette.accent.opacity(0.22)
        case .custom: return theme.customGlass.opacity(0.45)
        }
    }
}

// MARK: - Shared helpers

struct PerlogSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .padding(.vertical, 12)
            .padding(.horizontal, 15)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(.white.opacity(0.12), lineWidth: 0.8))
            .opacity(isEnabled ? (configuration.isPressed ? 0.72 : 1) : 0.45)
    }
}

@ViewBuilder
func pageTitle(_ title: String, subtitle: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(title)
            .font(.system(size: 30, weight: .bold, design: .rounded))
        Text(subtitle)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}
