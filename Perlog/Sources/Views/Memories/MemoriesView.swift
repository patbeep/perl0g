import SwiftUI
import SwiftData

struct MemoriesView: View {
    @EnvironmentObject private var theme: ThemeStore

    @Query(sort: [SortDescriptor<LogEntry>(\.date, order: .reverse)])
    private var allEntries: [LogEntry]

    @State private var selectedEntry: LogEntry?

    private var onThisDay: [LogEntry] {
        let today = Date.now
        return allEntries.filter { entry in
            !Calendar.current.isDate(entry.date, inSameDayAs: today) && entry.date.isSameMonthAndDay(as: today)
        }
    }

    private var milestones: [LogEntry] {
        allEntries.filter { $0.isMilestone }
    }

    private var randomRediscovery: [LogEntry] {
        guard allEntries.count > 3 else { return [] }
        return Array(allEntries.shuffled().prefix(4))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                if allEntries.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            memorySection(title: "On this day", subtitle: "From years past", entries: onThisDay)
                            memorySection(title: "Milestones", subtitle: "The moments you marked as important", entries: milestones)
                            memorySection(title: "Rediscover", subtitle: "A few older moments worth revisiting", entries: randomRediscovery)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Memories")
            .sheet(item: $selectedEntry) { entry in
                EntryDetailView(entry: entry)
            }
        }
    }

    @ViewBuilder
    private func memorySection(title: String, subtitle: String, entries: [LogEntry]) -> some View {
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.title3.weight(.bold)).foregroundStyle(theme.primaryText)
                    Text(subtitle).font(.caption).foregroundStyle(theme.secondaryText)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(entries.prefix(10)) { entry in
                            memoryCard(entry)
                                .onTapGesture { selectedEntry = entry }
                        }
                    }
                }
            }
        }
    }

    private func memoryCard(_ entry: LogEntry) -> some View {
        GlassCard(padding: 12, cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TypeBadge(type: entry.type, size: 28)
                    Spacer()
                    Text(entry.date.yearsAgoDescription)
                        .font(.caption2)
                        .foregroundStyle(theme.secondaryText)
                }
                Text(entry.title.isEmpty ? entry.type.title : entry.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.primaryText)
                    .lineLimit(1)
                Text(entry.content)
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
                    .lineLimit(3)
            }
            .frame(width: 190, alignment: .leading)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 44))
                .foregroundStyle(theme.accent)
            Text("No memories yet")
                .font(.title3.weight(.semibold))
                .foregroundStyle(theme.primaryText)
            Text("Keep logging — memories build up over time.")
                .font(.subheadline)
                .foregroundStyle(theme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
