// SkillManagerView.swift
// Train Today — Skill Manager (View & Edit All Skills)
// Developed by Tara Knight | @Hopetheservicedoodle

import SwiftUI
import SwiftData

struct SkillManagerView: View {

    @Environment(AppState.self) private var appState
    @Query(sort: \Skill.sortOrder) private var skills: [Skill]
    @State private var selectedCategory: TrainingCategoryType = .obedience
    @State private var showingAddSkill = false
    @State private var skillToEdit: Skill? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ttBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Category tab bar
                    categoryTabBar
                        .padding(.horizontal, TTSpacing.md)
                        .padding(.vertical, TTSpacing.sm)
                        .background(Color.ttBackground)

                    Divider()

                    // Skills list
                    skillsList
                }
            }
            .navigationTitle("Skills")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSkill = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.ttPrimaryInteractive)
                    }
                }
            }
            .sheet(isPresented: $showingAddSkill) {
                EditSkillView(
                    initialCategory: selectedCategory,
                    existingSkill: nil
                )
            }
            .sheet(item: $skillToEdit) { skill in
                EditSkillView(
                    initialCategory: skill.category,
                    existingSkill: skill
                )
            }
        }
    }

    // MARK: - Category Tab Bar

    private var categoryTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TTSpacing.xs) {
                ForEach(TrainingCategoryType.allCases) { category in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                            Text(category.shortName)
                                .font(TTFont.bodySmall)
                        }
                        .padding(.horizontal, TTSpacing.sm)
                        .padding(.vertical, TTSpacing.xs)
                        .background(selectedCategory == category
                            ? TTColor.forCategory(category)
                            : Color.ttSecondaryLight)
                        .foregroundColor(.ttText)
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }

    // MARK: - Skills List

    private var skillsList: some View {
        let filtered = skills.filter { $0.category == selectedCategory }

        return Group {
            if filtered.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(filtered) { skill in
                        SkillRowView(skill: skill)
                            .contentShape(Rectangle())
                            .onTapGesture { skillToEdit = skill }
                            .listRowBackground(Color.ttBackground)
                            .listRowSeparatorTint(Color.ttSecondaryLight)
                    }
                }
                .listStyle(.plain)
                .background(Color.ttBackground)
                .scrollContentBackground(.hidden)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: TTSpacing.md) {
            Image(systemName: selectedCategory.icon)
                .font(.system(size: 48))
                .foregroundColor(.ttText)
            Text("No \(selectedCategory.shortName) skills yet")
                .font(TTFont.headline)
                .foregroundColor(.ttText)
            Text("Tap + to add your first skill in this category.")
                .font(TTFont.bodySmall)
                .foregroundColor(.ttTextSecondary)
                .multilineTextAlignment(.center)
            Button("Add Skill") {
                showingAddSkill = true
            }
            .buttonStyle(TTPrimaryButtonStyle())
            .frame(maxWidth: 200)
        }
        .padding(TTSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Skill Row

struct SkillRowView: View {

    let skill: Skill

    var body: some View {
        HStack(spacing: TTSpacing.sm) {
            // Status color dot
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
                .padding(.leading, 4)

            VStack(alignment: .leading, spacing: TTSpacing.xxs) {
                HStack {
                    Text(skill.name)
                        .font(TTFont.body)
                        .foregroundColor(.ttText)
                    Spacer()
                    if skill.importance == .critical {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.ttText)
                    }
                    if skill.isCriticalOverdue {
                        Text("OVERDUE")
                            .font(TTFont.tag)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.ttWarning.opacity(0.15))
                            .foregroundColor(.ttText)
                            .clipShape(Capsule())
                    }
                }
                HStack(spacing: TTSpacing.xs) {
                    Text(skill.status.rawValue)
                        .font(TTFont.caption)
                        .foregroundColor(.ttTextSecondary)
                    Text("·")
                        .foregroundColor(.ttSecondaryLight)
                    Text(skill.recencyLabel)
                        .font(TTFont.caption)
                        .foregroundColor(.ttTextSecondary)
                    Text("·")
                        .foregroundColor(.ttSecondaryLight)
                    Image(systemName: skill.requiredEnvironment.icon)
                        .font(TTFont.caption)
                        .foregroundColor(.ttTextSecondary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.ttSecondaryLight)
        }
        .padding(.vertical, TTSpacing.xs)
    }

    private var statusColor: Color {
        switch skill.status {
        case .beginner:    return .ttWarning
        case .developing:  return TTColor.primaryInteractive
        case .maintaining: return .ttSuccess
        }
    }
}

// MARK: - Edit / Add Skill View

struct EditSkillView: View {

    let initialCategory: TrainingCategoryType
    let existingSkill: Skill?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Skill.sortOrder) private var allSkills: [Skill]

    @State private var name: String = ""
    @State private var category: TrainingCategoryType = .obedience
    @State private var status: SkillStatus = .developing
    @State private var importance: SkillImportance = .standard
    @State private var environment: SkillEnvironment = .home
    @State private var howTo: String = ""
    @State private var successMetric: String = ""
    @State private var notes: String = ""

    var isEditing: Bool { existingSkill != nil }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ttBackground.ignoresSafeArea()

                Form {
                    Section("Skill Details") {
                        TextField("Skill name", text: $name)
                        Picker("Category", selection: $category) {
                            ForEach(TrainingCategoryType.allCases) { c in
                                Text(c.shortName).tag(c)
                            }
                        }
                    }
                    .listRowBackground(Color.ttSurface)

                    Section("Training Level") {
                        Picker("Status", selection: $status) {
                            ForEach(SkillStatus.allCases) { s in
                                Text(s.rawValue).tag(s)
                            }
                        }
                        Picker("Importance", selection: $importance) {
                            ForEach(SkillImportance.allCases) { i in
                                Text(i.rawValue).tag(i)
                            }
                        }
                        Picker("Location required", selection: $environment) {
                            ForEach(SkillEnvironment.allCases) { e in
                                Text(e.rawValue).tag(e)
                            }
                        }
                    }
                    .listRowBackground(Color.ttSurface)

                    Section("Training Guidance") {
                        TextField("How to practice this skill", text: $howTo, axis: .vertical)
                            .lineLimit(3...6)
                        TextField("You're done when…", text: $successMetric, axis: .vertical)
                            .lineLimit(2...4)
                    }
                    .listRowBackground(Color.ttSurface)

                    Section("Notes") {
                        TextField("Your private notes on this skill", text: $notes, axis: .vertical)
                            .lineLimit(2...6)
                    }
                    .listRowBackground(Color.ttSurface)

                    if isEditing {
                        Section {
                            Button("Delete Skill", role: .destructive) {
                                if let skill = existingSkill {
                                    modelContext.delete(skill)
                                    try? modelContext.save()
                                    dismiss()
                                }
                            }
                        }
                        .listRowBackground(Color.ttSurface)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.ttBackground)
            }
            .navigationTitle(isEditing ? "Edit Skill" : "Add Skill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.ttTextSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveSkill() }
                        .foregroundColor(.ttPrimaryInteractive)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { populateFields() }
        }
    }

    private func populateFields() {
        if let skill = existingSkill {
            name          = skill.name
            category      = skill.category
            status        = skill.status
            importance    = skill.importance
            environment   = skill.requiredEnvironment
            howTo         = skill.howToReminder
            successMetric = skill.successMetric
            notes         = skill.notes
        } else {
            category = initialCategory
        }
    }

    private func saveSkill() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        if let skill = existingSkill {
            skill.name                 = trimmedName
            skill.category             = category
            skill.status               = status
            skill.importance           = importance
            skill.requiredEnvironment  = environment
            skill.howToReminder        = howTo
            skill.successMetric        = successMetric
            skill.notes                = notes
        } else {
            let maxOrder = allSkills.filter { $0.category == category }.map { $0.sortOrder }.max() ?? 0
            let newSkill = Skill(
                name: trimmedName,
                category: category,
                status: status,
                importance: importance,
                requiredEnvironment: environment,
                howToReminder: howTo,
                successMetric: successMetric,
                isCustom: true,
                sortOrder: maxOrder + 1,
                notes: notes
            )
            modelContext.insert(newSkill)
        }

        try? modelContext.save()
        dismiss()
    }
}
