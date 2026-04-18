// QuickLogView.swift
// Train Today — Retroactive Session Logger
// Allows logging one or more skills from a past session.
// Developed by Tara Knight | @Hopetheservicedoodle

import SwiftUI
import SwiftData

struct QuickLogView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var allSkills: [Skill]
    @Query(sort: \TrainingSession.date, order: .reverse) private var sessions: [TrainingSession]

    // MARK: - State

    @State private var selectedSkills: [Skill]     = []
    @State private var searchText: String           = ""
    @State private var sessionDate: Date            = .now
    @State private var durationMinutes: Int         = 15
    @State private var rating: SessionRating        = .okay
    @State private var notes: String                = ""
    @State private var showSavedConfirmation: Bool  = false

    // MARK: - Computed: Filtered Library

    private var filteredSkills: [Skill] {
        if searchText.isEmpty { return allSkills }
        return allSkills.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    /// Up to 5 most recently practiced skills (unique, in order)
    private var recentSkills: [Skill] {
        var seen = Set<String>()
        var result: [Skill] = []
        for session in sessions {
            guard result.count < 5 else { break }
            if !seen.contains(session.skillName) {
                seen.insert(session.skillName)
                if let skill = allSkills.first(where: { $0.name == session.skillName }) {
                    result.append(skill)
                }
            }
        }
        return result
    }

    /// Skills grouped by category for the full library section
    private var skillsByCategory: [(TrainingCategoryType, [Skill])] {
        let grouped = Dictionary(grouping: filteredSkills) { $0.category }
        return TrainingCategoryType.allCases.compactMap { cat in
            guard let skills = grouped[cat], !skills.isEmpty else { return nil }
            return (cat, skills.sorted { $0.name < $1.name })
        }
    }

    private var canSave: Bool {
        !selectedSkills.isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                        .padding(.horizontal, TTSpacing.md)
                        .padding(.top, TTSpacing.sm)
                        .padding(.bottom, TTSpacing.xs)

                    // Selected skill chips
                    if !selectedSkills.isEmpty {
                        selectedChips
                            .padding(.horizontal, TTSpacing.md)
                            .padding(.bottom, TTSpacing.sm)
                    }

                    Divider()

                    // Scrollable skill picker + session details
                    ScrollView {
                        VStack(alignment: .leading, spacing: TTSpacing.lg) {

                            // Zone 1: Recently practiced
                            if !recentSkills.isEmpty && searchText.isEmpty {
                                recentSection
                            }

                            // Zone 2: Full library grouped by category
                            fullLibrarySection

                            // Session details
                            sessionDetailsSection

                            // Save button
                            Button(action: saveLog) {
                                Text(selectedSkills.isEmpty
                                     ? "Select at least one skill"
                                     : "Save \(selectedSkills.count) Skill\(selectedSkills.count == 1 ? "" : "s")")
                            }
                            .buttonStyle(TTPrimaryButtonStyle())
                            .disabled(!canSave)
                            .padding(.bottom, TTSpacing.xxl)
                        }
                        .padding(.horizontal, TTSpacing.md)
                        .padding(.top, TTSpacing.md)
                    }
                }
            }
            .navigationTitle("Log a Past Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.accentInteractive)
                }
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: TTSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textSecondary)
            TextField("Search skills…", text: $searchText)
                .font(TTFont.body)
                .autocorrectionDisabled()
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(TTSpacing.sm)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: TTRadius.md))
    }

    // MARK: - Selected Chips

    private var selectedChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TTSpacing.xs) {
                ForEach(selectedSkills) { skill in
                    HStack(spacing: 4) {
                        Text(skill.name)
                            .font(TTFont.caption)
                            .foregroundColor(.textPrimary)
                        Button {
                            deselect(skill)
                        } label: {
                            Image(systemName: "xmark")
                                .font(.caption2)
                                .foregroundColor(.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, TTSpacing.sm)
                    .padding(.vertical, TTSpacing.xxs + 2)
                    .background(TTColor.forCategory(skill.category))
                    .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Recently Practiced

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: TTSpacing.sm) {
            Text("Recently Practiced")
                .font(TTFont.headline)
                .foregroundColor(.textPrimary)
            VStack(spacing: TTSpacing.xs) {
                ForEach(recentSkills) { skill in
                    skillRow(skill)
                }
            }
        }
    }

    // MARK: - Full Library

    private var fullLibrarySection: some View {
        VStack(alignment: .leading, spacing: TTSpacing.lg) {
            Text(searchText.isEmpty ? "All Skills" : "Results")
                .font(TTFont.headline)
                .foregroundColor(.textPrimary)

            if filteredSkills.isEmpty {
                Text("No skills match \"\(searchText)\"")
                    .font(TTFont.bodySmall)
                    .foregroundColor(.textSecondary)
                    .padding(.vertical, TTSpacing.sm)
            } else {
                ForEach(skillsByCategory, id: \.0) { category, skills in
                    VStack(alignment: .leading, spacing: TTSpacing.xs) {
                        // Category header
                        HStack(spacing: TTSpacing.xs) {
                            Image(systemName: category.icon)
                                .font(.caption)
                                .foregroundColor(.textPrimary)
                            Text(category.shortName)
                                .font(TTFont.bodySmall)
                                .foregroundColor(.textSecondary)
                        }
                        ForEach(skills) { skill in
                            skillRow(skill)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Skill Row

    private func skillRow(_ skill: Skill) -> some View {
        let isSelected = selectedSkills.contains { $0.id == skill.id }
        return Button {
            toggleSelection(skill)
        } label: {
            HStack(spacing: TTSpacing.sm) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Color.accentInteractive : .fillSecondary)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(skill.name)
                        .font(TTFont.body)
                        .foregroundColor(.textPrimary)
                    Text(skill.status.rawValue)
                        .font(TTFont.caption)
                        .foregroundColor(.textSecondary)
                }
                Spacer()
            }
            .padding(TTSpacing.sm)
            .background(isSelected ? TTColor.forCategory(skill.category).opacity(0.08) : Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: TTRadius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: TTRadius.sm)
                    .strokeBorder(
                        isSelected ? TTColor.forCategory(skill.category).opacity(0.4) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Session Details

    private var sessionDetailsSection: some View {
        VStack(alignment: .leading, spacing: TTSpacing.md) {
            Text("Session Details")
                .font(TTFont.headline)
                .foregroundColor(.textPrimary)

            VStack(spacing: TTSpacing.md) {

                // Date
                HStack {
                    Text("Date")
                        .font(TTFont.bodySmall)
                        .foregroundColor(.textSecondary)
                    Spacer()
                    DatePicker(
                        "",
                        selection: $sessionDate,
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    .tint(.accentInteractive)
                }
                .padding(TTSpacing.sm)
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: TTRadius.sm))

                // Duration
                VStack(alignment: .leading, spacing: TTSpacing.xs) {
                    Text("Total session length")
                        .font(TTFont.bodySmall)
                        .foregroundColor(.textSecondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: TTSpacing.xs) {
                            ForEach([5, 10, 15, 20, 30, 45, 60], id: \.self) { mins in
                                Button("\(mins) min") {
                                    durationMinutes = mins
                                }
                                .buttonStyle(.borderless)
                                .font(TTFont.caption)
                                .padding(.horizontal, TTSpacing.sm)
                                .padding(.vertical, TTSpacing.xxs + 2)
                                .background(durationMinutes == mins ? Color.accentInteractive : Color.fillSecondary)
                                .foregroundColor(durationMinutes == mins ? .white : .textPrimary)
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
                .padding(TTSpacing.sm)
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: TTRadius.sm))

                // Rating
                VStack(alignment: .leading, spacing: TTSpacing.xs) {
                    Text("How did it go?")
                        .font(TTFont.bodySmall)
                        .foregroundColor(.textSecondary)
                    HStack(spacing: TTSpacing.sm) {
                        ForEach(SessionRating.allCases) { r in
                            Button {
                                rating = r
                            } label: {
                                VStack(spacing: 2) {
                                    Text(r.emoji)
                                        .font(.title3)
                                    Text(r.rawValue)
                                        .font(TTFont.caption)
                                        .foregroundColor(rating == r ? .accentInteractive : .textSecondary)
                                }
                                .padding(.horizontal, TTSpacing.sm)
                                .padding(.vertical, TTSpacing.xs)
                                .background(rating == r ? Color.accentLight.opacity(0.12) : Color.surface)
                                .clipShape(RoundedRectangle(cornerRadius: TTRadius.sm))
                                .overlay(
                                    RoundedRectangle(cornerRadius: TTRadius.sm)
                                        .strokeBorder(
                                            rating == r ? Color.accentInteractive : Color.fillSecondary,
                                            lineWidth: 1.5
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(TTSpacing.sm)
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: TTRadius.sm))

                // Notes
                VStack(alignment: .leading, spacing: TTSpacing.xs) {
                    Text("Notes (optional)")
                        .font(TTFont.bodySmall)
                        .foregroundColor(.textSecondary)
                    TextEditor(text: $notes)
                        .font(TTFont.body)
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                }
                .padding(TTSpacing.sm)
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: TTRadius.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: TTRadius.sm)
                        .strokeBorder(Color.fillSecondary, lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Selection Helpers

    private func toggleSelection(_ skill: Skill) {
        if let idx = selectedSkills.firstIndex(where: { $0.id == skill.id }) {
            selectedSkills.remove(at: idx)
        } else {
            selectedSkills.append(skill)
        }
    }

    private func deselect(_ skill: Skill) {
        selectedSkills.removeAll { $0.id == skill.id }
    }

    // MARK: - Save

    private func saveLog() {
        guard !selectedSkills.isEmpty else { return }

        // Duration is shared across all skills in this session
        let perSkillDuration = max(1, durationMinutes / selectedSkills.count)

        for skill in selectedSkills {
            let session = TrainingSession(
                date: sessionDate,
                durationMinutes: perSkillDuration,
                skillName: skill.name,
                skillCategory: skill.category,
                rating: rating,
                notes: notes,
                isQuickWin: false,
                isAdHoc: true
            )
            modelContext.insert(session)

            // Update lastPracticed on the skill
            skill.lastPracticed = sessionDate
        }

        try? modelContext.save()
        dismiss()
    }
}
