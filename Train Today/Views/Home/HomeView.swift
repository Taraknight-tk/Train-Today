// HomeView.swift
// Train Today — Home / Dashboard
// Developed by Tara Knight | @Hopetheservicedoodle

import SwiftUI
import SwiftData

struct HomeView: View {

    @Environment(AppState.self) private var appState
    @Query private var skills: [Skill]
    @Query(sort: \TrainingSession.date, order: .reverse) private var sessions: [TrainingSession]
    @Query private var scheduleRules: [ScheduleRule]
    @Query private var profiles: [DogProfile]

    var body: some View {
        @Bindable var appState = appState
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: TTSpacing.lg) {

                        // Greeting header
                        greetingHeader

                        // Quick Win shortcut
                        quickWinCard

                        // Session inputs
                        sessionInputsCard(appState: $appState)

                        // Critical skill alerts
                        criticalAlertsSection

                        // Today's plan (if generated)
                        if let plan = appState.currentPlan, !appState.isGeneratingPlan {
                            SessionPlanCard(plan: plan)
                        }

                        // Generate button
                        generateButton

                        // Quick Log — retroactive session entry
                        quickLogButton

                        Spacer(minLength: TTSpacing.xxl)
                    }
                    .padding(.horizontal, TTSpacing.md)
                    .padding(.top, TTSpacing.md)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Train Today")
                        .font(TTFont.headline)
                        .foregroundColor(.textPrimary)
                }
            }
            .sheet(item: $appState.activeSheet) { sheet in
                switch sheet {
                case .sessionLog(let plan):
                    SessionLogView(plan: plan)
                case .quickWin:
                    if let plan = appState.currentPlan {
                        SessionPlanView(plan: plan, isQuickWin: true)
                    }
                case .quickLog:
                    QuickLogView()
                default:
                    EmptyView()
                }
            }
        }
    }

    // MARK: - Greeting Header

    private var greetingHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: TTSpacing.xxs) {
                Text(greetingText)
                    .font(TTFont.display)
                    .foregroundColor(.textPrimary)
                if let dog = profiles.first {
                    Text("Training with \(dog.name) 🐾")
                        .font(TTFont.bodySmall)
                        .foregroundColor(.textSecondary)
                }
            }
            Spacer()
            streakBadge
        }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning!"
        case 12..<17: return "Good afternoon!"
        case 17..<21: return "Good evening!"
        default:      return "Hey there!"
        }
    }

    // MARK: - Streak Badge

    private var streakBadge: some View {
        let streak = SchedulingEngine.currentStreak(sessions: Array(sessions))
        return VStack(spacing: 2) {
            Text("🔥")
                .font(.title2)
            Text("\(streak)")
                .font(TTFont.headline)
                .foregroundColor(.accentInteractive)
            Text(streak == 1 ? "day" : "days")
                .font(TTFont.caption)
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, TTSpacing.sm)
        .padding(.vertical, TTSpacing.xs)
        .background(Color.fillSecondary)
        .clipShape(RoundedRectangle(cornerRadius: TTRadius.md))
    }

    // MARK: - Quick Win Card

    private var quickWinCard: some View {
        Button {
            appState.generateQuickWin(skills: skills, sessions: Array(sessions))
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quick Win Mode")
                        .font(TTFont.headline)
                        .foregroundColor(.textPrimary)
                    Text("5 minutes · one easy skill · confidence boost")
                        .font(TTFont.caption)
                        .foregroundColor(.textSecondary)
                }
                Spacer()
                Image(systemName: "bolt.fill")
                    .font(.title2)
                    .foregroundColor(.accentInteractive)
            }
            .ttCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Session Inputs Card

    private func sessionInputsCard(appState: Bindable<AppState>) -> some View {
        VStack(alignment: .leading, spacing: TTSpacing.md) {
            Text("Today's Session")
                .font(TTFont.headline)
                .foregroundColor(.textPrimary)

            // Time
            inputRow(title: "Time available") {
                SessionDurationPicker(selected: appState.selectedDuration)
            }

            Divider().background(Color.fillSecondary)

            // Energy
            inputRow(title: "Energy today") {
                EnergyPicker(selected: appState.selectedEnergy)
            }

            Divider().background(Color.fillSecondary)

            // Location
            inputRow(title: "Where are you?") {
                LocationPicker(selected: appState.selectedLocation)
            }
        }
        .ttCard()
    }

    @ViewBuilder
    private func inputRow<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: TTSpacing.xs) {
            Text(title)
                .font(TTFont.bodySmall)
                .foregroundColor(.textSecondary)
            content()
        }
    }

    // MARK: - Critical Alerts

    @ViewBuilder
    private var criticalAlertsSection: some View {
        let overdue = skills.filter { $0.isCriticalOverdue }
        if !overdue.isEmpty {
            VStack(alignment: .leading, spacing: TTSpacing.xs) {
                ForEach(overdue) { skill in
                    HStack(spacing: TTSpacing.xs) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.textPrimary)
                        Text("\(skill.name) is overdue (Critical · \(skill.recencyLabel))")
                            .font(TTFont.bodySmall)
                            .foregroundColor(.textPrimary)
                        Spacer()
                    }
                    .padding(TTSpacing.sm)
                    .background(Color.warning.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: TTRadius.sm))
                }
            }
        }
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        Button {
            appState.generatePlan(
                skills: Array(skills),
                sessions: Array(sessions),
                scheduleRule: todayScheduleRule
            )
        } label: {
            HStack {
                if appState.isGeneratingPlan {
                    ProgressView()
                        .tint(.white)
                        .padding(.trailing, 4)
                }
                Text(appState.isGeneratingPlan ? "Building your plan…" : "Generate Today's Plan")
            }
        }
        .buttonStyle(TTPrimaryButtonStyle())
        .disabled(appState.isGeneratingPlan || skills.isEmpty)
    }

    // MARK: - Quick Log Button

    private var quickLogButton: some View {
        Button {
            appState.activeSheet = .quickLog
        } label: {
            HStack(spacing: TTSpacing.xs) {
                Image(systemName: "pencil.and.list.clipboard")
                Text("Log a Past Session")
            }
        }
        .buttonStyle(TTSecondaryButtonStyle())
    }

    // MARK: - Helpers

    private var todayScheduleRule: ScheduleRule? {
        let today = Weekday.today
        return scheduleRules.first { $0.weekday == today }
    }
}

// MARK: - Picker Sub-Components

struct SessionDurationPicker: View {
    @Binding var selected: SessionDuration

    var body: some View {
        HStack(spacing: TTSpacing.xs) {
            ForEach(SessionDuration.allCases) { duration in
                Button(duration.label) {
                    selected = duration
                }
                .font(TTFont.bodySmall)
                .padding(.horizontal, TTSpacing.sm)
                .padding(.vertical, TTSpacing.xxs + 2)
                .background(selected == duration ? Color.accentInteractive : Color.fillSecondary)
                .foregroundColor(selected == duration ? .white : .textPrimary)
                .clipShape(Capsule())
            }
        }
    }
}

struct EnergyPicker: View {
    @Binding var selected: EnergyLevel

    var body: some View {
        HStack(spacing: TTSpacing.xs) {
            ForEach(EnergyLevel.allCases) { level in
                Button {
                    selected = level
                } label: {
                    HStack(spacing: 4) {
                        Text(level.emoji)
                        Text(level.rawValue)
                            .font(TTFont.bodySmall)
                    }
                    .padding(.horizontal, TTSpacing.sm)
                    .padding(.vertical, TTSpacing.xxs + 2)
                    .background(selected == level ? Color.accentInteractive : Color.fillSecondary)
                    .foregroundColor(selected == level ? .white : .textPrimary)
                    .clipShape(Capsule())
                }
            }
        }
    }
}

struct LocationPicker: View {
    @Binding var selected: SkillEnvironment

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TTSpacing.xs) {
                ForEach(SkillEnvironment.allCases) { env in
                    Button {
                        selected = env
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: env.icon)
                            Text(env.rawValue)
                                .font(TTFont.bodySmall)
                        }
                        .padding(.horizontal, TTSpacing.sm)
                        .padding(.vertical, TTSpacing.xxs + 2)
                        .background(selected == env ? Color.accentInteractive : Color.fillSecondary)
                        .foregroundColor(selected == env ? .white : .textPrimary)
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }
}
