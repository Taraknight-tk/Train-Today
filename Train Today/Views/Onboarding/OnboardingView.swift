// OnboardingView.swift
// Train Today — First-Run Onboarding Flow
// Developed by Tara Knight | @Hopetheservicedoodle
//
// Steps:
//  1. Welcome
//  2. Dog Profile
//  3. Training Categories
//  4. Skill Inventory
//  5. Schedule Preferences
//  6. Handler Notes
//  7. Disclaimer Acknowledgment

import SwiftUI
import SwiftData

struct OnboardingView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationManager.self) private var notificationManager

    @State private var currentStep: Int = 0
    private let totalSteps = 7

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

    // Disclaimer
    @State private var disclaimerAcknowledged: Bool = false

    var body: some View {
        ZStack {
            Color.ttBackground.ignoresSafeArea()

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
                    skillInventoryStep.tag(3)
                    scheduleStep.tag(4)
                    handlerNotesStep.tag(5)
                    disclaimerStep.tag(6)
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
                    .fill(Color.ttSecondaryLight)
                    .frame(height: 4)
                Capsule()
                    .fill(Color.ttPrimary)
                    .frame(width: geo.size.width * (CGFloat(currentStep + 1) / CGFloat(totalSteps)), height: 4)
                    .animation(.easeInOut, value: currentStep)
            }
        }
        .frame(height: 4)
    }

    // MARK: - Navigation Helpers

    private func nextStep() {
        withAnimation { currentStep = min(currentStep + 1, totalSteps - 1) }
    }

    private func prevStep() {
        withAnimation { currentStep = max(currentStep - 1, 0) }
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
                .foregroundColor(.ttText)
                .multilineTextAlignment(.center)
            Text("Your personal service dog training planner. Tell us a little about your team and we'll get you set up in about 5 minutes.")
                .font(TTFont.body)
                .foregroundColor(.ttTextSecondary)
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
                        Text("Age").font(TTFont.bodySmall).foregroundColor(.ttTextSecondary)
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
                        .tint(.ttPrimary)
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
                    .foregroundColor(isActive ? Color.forCategory(category) : .ttTextSecondary)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.rawValue)
                        .font(TTFont.body)
                        .foregroundColor(.ttText)
                    Text(category.description)
                        .font(TTFont.caption)
                        .foregroundColor(.ttTextSecondary)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isActive ? Color.forCategory(category) : .ttSecondaryLight)
            }
            .ttCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 3: Skill Inventory

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
                    .foregroundColor(Color.forCategory(category))
                Text(category.shortName)
                    .font(TTFont.headline)
                    .foregroundColor(.ttText)
            }
            ForEach(DefaultSkillLibrary.skills(for: category), id: \.name) { template in
                HStack {
                    Text(template.name)
                        .font(TTFont.bodySmall)
                        .foregroundColor(.ttText)
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
                    .tint(.ttPrimary)
                }
                .padding(.horizontal, TTSpacing.sm)
                .padding(.vertical, TTSpacing.xs)
                .background(Color.ttSurface)
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
                    .background(Color.ttSurface)
                    .clipShape(RoundedRectangle(cornerRadius: TTRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: TTRadius.md)
                            .strokeBorder(Color.ttSecondaryLight, lineWidth: 1)
                    )
                    .scrollContentBackground(.hidden)

                Text("This is stored only on your device and never shared.")
                    .font(TTFont.caption)
                    .foregroundColor(.ttTextSecondary)

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
                        .foregroundColor(.ttText)
                    Text("The developer is not a professional dog trainer. This app exists to support the disabled community in managing their training practice — not to provide professional advice.")
                        .font(TTFont.body)
                        .foregroundColor(.ttText)
                    Text("Always consult a certified trainer for guidance specific to your dog and your disability.")
                        .font(TTFont.body)
                        .foregroundColor(.ttText)
                }
                .ttCard()

                Toggle(isOn: $disclaimerAcknowledged) {
                    Text("I understand this is a planning tool, not professional training advice.")
                        .font(TTFont.bodySmall)
                        .foregroundColor(.ttText)
                }
                .tint(.ttPrimary)
                .padding(TTSpacing.sm)
                .background(Color.ttSurface)
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
                .foregroundColor(.ttText)
            Text(subtitle)
                .font(TTFont.body)
                .foregroundColor(.ttTextSecondary)
        }
    }

    private func inputField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: TTSpacing.xxs) {
            Text(title).font(TTFont.bodySmall).foregroundColor(.ttTextSecondary)
            TextField(placeholder, text: text)
                .font(TTFont.body)
                .padding(TTSpacing.sm)
                .background(Color.ttSurface)
                .clipShape(RoundedRectangle(cornerRadius: TTRadius.sm))
                .overlay(RoundedRectangle(cornerRadius: TTRadius.sm)
                    .strokeBorder(Color.ttSecondaryLight, lineWidth: 1))
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
                let status = skillStatuses[template.name] ?? .developing
                let skill = Skill(
                    name: template.name,
                    category: category,
                    status: status,
                    importance: template.importance,
                    requiredEnvironment: template.environment,
                    howToReminder: template.howToReminder,
                    successMetric: template.successMetric,
                    sortOrder: order
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
