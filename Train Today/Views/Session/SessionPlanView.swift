// SessionPlanView.swift
// Train Today — Session Plan Display
// Developed by Tara Knight | @Hopetheservicedoodle

import SwiftUI

struct SessionPlanView: View {

    let plan: SessionPlan
    var isQuickWin: Bool = false
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var showingLog = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ttBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: TTSpacing.lg) {

                        // Header
                        planHeader

                        // Warning if any
                        if let warning = plan.warningMessage {
                            warningBanner(warning)
                        }

                        // Primary skill
                        skillCard(item: plan.primarySkill, isPrimary: true)

                        // Secondary skill (if time permits)
                        if let secondary = plan.secondarySkill {
                            secondaryDivider
                            skillCard(item: secondary, isPrimary: false)
                        }

                        // Action buttons
                        actionButtons

                        Spacer(minLength: TTSpacing.xxl)
                    }
                    .padding(.horizontal, TTSpacing.md)
                    .padding(.top, TTSpacing.md)
                }
            }
            .navigationTitle(isQuickWin ? "Quick Win" : "Today's Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.ttPrimary)
                }
            }
            .sheet(isPresented: $showingLog) {
                SessionLogView(plan: plan)
            }
        }
    }

    // MARK: - Plan Header

    private var planHeader: some View {
        VStack(spacing: TTSpacing.xs) {
            if isQuickWin {
                Text("Quick Win 🎉")
                    .font(TTFont.display)
                    .foregroundColor(.ttText)
                Text("One easy skill. 5 minutes. You've got this.")
                    .font(TTFont.bodySmall)
                    .foregroundColor(.ttTextSecondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Your session plan is ready.")
                    .font(TTFont.display)
                    .foregroundColor(.ttText)
                Text("Total: ~\(plan.totalMinutes) minutes")
                    .font(TTFont.body)
                    .foregroundColor(.ttTextSecondary)
            }
        }
        .multilineTextAlignment(.center)
    }

    // MARK: - Warning Banner

    private func warningBanner(_ text: String) -> some View {
        HStack(spacing: TTSpacing.xs) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.ttWarning)
            Text(text)
                .font(TTFont.bodySmall)
                .foregroundColor(.ttText)
        }
        .padding(TTSpacing.sm)
        .background(Color.ttWarning.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: TTRadius.md))
    }

    // MARK: - Skill Card

    @ViewBuilder
    private func skillCard(item: SessionSkillItem, isPrimary: Bool) -> some View {
        let skill = item.skill
        let category = skill.category

        VStack(alignment: .leading, spacing: TTSpacing.md) {

            // Category tag + importance badge
            HStack {
                CategoryTag(category: category)
                Spacer()
                ImportanceBadge(importance: skill.importance)
                if item.adjustedForLowEnergy {
                    LowEnergyBadge()
                }
            }

            // Skill name
            Text(skill.name)
                .font(isPrimary ? TTFont.display : TTFont.title)
                .foregroundColor(.ttText)

            // Duration
            HStack(spacing: TTSpacing.xxs) {
                Image(systemName: "clock")
                    .foregroundColor(.ttPrimary)
                Text("~\(item.suggestedMinutes) min")
                    .font(TTFont.body)
                    .foregroundColor(.ttText)
                if item.adjustedForLowEnergy {
                    Text("· low energy version")
                        .font(TTFont.bodySmall)
                        .foregroundColor(.ttTextSecondary)
                }
            }

            // How-to reminder
            if !skill.howToReminder.isEmpty {
                VStack(alignment: .leading, spacing: TTSpacing.xxs) {
                    Text("How to practice")
                        .font(TTFont.caption)
                        .foregroundColor(.ttTextSecondary)
                        .textCase(.uppercase)
                    Text(skill.howToReminder)
                        .font(TTFont.body)
                        .foregroundColor(.ttText)
                }
                .padding(TTSpacing.sm)
                .background(Color.ttSecondaryLight)
                .clipShape(RoundedRectangle(cornerRadius: TTRadius.sm))
            }

            // Success metric
            if !skill.successMetric.isEmpty {
                VStack(alignment: .leading, spacing: TTSpacing.xxs) {
                    Text("You're done when…")
                        .font(TTFont.caption)
                        .foregroundColor(.ttTextSecondary)
                        .textCase(.uppercase)
                    Text(skill.successMetric)
                        .font(TTFont.body)
                        .foregroundColor(.ttText)
                }
                .padding(TTSpacing.sm)
                .background(Color.forCategory(category).opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: TTRadius.sm))
            }

            // Recency
            HStack(spacing: TTSpacing.xxs) {
                Image(systemName: "calendar")
                    .foregroundColor(.ttTextSecondary)
                Text(skill.recencyLabel)
                    .font(TTFont.caption)
                    .foregroundColor(.ttTextSecondary)
            }
        }
        .ttCard()
    }

    // MARK: - Secondary Divider

    private var secondaryDivider: some View {
        HStack {
            VStack { Divider() }
            Text("If time allows")
                .font(TTFont.caption)
                .foregroundColor(.ttTextSecondary)
                .fixedSize()
            VStack { Divider() }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: TTSpacing.sm) {
            Button("Log This Session") {
                showingLog = true
            }
            .buttonStyle(TTPrimaryButtonStyle())

            Button("Skip & Generate Another") {
                appState.clearPlan()
                dismiss()
            }
            .buttonStyle(TTSecondaryButtonStyle())
        }
    }
}

// MARK: - Session Plan Card (inline on Home)

struct SessionPlanCard: View {

    let plan: SessionPlan
    @Environment(AppState.self) private var appState
    @State private var showingFullPlan = false

    var body: some View {
        Button {
            showingFullPlan = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: TTSpacing.xxs) {
                    Text("Your plan is ready 🎯")
                        .font(TTFont.headline)
                        .foregroundColor(.ttText)
                    Text("\(plan.primarySkill.skill.name) · ~\(plan.totalMinutes) min")
                        .font(TTFont.bodySmall)
                        .foregroundColor(.ttTextSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.ttPrimary)
            }
            .ttCard()
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingFullPlan) {
            SessionPlanView(plan: plan)
        }
    }
}

// MARK: - Reusable Badges

struct CategoryTag: View {
    let category: TrainingCategoryType

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
            Text(category.shortName)
                .font(TTFont.tag)
        }
        .padding(.horizontal, TTSpacing.sm)
        .padding(.vertical, TTSpacing.xxs)
        .background(Color.forCategory(category).opacity(0.15))
        .foregroundColor(Color.forCategory(category))
        .clipShape(Capsule())
    }
}

struct ImportanceBadge: View {
    let importance: SkillImportance

    var body: some View {
        if importance != .standard {
            HStack(spacing: 4) {
                Image(systemName: importance.icon)
                Text(importance.rawValue)
                    .font(TTFont.tag)
            }
            .padding(.horizontal, TTSpacing.xs)
            .padding(.vertical, 3)
            .background(importance == .critical ? Color.ttWarning.opacity(0.15) : Color.ttSecondaryLight)
            .foregroundColor(importance == .critical ? .ttWarning : .ttTextSecondary)
            .clipShape(Capsule())
        }
    }
}

struct LowEnergyBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Text("🌿")
            Text("Light version")
                .font(TTFont.tag)
        }
        .padding(.horizontal, TTSpacing.xs)
        .padding(.vertical, 3)
        .background(Color.ttPrimaryLight.opacity(0.2))
        .foregroundColor(.ttPrimary)
        .clipShape(Capsule())
    }
}
