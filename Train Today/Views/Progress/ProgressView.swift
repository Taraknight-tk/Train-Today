// ProgressView.swift
// Train Today — Training History & Progress Overview
// Developed by Tara Knight | @Hopetheservicedoodle

import SwiftUI
import SwiftData

struct ProgressView: View {

    @Query(sort: \TrainingSession.date, order: .reverse) private var sessions: [TrainingSession]
    @Query private var skills: [Skill]
    @State private var selectedFilter: ProgressFilter = .all

    enum ProgressFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case obedience    = "Obedience"
        case publicAccess = "Public Access"
        case task         = "Task"
        case relationship = "Relationship"

        var id: String { rawValue }
    }

    private var filteredSessions: [TrainingSession] {
        switch selectedFilter {
        case .all: return Array(sessions)
        case .obedience:    return sessions.filter { $0.skillCategory == .obedience }
        case .publicAccess: return sessions.filter { $0.skillCategory == .publicAccess }
        case .task:         return sessions.filter { $0.skillCategory == .task }
        case .relationship: return sessions.filter { $0.skillCategory == .relationship }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: TTSpacing.lg) {

                        // Stats row
                        statsRow

                        // Category summary cards
                        categoryCards

                        // Filter + session log
                        sessionLogSection

                        Spacer(minLength: TTSpacing.xxl)
                    }
                    .padding(.horizontal, TTSpacing.md)
                    .padding(.top, TTSpacing.md)
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: TTSpacing.sm) {
            statTile(
                value: "\(SchedulingEngine.currentStreak(sessions: Array(sessions)))",
                label: "Day Streak",
                icon: "flame.fill",
                color: Color.accentInteractive
            )
            statTile(
                value: "\(sessions.count)",
                label: "Total Sessions",
                icon: "checkmark.circle.fill",
                color: Color.accentInteractive
            )
            statTile(
                value: totalMinutesLabel,
                label: "Total Minutes",
                icon: "clock.fill",
                color: .fillBorder
            )
        }
    }

    private func statTile(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: TTSpacing.xxs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(TTFont.title)
                .foregroundColor(.textPrimary)
            Text(label)
                .font(TTFont.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .ttCard(padding: TTSpacing.sm)
    }

    private var totalMinutesLabel: String {
        let total = sessions.reduce(0) { $0 + $1.durationMinutes }
        return total >= 60 ? "\(total / 60)h \(total % 60)m" : "\(total)m"
    }

    // MARK: - Category Summary Cards

    private var categoryCards: some View {
        VStack(alignment: .leading, spacing: TTSpacing.sm) {
            Text("By Category")
                .font(TTFont.headline)
                .foregroundColor(.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: TTSpacing.sm) {
                ForEach(TrainingCategoryType.allCases) { category in
                    categorySummaryCard(category: category)
                }
            }
        }
    }

    private func categorySummaryCard(category: TrainingCategoryType) -> some View {
        let catSessions = sessions.filter { $0.skillCategory == category }
        let catSkills   = skills.filter { $0.category == category && $0.isActive }

        return VStack(alignment: .leading, spacing: TTSpacing.xs) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(.textPrimary)
                Spacer()
            }
            Text(category.shortName)
                .font(TTFont.bodySmall)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            Text("\(catSessions.count) sessions")
                .font(TTFont.caption)
                .foregroundColor(.textSecondary)
            Text("\(catSkills.count) skills")
                .font(TTFont.caption)
                .foregroundColor(.textSecondary)

            // Simple recency bar
            ProgressBar(
                value: recencyScore(for: category),
                color: TTColor.forCategory(category)
            )
        }
        .padding(TTSpacing.sm)
        .background(TTColor.forCategory(category).opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: TTRadius.md))
    }

    /// Returns a 0.0–1.0 score reflecting how recently this category was practiced
    private func recencyScore(for category: TrainingCategoryType) -> Double {
        guard let last = sessions.filter({ $0.skillCategory == category }).first else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: last.date, to: Date()).day ?? 999
        return max(0, min(1, 1.0 - (Double(days) / 14.0)))
    }

    // MARK: - Session Log Section

    private var sessionLogSection: some View {
        VStack(alignment: .leading, spacing: TTSpacing.sm) {
            Text("Session History")
                .font(TTFont.headline)
                .foregroundColor(.textPrimary)

            // Filter pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: TTSpacing.xs) {
                    ForEach(ProgressFilter.allCases) { filter in
                        Button(filter.rawValue) {
                            selectedFilter = filter
                        }
                        .font(TTFont.bodySmall)
                        .padding(.horizontal, TTSpacing.sm)
                        .padding(.vertical, TTSpacing.xxs + 2)
                        .background(selectedFilter == filter ? Color.accentInteractive : Color.fillSecondary)
                        .foregroundColor(selectedFilter == filter ? .white : .textPrimary)
                        .clipShape(Capsule())
                    }
                }
            }

            if filteredSessions.isEmpty {
                emptyHistoryState
            } else {
                LazyVStack(spacing: TTSpacing.xs) {
                    ForEach(filteredSessions) { session in
                        SessionHistoryRow(session: session)
                    }
                }
            }
        }
    }

    private var emptyHistoryState: some View {
        HStack {
            Spacer()
            VStack(spacing: TTSpacing.xs) {
                Text("🐾")
                    .font(.largeTitle)
                Text("No sessions yet")
                    .font(TTFont.bodySmall)
                    .foregroundColor(.textSecondary)
                Text("Log your first session to see history here.")
                    .font(TTFont.caption)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(TTSpacing.xl)
            Spacer()
        }
    }
}

// MARK: - Session History Row

struct SessionHistoryRow: View {

    let session: TrainingSession

    var body: some View {
        HStack(spacing: TTSpacing.sm) {
            // Category color dot
            Circle()
                .fill(TTColor.forCategory(session.skillCategory))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(session.skillName)
                        .font(TTFont.bodySmall)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Text(session.rating.emoji)
                }
                HStack(spacing: 4) {
                    Text(session.dateDisplay)
                        .font(TTFont.caption)
                        .foregroundColor(.textSecondary)
                    if session.durationMinutes > 0 {
                        Text("·")
                            .foregroundColor(.fillSecondary)
                        Text("\(session.durationMinutes) min")
                            .font(TTFont.caption)
                            .foregroundColor(.textSecondary)
                    }
                    if session.isQuickWin {
                        Text("·")
                            .foregroundColor(.fillSecondary)
                        Text("Quick Win")
                            .font(TTFont.caption)
                            .foregroundColor(.accentInteractive)
                    }
                }
            }
        }
        .padding(.horizontal, TTSpacing.sm)
        .padding(.vertical, TTSpacing.xs)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: TTRadius.sm))
    }
}

// MARK: - Progress Bar Helper

struct ProgressBar: View {
    let value: Double   // 0.0 to 1.0
    let color: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(color.opacity(0.15))
                    .frame(height: 5)
                Capsule()
                    .fill(color)
                    .frame(width: geo.size.width * max(0, min(1, value)), height: 5)
            }
        }
        .frame(height: 5)
    }
}
