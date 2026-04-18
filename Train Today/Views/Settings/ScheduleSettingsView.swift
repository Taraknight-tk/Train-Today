// ScheduleSettingsView.swift
// Train Today — Day-of-Week Schedule Configuration
// Developed by Tara Knight | @Hopetheservicedoodle

import SwiftUI
import SwiftData

// MARK: - Schedule Settings View

struct ScheduleSettingsView: View {

    @Query private var rules: [ScheduleRule]
    @Environment(\.modelContext) private var modelContext

    private func ruleFor(_ weekday: Weekday) -> ScheduleRule? {
        rules.first { $0.weekday == weekday }
    }

    var body: some View {
        ZStack {
            Color.ttBackground.ignoresSafeArea()

            List {
                Section {
                    Text("Set your training preferences for each day. The app uses these to adjust your session plans automatically.")
                        .font(TTFont.bodySmall)
                        .foregroundColor(.ttTextSecondary)
                        .listRowBackground(Color.ttBackground)
                }

                Section("Weekly Schedule") {
                    ForEach(Weekday.allCases) { weekday in
                        // Only render the row once the rule exists.
                        // DayRowView owns its own isExpanded @State so parent
                        // re-renders from @Query never collapse an open row.
                        if let rule = ruleFor(weekday) {
                            DayRowView(rule: rule)
                        }
                    }
                }
                .listRowBackground(Color.ttSurface)
            }
            .scrollContentBackground(.hidden)
            .background(Color.ttBackground)
        }
        .navigationTitle("Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { ensureRulesExist() }
    }

    // MARK: - Ensure Rules Exist

    private func ensureRulesExist() {
        guard rules.isEmpty else { return }
        ScheduleRule.defaultRules().forEach { modelContext.insert($0) }
        try? modelContext.save()
    }
}

// MARK: - Day Row View
// Each row owns its expansion state. When ScheduleSettingsView re-renders
// after a @Query refresh, SwiftUI uses the Weekday.id identity from the
// ForEach to preserve this view's @State, so isExpanded never resets.

private struct DayRowView: View {

    @Bindable var rule: ScheduleRule
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Summary row — always visible
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(rule.weekday.fullName)
                            .font(TTFont.body)
                            .foregroundColor(.ttText)
                        Text(rule.maxMinutes == 0 ? "Rest day" : "\(rule.maxMinutes) min max")
                            .font(TTFont.caption)
                            .foregroundColor(.ttTextSecondary)
                    }
                    Spacer()
                    if rule.reminderEnabled {
                        HStack(spacing: 4) {
                            Image(systemName: "bell.fill")
                                .font(.caption2)
                            Text(rule.reminderTimeLabel)
                                .font(TTFont.caption)
                        }
                        .foregroundColor(.ttPrimaryInteractive)
                    }
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.ttTextSecondary)
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical, TTSpacing.xs)

            // Expanded controls
            if isExpanded {
                Divider().padding(.vertical, TTSpacing.xxs)
                DayControlsView(rule: rule)
            }
        }
    }
}

// MARK: - Day Controls View
// @Bindable gives proper two-way access to the @Model object so SwiftUI
// can track rule.maxMinutes in THIS view's body only, keeping renders
// scoped and stable.

private struct DayControlsView: View {

    @Bindable var rule: ScheduleRule
    @Environment(\.modelContext) private var modelContext
    @State private var notificationManager = NotificationManager()

    var body: some View {
        VStack(alignment: .leading, spacing: TTSpacing.sm) {

            // Max minutes
            VStack(alignment: .leading, spacing: TTSpacing.xxs) {
                Text("Max session length")
                    .font(TTFont.caption)
                    .foregroundColor(.ttTextSecondary)
                HStack(spacing: TTSpacing.xs) {
                    ForEach([0, 5, 10, 15, 20, 30], id: \.self) { mins in
                        Button(mins == 0 ? "Rest" : "\(mins)m") {
                            rule.maxMinutes = mins
                            try? modelContext.save()
                        }
                        .buttonStyle(.borderless)
                        .font(TTFont.caption)
                        .padding(.horizontal, TTSpacing.xs)
                        .padding(.vertical, 4)
                        .background(rule.maxMinutes == mins ? TTColor.primaryInteractive : Color.ttSecondaryLight)
                        .foregroundColor(rule.maxMinutes == mins ? .white : .ttText)
                        .clipShape(Capsule())
                    }
                }
            }

            // Priority category
            VStack(alignment: .leading, spacing: TTSpacing.xxs) {
                Text("Priority category (optional)")
                    .font(TTFont.caption)
                    .foregroundColor(.ttTextSecondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: TTSpacing.xs) {
                        Button("None") {
                            rule.priorityCategory = nil
                            try? modelContext.save()
                        }
                        .buttonStyle(.borderless)
                        .font(TTFont.caption)
                        .padding(.horizontal, TTSpacing.xs)
                        .padding(.vertical, 4)
                        .background(rule.priorityCategory == nil ? TTColor.primaryInteractive : Color.ttSecondaryLight)
                        .foregroundColor(rule.priorityCategory == nil ? .white : .ttText)
                        .clipShape(Capsule())

                        ForEach(TrainingCategoryType.allCases) { cat in
                            Button(cat.shortName) {
                                rule.priorityCategory = cat
                                try? modelContext.save()
                            }
                            .buttonStyle(.borderless)
                            .font(TTFont.caption)
                            .padding(.horizontal, TTSpacing.xs)
                            .padding(.vertical, 4)
                            .background(rule.priorityCategory == cat ? TTColor.forCategory(cat) : Color.ttSecondaryLight)
                            .foregroundColor(rule.priorityCategory == cat ? .ttText : .ttText)
                            .clipShape(Capsule())
                        }
                    }
                }
            }

            // Reminder toggle — $rule binding via @Bindable, side-effects via .onChange
            Toggle(isOn: $rule.reminderEnabled) {
                Text("Training reminder")
                    .font(TTFont.bodySmall)
                    .foregroundColor(.ttText)
            }
            .tint(.ttPrimaryInteractive)
            .onChange(of: rule.reminderEnabled) { _, newValue in
                try? modelContext.save()
                if newValue {
                    notificationManager.scheduleReminder(for: rule)
                } else {
                    notificationManager.cancelReminder(for: rule.weekday)
                }
            }

            if rule.reminderEnabled {
                HStack {
                    Text("Reminder time")
                        .font(TTFont.caption)
                        .foregroundColor(.ttTextSecondary)
                    Spacer()
                    DatePicker(
                        "",
                        selection: Binding(
                            get: {
                                var comps        = DateComponents()
                                comps.hour       = rule.reminderHour
                                comps.minute     = rule.reminderMinute
                                return Calendar.current.date(from: comps) ?? Date()
                            },
                            set: { date in
                                rule.reminderHour   = Calendar.current.component(.hour, from: date)
                                rule.reminderMinute = Calendar.current.component(.minute, from: date)
                                try? modelContext.save()
                                notificationManager.scheduleReminder(for: rule)
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
            }
        }
        .padding(.bottom, TTSpacing.sm)
    }
}
