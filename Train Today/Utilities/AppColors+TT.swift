// AppColors+TT.swift
// Train Today — Apps for Hope
// Developed by Tara Knight | @Hopetheservicedoodle
//
// Train Today-specific colors that are NOT part of the shared Apps for Hope
// canonical token set. These represent the app's unique training category
// color system and are intentionally separate from BrandColors.swift.

import SwiftUI

// MARK: - Train Today Category Colors

enum TTColor {
    // Training category palette — used as decorative background fills only.
    // Always pair with Color.textPrimary (dark charcoal) as the foreground.
    // Never use these directly as text or icon foreground colors.
    static let obedience    = Color("ttObedience")    // sage green — adaptive light/dark
    static let publicAccess = Color("ttPublicAccess") // dusty blue — adaptive light/dark
    static let task         = Color("ttTask")         // warm taupe — adaptive light/dark
    static let relationship = Color("ttRelationship") // soft lavender — adaptive light/dark

    static func forCategory(_ category: TrainingCategoryType) -> Color {
        switch category {
        case .obedience:    return TTColor.obedience
        case .publicAccess: return TTColor.publicAccess
        case .task:         return TTColor.task
        case .relationship: return TTColor.relationship
        }
    }
}
