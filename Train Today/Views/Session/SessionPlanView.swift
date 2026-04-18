// SessionPlanView.swift
// Train Today — Session Plan Display
// Developed by Tara Knight | @Hopetheservicedoodle

import SwiftUI
import SwiftData

struct SessionPlanView: View {

    let plan: SessionPlan
    var isQuickWin: Bool = false
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var showingLog = false

    @Query private var skills: [Skill]
    @Query(sort: \TrainingSession.date, order: .reverse) private var sessions: [TrainingSession]
    @Query private var scheduleRules: [ScheduleRule]

    private var todayScheduleRule: ScheduleRule? {
        let today = Weekday.today
        return scheduleRules.first { $0.weekday == today }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()

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
                        .foregroundColor(.accentInteractive)
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
                    .foregroundColor(.textPrimary)
                Text("One easy skill. 5 minutes. You've got this.")
                    .font(TTFont.bodySmall)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Your session plan is ready.")
                    .font(TTFont.display)
                    .foregroundColor(.textPrimary)
                Text("Total: ~\(plan.totalMinutes) minutes")
                    .font(TTFont.body)
                    .foregroundColor(.textSecondary)
            }
        }
        .multilineTextAlignment(.center)
    }

    // MARK: - Warning Banner

    private func warningBanner(_ text: String) -> some View {
        HStack(spacing: TTSpacing.xs) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.textPrimary)
            Text(text)
                .font(TTFont.bodySmall)
                .foregroundColor(.textPrimary)
        }
        .padding(TTSpacing.sm)
        .background(Color.warning.opacity(0.12))
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
                .foregroundColor(.textPrimary)

            // Duration
            HStack(spacing: TTSpacing.xxs) {
                Image(systemName: "clock")
                    .foregroundColor(.accentInteractive)
                Text("~\(item.suggestedMinutes) min")
                    .font(TTFont.body)
                    .foregroundColor(.textPrimary)
                if item.adjustedForLowEnergy {
                    Text("· low energy version")
                        .font(TTFont.bodySmall)
                        .foregroundColor(.textSecondary)
                }
            }

            // How-to reminder
            if !skill.howToReminder.isEmpty {
                VStack(alignment: .leading, spacing: TTSpacing.xxs) {
                    Text("How to practice")
                        .font(TTFont.caption)
                        .foregroundColor(.textSecondary)
                        .textCase(.uppercase)
                    Text(skill.howToReminder)
                        .font(TTFont.body)
                        .foregroundColor(.textPrimary)
                }
                .padding(TTSpacing.sm)
                .background(Color.fillSecondary)
                .clipShape(RoundedRectangle(cornerRadius: TTRadius.sm))
            }

            // Success metric
            if !skill.successMetric.isEmpty {
                VStack(alignment: .leading, spacing: TTSpacing.xxs) {
                    Text("You're done when…")
                        .font(TTFont.caption)
                        .foregroundColor(.textSecondary)
                        .textCase(.uppercase)
                    Text(skill.successMetric)
                        .font(TTFont.body)
                        .foregroundColor(.textPrimary)
                }
                .padding(TTSpacing.sm)
                .background(TTColor.forCategory(category).opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: TTRadius.sm))
            }

            // Recency
            HStack(spacing: TTSpacing.xxs) {
                Image(systemName: "calendar")
                    .foregroundColor(.textSecondary)
                Text(skill.recencyLabel)
                    .font(TTFont.caption)
                    .foregroundColor(.textSecondary)
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
                .foregroundColor(.textSecondary)
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
                dismiss()
                appState.generatePlan(
                    skills: Array(skills),
                    sessions: Array(sessions),
                    scheduleRule: todayScheduleRule
                )
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
                        .foregroundColor(.textPrimary)
                    Text("\(plan.primarySkill.skill.name) · ~\(plan.totalMinutes) min")
                        .font(TTFont.bodySmall)
                        .foregroundColor(.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.accentInteractive)
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
        .background(TTColor.forCategory(category).opacity(0.15))
        .foregroundColor(.textPrimary)
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
            .background(importance == .critical ? Color.warning.opacity(0.15) : Color.fillSecondary)
            .foregroundColor(importance == .critical ? .textPrimary : .textSecondary)
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
        .background(Color.accentLighter.opacity(0.2))
        .foregroundColor(.accentInteractive)
        .clipShape(Capsule())
    }
}
