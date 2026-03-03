// ScheduleSettingsView.swift
// Train Today — Day-of-Week Schedule Configuration
// Developed by Tara Knight | @Hopetheservicedoodle

import SwiftUI
import SwiftData

struct ScheduleSettingsView: View {

    @Query private var rules: [ScheduleRule]
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationManager.self) private var notificationManager
    @State private var expandedDay: Weekday? = nil

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
                        dayRow(weekday)
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

    // MARK: - Day Row

    @ViewBuilder
    private func dayRow(_ weekday: Weekday) -> some View {
        let rule = ruleFor(weekday)
        let isExpanded = expandedDay == weekday

        VStack(alignment: .leading, spacing: 0) {
            // Summary row (always visible)
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedDay = isExpanded ? nil : weekday
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(weekday.fullName)
                            .font(TTFont.body)
                            .foregroundColor(.ttText)
                        if let r = rule {
                            Text(r.maxMinutes == 0 ? "Rest day" : "\(r.maxMinutes) min max")
                                .font(TTFont.caption)
                                .foregroundColor(.ttTextSecondary)
                        }
                    }
                    Spacer()
                    if let r = rule, r.reminderEnabled {
                        HStack(spacing: 4) {
                            Image(systemName: "bell.fill")
                                .font(.caption2)
                            Text(r.reminderTimeLabel)
                                .font(TTFont.caption)
                        }
                        .foregroundColor(.ttPrimary)
                    }
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.ttTextSecondary)
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical, TTSpacing.xs)

            // Expanded controls
            if isExpanded, let r = rule {
                Divider().padding(.vertical, TTSpacing.xs)
                dayControls(rule: r)
            }
        }
    }

    @ViewBuilder
    private func dayControls(rule: ScheduleRule) -> some View {
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
                        .font(TTFont.caption)
                        .padding(.horizontal, TTSpacing.xs)
                        .padding(.vertical, 4)
                        .background(rule.maxMinutes == mins ? Color.ttPrimary : Color.ttSecondaryLight)
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
                        // None option
                        Button("None") {
                            rule.priorityCategory = nil
                            try? modelContext.save()
                        }
                        .font(TTFont.caption)
                        .padding(.horizontal, TTSpacing.xs)
                        .padding(.vertical, 4)
                        .background(rule.priorityCategory == nil ? Color.ttPrimary : Color.ttSecondaryLight)
                        .foregroundColor(rule.priorityCategory == nil ? .white : .ttText)
                        .clipShape(Capsule())

                        ForEach(TrainingCategoryType.allCases) { cat in
                            Button(cat.shortName) {
                                rule.priorityCategory = cat
                                try? modelContext.save()
                            }
                            .font(TTFont.caption)
                            .padding(.horizontal, TTSpacing.xs)
                            .padding(.vertical, 4)
                            .background(rule.priorityCategory == cat ? Color.forCategory(cat) : Color.ttSecondaryLight)
                            .foregroundColor(rule.priorityCategory == cat ? .white : .ttText)
                            .clipShape(Capsule())
                        }
                    }
                }
            }

            // Reminder toggle
            Toggle(isOn: Binding(
                get: { rule.reminderEnabled },
                set: { newValue in
                    rule.reminderEnabled = newValue
                    try? modelContext.save()
                    if newValue {
                        notificationManager.scheduleReminder(for: rule)
                    } else {
                        notificationManager.cancelReminder(for: rule.weekday)
                    }
                }
            )) {
                Text("Training reminder")
                    .font(TTFont.bodySmall)
                    .foregroundColor(.ttText)
            }
            .tint(.ttPrimary)

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

    // MARK: - Ensure Rules Exist

    private func ensureRulesExist() {
        guard rules.isEmpty else { return }
        ScheduleRule.defaultRules().forEach { modelContext.insert($0) }
        try? modelContext.save()
    }
}
