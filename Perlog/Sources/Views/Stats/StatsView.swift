import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @EnvironmentObject private var theme: ThemeStore

    @Query private var allEntries: [LogEntry]
    @Query private var allTags: [Tag]
    @Query private var allPeople: [Person]

    private var typeCounts: [(type: EntryType, count: Int)] {
        EntryType.allCases
            .map { type in (type, allEntries.filter { $0.type == type }.count) }
            .filter { $0.count > 0 }
            .sorted { $0.count > $1.count }
    }

    private var currentStreak: Int {
        let calendar = Calendar.current
        let days = Set(allEntries.map { calendar.startOfDay(for: $0.date) })
        var streak = 0
        var cursor = calendar.startOfDay(for: .now)
        while days.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }

    private var totalPhotos: Int {
        allEntries.reduce(0) { $0 + $1.photoData.count }
    }

    private var completedTasks: Int {
        allEntries.filter { $0.type == .task && $0.isCompleted }.count
    }

    private var openTasks: Int {
        allEntries.filter { $0.type == .task && !$0.isCompleted }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        statGrid

                        if !typeCounts.isEmpty {
                            GlassCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Records by type")
                                        .font(.headline)
                                        .foregroundStyle(theme.primaryText)
                                    Chart(typeCounts, id: \.type) { item in
                                        BarMark(
                                            x: .value("Count", item.count),
                                            y: .value("Type", item.type.title)
                                        )
                                        .foregroundStyle(theme.tint(for: item.type))
                                        .cornerRadius(4)
                                    }
                                    .frame(height: CGFloat(typeCounts.count * 34 + 20))
                                    .chartXAxis { AxisMarks(position: .bottom) }
                                }
                            }
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tasks")
                                    .font(.headline)
                                    .foregroundStyle(theme.primaryText)
                                HStack {
                                    statPill(label: "Completed", value: "\(completedTasks)")
                                    statPill(label: "Open", value: "\(openTasks)")
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Stats")
        }
    }

    private var statGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard(icon: "flame.fill", value: "\(currentStreak)", label: currentStreak == 1 ? "day streak" : "day streak")
            statCard(icon: "note.text", value: "\(allEntries.count)", label: "total records")
            statCard(icon: "photo.on.rectangle", value: "\(totalPhotos)", label: "photos")
            statCard(icon: "tag.fill", value: "\(allTags.count)", label: "tags")
            statCard(icon: "person.2.fill", value: "\(allPeople.count)", label: "people")
        }
    }

    private func statCard(icon: String, value: String, label: String) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(theme.accent)
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(theme.primaryText)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func statPill(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.title3.weight(.bold)).foregroundStyle(theme.primaryText)
            Text(label).font(.caption).foregroundStyle(theme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
