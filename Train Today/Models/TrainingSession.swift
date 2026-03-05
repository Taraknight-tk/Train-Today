// TrainingSession.swift
// Train Today — Session Log Model (immutable log records)
// Developed by Tara Knight | @Hopetheservicedoodle

import Foundation
import SwiftData

@Model
final class TrainingSession {

    // MARK: - Properties

    var date: Date
    var durationMinutes: Int
    var skillName: String               // denormalized for resilience if skill is later deleted
    var skillCategoryRaw: String        // denormalized category
    var ratingRaw: String
    var notes: String
    var isQuickWin: Bool                // flagged if started from Quick Win mode
    var isAdHoc: Bool = false           // flagged if logged retroactively via Quick Log; default gives SwiftData a migration value

    // MARK: - Typed Computed Properties

    var rating: SessionRating {
        get { SessionRating(rawValue: ratingRaw) ?? .okay }
        set { ratingRaw = newValue.rawValue }
    }

    var skillCategory: TrainingCategoryType {
        get { TrainingCategoryType(rawValue: skillCategoryRaw) ?? .obedience }
        set { skillCategoryRaw = newValue.rawValue }
    }

    var dateDisplay: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // MARK: - Init

    init(
        date: Date = .now,
        durationMinutes: Int,
        skillName: String,
        skillCategory: TrainingCategoryType,
        rating: SessionRating,
        notes: String = "",
        isQuickWin: Bool = false,
        isAdHoc: Bool = false
    ) {
        self.date               = date
        self.durationMinutes    = durationMinutes
        self.skillName          = skillName
        self.skillCategoryRaw   = skillCategory.rawValue
        self.ratingRaw          = rating.rawValue
        self.notes              = notes
        self.isQuickWin         = isQuickWin
        self.isAdHoc            = isAdHoc
    }
}
