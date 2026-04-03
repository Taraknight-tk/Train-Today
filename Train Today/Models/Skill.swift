// Skill.swift
// Train Today — Skill Model
// Developed by Tara Knight | @Hopetheservicedoodle

import Foundation
import SwiftData

@Model
final class Skill {

    // MARK: - Properties

    var name: String
    var categoryRaw: String
    var statusRaw: String
    var importanceRaw: String
    var requiredEnvironmentRaw: String
    var howToReminder: String       // plain-language training tip shown in session plan
    var successMetric: String       // "when enough is enough" cue for the handler
    var lastPracticed: Date?
    var isActive: Bool              // handler can deactivate without deleting
    var isCustom: Bool              // true = handler-added, false = default library skill
    var sortOrder: Int              // for display ordering within a category
    var notes: String               // handler-specific notes on this skill
    var minimumDurationMinutes: Int // 0 = no minimum; >0 = skill requires this many minutes (e.g. crate training = 60)

    // MARK: - Typed Computed Properties

    var category: TrainingCategoryType {
        get { TrainingCategoryType(rawValue: categoryRaw) ?? .obedience }
        set { categoryRaw = newValue.rawValue }
    }

    var status: SkillStatus {
        get { SkillStatus(rawValue: statusRaw) ?? .developing }
        set { statusRaw = newValue.rawValue }
    }

    var importance: SkillImportance {
        get { SkillImportance(rawValue: importanceRaw) ?? .standard }
        set { importanceRaw = newValue.rawValue }
    }

    var requiredEnvironment: SkillEnvironment {
        get { SkillEnvironment(rawValue: requiredEnvironmentRaw) ?? .home }
        set { requiredEnvironmentRaw = newValue.rawValue }
    }

    // MARK: - Recency Helpers

    var daysSinceLastPracticed: Int? {
        guard let last = lastPracticed else { return nil }
        return Calendar.current.dateComponents([.day], from: last, to: Date()).day
    }

    var recencyLabel: String {
        guard let days = daysSinceLastPracticed else { return "Never practiced" }
        switch days {
        case 0:       return "Practiced today"
        case 1:       return "Yesterday"
        case 2...6:   return "\(days) days ago"
        case 7...13:  return "1 week ago"
        case 14...29: return "\(days / 7) weeks ago"
        default:      return "\(days / 30)+ months ago"
        }
    }

    var isCriticalOverdue: Bool {
        guard importance == .critical, let days = daysSinceLastPracticed else {
            return importance == .critical && lastPracticed == nil
        }
        return days >= 7
    }

    // MARK: - Init

    init(
        name: String,
        category: TrainingCategoryType,
        status: SkillStatus = .developing,
        importance: SkillImportance = .standard,
        requiredEnvironment: SkillEnvironment = .home,
        howToReminder: String = "",
        successMetric: String = "",
        lastPracticed: Date? = nil,
        isActive: Bool = true,
        isCustom: Bool = false,
        sortOrder: Int = 0,
        notes: String = "",
        minimumDurationMinutes: Int = 0
    ) {
        self.name                    = name
        self.categoryRaw             = category.rawValue
        self.statusRaw               = status.rawValue
        self.importanceRaw           = importance.rawValue
        self.requiredEnvironmentRaw  = requiredEnvironment.rawValue
        self.howToReminder           = howToReminder
        self.successMetric           = successMetric
        self.lastPracticed           = lastPracticed
        self.isActive                = isActive
        self.isCustom                = isCustom
        self.sortOrder               = sortOrder
        self.notes                   = notes
        self.minimumDurationMinutes  = minimumDurationMinutes
    }
}
