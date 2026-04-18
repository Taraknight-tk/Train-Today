// OnboardingView.swift
// Train Today — First-Run Onboarding Flow
// Developed by Tara Knight | @Hopetheservicedoodle
//
// Steps:
//  1. Welcome
//  2. Dog Profile
//  3. Training Categories
//  4. Task Selection (skipped if Task Training not active)
//  5. Skill Inventory
//  6. Schedule Preferences
//  7. Handler Notes
//  8. Disclaimer Acknowledgment

import SwiftUI
import SwiftData

struct OnboardingView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var notificationManager = NotificationManager()

    @State private var currentStep: Int = 0
    private let totalSteps = 8

    // Dog profile fields
    @State private var dogName: String       = ""
    @State private var dogBreed: String      = ""
    @State private var dogAgeYears: Int      = 1
    @State private var dogAgeMonths: Int     = 0
    @State private var isProgramDog: Bool    = false
    @State private var handlerNotes: String  = ""

    // Category selection (all active by default)
    @State private var activeCategories: Set<TrainingCategoryType> = Set(TrainingCategoryType.allCases)

    // Skill statuses set during onboarding
    @State private var skillStatuses: [String: SkillStatus] = [:]

    // Tasks selected during onboarding (defaults to all tasks)
    @State private var selectedTaskNames: Set<String> =
        Set(DefaultSkillLibrary.taskSkills.map { $0.name })

    // Disclaimer
    @State private var disclaimerAcknowledged: Bool = false

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                progressBar
                    .padding(.horizontal, TTSpacing.md)
                    .padding(.top, TTSpacing.md)

                // Step content
                TabView(selection: $currentStep) {
                    welcomeStep.tag(0)
                    dogProfileStep.tag(1)
                    categoriesStep.tag(2)
                    taskSelectionStep.tag(3)       // NEW — skipped if Task Training not active
                    skillInventoryStep.tag(4)
                    scheduleStep.tag(5)
                    handlerNotesStep.tag(6)
                    disclaimerStep.tag(7)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.fillSecondary)
                    .frame(height: 4)
                Capsule()
                    .fill(Color.accentInteractive)
                    .frame(width: geo.size.width * (CGFloat(currentStep + 1) / CGFloat(totalSteps)), height: 4)
                    .animation(.easeInOut, value: currentStep)
            }
        }
        .frame(height: 4)
    }

    // MARK: - Navigation Helpers

    private func nextStep() {
        var next = currentStep + 1
        // Skip step 3 (Task Selection) if Task Training category is not active
        if next == 3 && !activeCategories.contains(.task) { next = 4 }
        withAnimation { currentStep = min(next, totalSteps - 1) }
    }

    private func prevStep() {
        var prev = currentStep - 1
        // Skip step 3 going backwards too
        if prev == 3 && !activeCategories.contains(.task) { prev = 2 }
        withAnimation { currentStep = max(prev, 0) }
    }

    @ViewBuilder
    private func navButtons(
        nextLabel: String = "Continue",
        nextEnabled: Bool = true,
        nextAction: (() -> Void)? = nil
    ) -> some View {
        HStack(spacing: TTSpacing.sm) {
            if currentStep > 0 {
                Button("Back", action: prevStep)
                    .buttonStyle(TTSecondaryButtonStyle())
                    .frame(maxWidth: 100)
            }
            Button(nextLabel) {
                nextAction?()
                nextStep()
            }
            .buttonStyle(TTPrimaryButtonStyle())
            .disabled(!nextEnabled)
        }
    }

    // MARK: - Step 0: Welcome

    private var welcomeStep: some View {
        VStack(spacing: TTSpacing.lg) {
            Spacer()
            Text("🐾")
                .font(.system(size: 80))
            Text("Welcome to\nTrain Today")
                .font(TTFont.display)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            Text("Your personal service dog training planner. Tell us a little about your team and we'll get you set up in about 5 minutes.")
                .font(TTFont.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, TTSpacing.xl)
            Spacer()
            navButtons()
                .padding(.horizontal, TTSpacing.md)
                .padding(.bottom, TTSpacing.xl)
        }
    }

    // MARK: - Step 1: Dog Profile

    private var dogProfileStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TTSpacing.lg) {
                stepHeader(
                    emoji: "🐶",
                    title: "Tell us about your dog",
                    subtitle: "This helps personalize your experience."
                )

                VStack(spacing: TTSpacing.md) {
                    inputField(title: "Dog's name", text: $dogName, placeholder: "e.g., Hope")
                    inputField(title: "Breed", text: $dogBreed, placeholder: "e.g., Standard Poodle")

                    VStack(alignment: .leading, spacing: TTSpacing.xs) {
                        Text("Age").font(TTFont.bodySmall).foregroundColor(.textSecondary)
                        HStack {
                            Stepper("\(dogAgeYears) year\(dogAgeYears == 1 ? "" : "s")",
                                    value: $dogAgeYears, in: 0...20)
                            Spacer()
                            Stepper("\(dogAgeMonths) mo",
                                    value: $dogAgeMonths, in: 0...11)
                        }
                    }
                    .ttCard()

                    Toggle("Program dog (vs. owner-trained)", isOn: $isProgramDog)
                        .tint(.accentInteractive)
                        .ttCard()
                }

                navButtons(nextEnabled: !dogName.isEmpty)
                    .padding(.bottom, TTSpacing.xl)
            }
            .padding(.horizontal, TTSpacing.md)
            .padding(.top, TTSpacing.md)
        }
    }

    // MARK: - Step 2: Categories

    private var categoriesStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TTSpacing.lg) {
                stepHeader(
                    emoji: "📋",
                    title: "Training categories",
                    subtitle: "Which categories are active for your team? You can change this later."
                )

                ForEach(TrainingCategoryType.allCases) { category in
                    categoryToggleCard(category)
                }

                navButtons()
                    .padding(.bottom, TTSpacing.xl)
            }
            .padding(.horizontal, TTSpacing.md)
            .padding(.top, TTSpacing.md)
        }
    }

    private func categoryToggleCard(_ category: TrainingCategoryType) -> some View {
        let isActive = activeCategories.contains(category)
        return Button {
            if isActive {
                activeCategories.remove(category)
            } else {
                activeCategories.insert(category)
            }
        } label: {
            HStack(spacing: TTSpacing.md) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(isActive ? Color.accentInteractive : .textSecondary)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.rawValue)
                        .font(TTFont.body)
                        .foregroundColor(.textPrimary)
                    Text(category.description)
                        .font(TTFont.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isActive ? Color.accentInteractive : .fillSecondary)
            }
            .ttCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 3: Task Selection

    private var taskSelectionStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TTSpacing.lg) {
                stepHeader(
                    emoji: "⭐️",
                    title: "Which tasks does your dog do?",
                    subtitle: "Select the tasks relevant to your disability. You can add or remove tasks any time in the Skills tab."
                )

                // Select All / Deselect All convenience
                HStack {
                    Button("Select All") {
                        selectedTaskNames = Set(DefaultSkillLibrary.taskSkills.map { $0.name })
                    }
                    .buttonStyle(.borderless)
                    .font(TTFont.bodySmall)
                    .foregroundColor(.accentInteractive)

                    Spacer()

                    Button("Deselect All") {
                        selectedTaskNames = []
                    }
                    .buttonStyle(.borderless)
                    .font(TTFont.bodySmall)
                    .foregroundColor(.textSecondary)
                }

                // Tasks grouped by disability type
                ForEach(TaskDisabilityGroup.allCases) { group in
                    taskGroupSection(group)
                }

                navButtons()
                    .padding(.bottom, TTSpacing.xl)
            }
            .padding(.horizontal, TTSpacing.md)
            .padding(.top, TTSpacing.md)
        }
    }

    @ViewBuilder
    private func taskGroupSection(_ group: TaskDisabilityGroup) -> some View {
        let tasks = DefaultSkillLibrary.taskSkills.filter { $0.taskDisabilityGroup == group }
        if !tasks.isEmpty {
            VStack(alignment: .leading, spacing: TTSpacing.sm) {
                // Group header
                HStack(spacing: TTSpacing.xs) {
                    Image(systemName: group.icon)
                        .font(.subheadline)
                        .foregroundColor(.accentInteractive)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(group.rawValue)
                            .font(TTFont.headline)
                            .foregroundColor(.textPrimary)
                        Text(group.description)
                            .font(TTFont.caption)
                            .foregroundColor(.textSecondary)
                    }
                }

                // Task rows
                ForEach(tasks, id: \.name) { template in
                    let isSelected = selectedTaskNames.contains(template.name)
                    Button {
                        if isSelected {
                            selectedTaskNames.remove(template.name)
                        } else {
                            selectedTaskNames.insert(template.name)
                        }
                    } label: {
                        HStack(spacing: TTSpacing.sm) {
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isSelected ? .accentInteractive : .fillSecondary)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(template.name)
                                    .font(TTFont.bodySmall)
                                    .foregroundColor(.textPrimary)
                                Text(template.importance.rawValue)
                                    .font(TTFont.caption)
                                    .foregroundColor(.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(TTSpacing.sm)
                        .background(isSelected ? Color.accentLight.opacity(0.08) : Color.surface)
                        .clipShape(RoundedRectangle(cornerRadius: TTRadius.sm))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Step 4: Skill Inventory

    private var skillInventoryStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TTSpacing.lg) {
                stepHeader(
                    emoji: "✅",
                    title: "Skill inventory",
                    subtitle: "For each default skill, set where your dog currently is. You can update these any time."
                )

                ForEach(activeCategories.sorted(by: { $0.rawValue < $1.rawValue })) { category in
                    skillCategorySection(category)
                }

                navButtons()
                    .padding(.bottom, TTSpacing.xl)
            }
            .padding(.horizontal, TTSpacing.md)
            .padding(.top, TTSpacing.md)
        }
    }

    @ViewBuilder
    private func skillCategorySection(_ category: TrainingCategoryType) -> some View {
        VStack(alignment: .leading, spacing: TTSpacing.sm) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(.textPrimary)
                Text(category.shortName)
                    .font(TTFont.headline)
                    .foregroundColor(.textPrimary)
            }
            ForEach(DefaultSkillLibrary.skills(for: category).filter { template in
                // For task skills, only show the ones the handler selected in step 3
                category != .task || selectedTaskNames.contains(template.name)
            }, id: \.name) { template in
                HStack {
                    Text(template.name)
                        .font(TTFont.bodySmall)
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Picker("", selection: Binding(
                        get: { skillStatuses[template.name] ?? .developing },
                        set: { skillStatuses[template.name] = $0 }
                    )) {
                        ForEach(SkillStatus.allCases) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.accentInteractive)
                }
                .padding(.horizontal, TTSpacing.sm)
                .padding(.vertical, TTSpacing.xs)
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: TTRadius.sm))
            }
        }
    }

    // MARK: - Step 4: Schedule

    private var scheduleStep: some View {
        VStack(spacing: TTSpacing.lg) {
            Spacer()
            stepHeader(
                emoji: "📅",
                title: "Your schedule",
                subtitle: "You can configure your day-by-day training schedule in Settings after setup. For now, default schedules will be created."
            )
            Spacer()
            navButtons()
                .padding(.horizontal, TTSpacing.md)
                .padding(.bottom, TTSpacing.xl)
        }
    }

    // MARK: - Step 5: Handler Notes

    private var handlerNotesStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TTSpacing.lg) {
                stepHeader(
                    emoji: "💙",
                    title: "About you (optional)",
                    subtitle: "Any physical limitations, sensory sensitivities, or context the app should know about?"
                )

                TextEditor(text: $handlerNotes)
                    .font(TTFont.body)
                    .frame(minHeight: 120)
                    .padding(TTSpacing.sm)
                    .background(Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: TTRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: TTRadius.md)
                            .strokeBorder(Color.fillSecondary, lineWidth: 1)
                    )
                    .scrollContentBackground(.hidden)

                Text("This is stored only on your device and never shared.")
                    .font(TTFont.caption)
                    .foregroundColor(.textSecondary)

                navButtons()
                    .padding(.bottom, TTSpacing.xl)
            }
            .padding(.horizontal, TTSpacing.md)
            .padding(.top, TTSpacing.md)
        }
    }

    // MARK: - Step 6: Disclaimer

    private var disclaimerStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TTSpacing.lg) {
                stepHeader(
                    emoji: "📋",
                    title: "One more thing",
                    subtitle: "Please read and acknowledge before we get started."
                )

                VStack(alignment: .leading, spacing: TTSpacing.md) {
                    Text("Train Today is a planning tool for service dog handlers. It is not a replacement for working with a qualified service dog trainer.")
                        .font(TTFont.body)
                        .foregroundColor(.textPrimary)
                    Text("The developer is not a professional dog trainer. This app exists to support the disabled community in managing their training practice — not to provide professional advice.")
                        .font(TTFont.body)
                        .foregroundColor(.textPrimary)
                    Text("Always consult a certified trainer for guidance specific to your dog and your disability.")
                        .font(TTFont.body)
                        .foregroundColor(.textPrimary)
                }
                .ttCard()

                Toggle(isOn: $disclaimerAcknowledged) {
                    Text("I understand this is a planning tool, not professional training advice.")
                        .font(TTFont.bodySmall)
                        .foregroundColor(.textPrimary)
                }
                .tint(.accentInteractive)
                .padding(TTSpacing.sm)
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: TTRadius.md))

                Button("Get Started 🐾") {
                    completeOnboarding()
                }
                .buttonStyle(TTPrimaryButtonStyle())
                .disabled(!disclaimerAcknowledged)
                .padding(.bottom, TTSpacing.xl)
            }
            .padding(.horizontal, TTSpacing.md)
            .padding(.top, TTSpacing.md)
        }
    }

    // MARK: - Shared Helpers

    private func stepHeader(emoji: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: TTSpacing.xs) {
            Text(emoji).font(.system(size: 40))
            Text(title)
                .font(TTFont.display)
                .foregroundColor(.textPrimary)
            Text(subtitle)
                .font(TTFont.body)
                .foregroundColor(.textSecondary)
        }
    }

    private func inputField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: TTSpacing.xxs) {
            Text(title).font(TTFont.bodySmall).foregroundColor(.textSecondary)
            TextField(placeholder, text: text)
                .font(TTFont.body)
                .padding(TTSpacing.sm)
                .background(Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: TTRadius.sm))
                .overlay(RoundedRectangle(cornerRadius: TTRadius.sm)
                    .strokeBorder(Color.fillSecondary, lineWidth: 1))
        }
    }

    // MARK: - Complete Onboarding

    private func completeOnboarding() {
        // 1. Create dog profile
        let profile = DogProfile(
            name: dogName,
            breed: dogBreed,
            ageYears: dogAgeYears,
            ageMonths: dogAgeMonths,
            isProgramDog: isProgramDog,
            handlerNotes: handlerNotes,
            hasCompletedOnboarding: true
        )
        modelContext.insert(profile)

        // 2. Create default skill library with statuses from onboarding
        var order = 0
        for category in TrainingCategoryType.allCases {
            guard activeCategories.contains(category) else { continue }
            for template in DefaultSkillLibrary.skills(for: category) {
                // For Task Training, only seed tasks the handler selected in step 3
                if category == .task && !selectedTaskNames.contains(template.name) { continue }
                let status = skillStatuses[template.name] ?? .developing
                let skill = Skill(
                    name: template.name,
                    category: category,
                    status: status,
                    importance: template.importance,
                    requiredEnvironment: template.environment,
                    howToReminder: template.howToReminder,
                    successMetric: template.successMetric,
                    sortOrder: order,
                    minimumDurationMinutes: template.minimumDurationMinutes
                )
                modelContext.insert(skill)
                order += 1
            }
        }

        // 3. Create default schedule rules
        ScheduleRule.defaultRules().forEach { modelContext.insert($0) }

        // 4. Request notification permission
        notificationManager.requestAuthorization()

        // 5. Save
        try? modelContext.save()
    }
}
