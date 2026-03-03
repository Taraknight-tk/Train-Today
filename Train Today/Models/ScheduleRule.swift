// ScheduleRule.swift
// Train Today — Schedule Rule Model (one per day of week)
// Developed by Tara Knight | @Hopetheservicedoodle

import Foundation
import SwiftData

@Model
final class ScheduleRule {

    // MARK: - Properties

    var weekdayRaw: Int                     // Weekday.rawValue (1=Sun … 7=Sat)
    var maxMinutes: Int                     // 0 = no training scheduled this day
    var priorityCategoryRaw: String?        // Optional TrainingCategoryType rawValue
    var isEnabled: Bool                     // quick on/off without losing settings
    var reminderEnabled: Bool               // local notification on this day
    var reminderHour: Int                   // hour component of reminder time (0–23)
    var reminderMinute: Int                 // minute component of reminder time (0–59)

    // MARK: - Typed Computed Properties

    var weekday: Weekday {
        get { Weekday(rawValue: weekdayRaw) ?? .monday }
        set { weekdayRaw = newValue.rawValue }
    }

    var priorityCategory: TrainingCategoryType? {
        get {
            guard let raw = priorityCategoryRaw else { return nil }
            return TrainingCategoryType(rawValue: raw)
        }
        set { priorityCategoryRaw = newValue?.rawValue }
    }

    var reminderTimeLabel: String {
        let hour   = reminderHour
        let minute = reminderMinute
        let ampm   = hour < 12 ? "AM" : "PM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d %@", displayHour, minute, ampm)
    }

    // MARK: - Init

    init(
        weekday: Weekday,
        maxMinutes: Int = 20,
        priorityCategory: TrainingCategoryType? = nil,
        isEnabled: Bool = true,
        reminderEnabled: Bool = false,
        reminderHour: Int = 9,
        reminderMinute: Int = 0
    ) {
        self.weekdayRaw             = weekday.rawValue
        self.maxMinutes             = maxMinutes
        self.priorityCategoryRaw    = priorityCategory?.rawValue
        self.isEnabled              = isEnabled
        self.reminderEnabled        = reminderEnabled
        self.reminderHour           = reminderHour
        self.reminderMinute         = reminderMinute
    }

    // MARK: - Factory: Default Rules

    static func defaultRules() -> [ScheduleRule] {
        Weekday.allCases.map { weekday in
            let maxMin: Int
            switch weekday {
            case .monday, .wednesday, .friday: maxMin = 15
            case .tuesday, .thursday:          maxMin = 20
            case .saturday:                    maxMin = 30
            case .sunday:                      maxMin = 10
            }
            return ScheduleRule(weekday: weekday, maxMinutes: maxMin)
        }
    }
}
