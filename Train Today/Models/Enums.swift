// Enums.swift
// Train Today — Shared Enumerations
// Developed by Tara Knight | @Hopetheservicedoodle

import Foundation

// MARK: - Training Category Type

enum TrainingCategoryType: String, Codable, CaseIterable, Identifiable {
    case obedience    = "Basic Obedience"
    case publicAccess = "Public Access"
    case task         = "Task Training"
    case relationship = "Relationship / Play"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .obedience:    return "pawprint.fill"
        case .publicAccess: return "figure.walk"
        case .task:         return "star.fill"
        case .relationship: return "heart.fill"
        }
    }

    var shortName: String {
        switch self {
        case .obedience:    return "Obedience"
        case .publicAccess: return "Public Access"
        case .task:         return "Task"
        case .relationship: return "Relationship"
        }
    }

    var description: String {
        switch self {
        case .obedience:
            return "Foundation skills all service dogs need, regardless of task."
        case .publicAccess:
            return "Skills needed to navigate the world safely as a working team."
        case .task:
            return "Your dog's specific service tasks tied to your disability."
        case .relationship:
            return "Rest, connection, and relationship-building — valued as training."
        }
    }
}

// MARK: - Skill Status

enum SkillStatus: String, Codable, CaseIterable, Identifiable {
    case beginner    = "Beginner"
    case developing  = "Developing"
    case maintaining = "Maintaining"

    var id: String { rawValue }

    var sortPriority: Int {
        switch self {
        case .beginner:    return 0
        case .developing:  return 1
        case .maintaining: return 2
        }
    }

    var icon: String {
        switch self {
        case .beginner:    return "1.circle.fill"
        case .developing:  return "2.circle.fill"
        case .maintaining: return "checkmark.circle.fill"
        }
    }

    var description: String {
        switch self {
        case .beginner:
            return "Being introduced for the first time. Short, frequent sessions."
        case .developing:
            return "Partially trained. Needs consistent reinforcement."
        case .maintaining:
            return "Reliable but requires periodic practice to prevent regression."
        }
    }
}

// MARK: - Skill Importance

enum SkillImportance: String, Codable, CaseIterable, Identifiable {
    case critical = "Critical"
    case standard = "Standard"
    case low      = "Low"

    var id: String { rawValue }

    /// Lower number = higher priority in scheduling
    var sortPriority: Int {
        switch self {
        case .critical: return 0
        case .standard: return 1
        case .low:      return 2
        }
    }

    var icon: String {
        switch self {
        case .critical: return "exclamationmark.triangle.fill"
        case .standard: return "minus.circle.fill"
        case .low:      return "arrow.down.circle.fill"
        }
    }

    var description: String {
        switch self {
        case .critical:
            return "Must be practiced regularly. Always surfaces in the plan."
        case .standard:
            return "Normal scheduling priority. Follows recency and status logic."
        case .low:
            return "Only surfaces when higher-importance skills are covered."
        }
    }
}

// MARK: - Required Environment

enum SkillEnvironment: String, Codable, CaseIterable, Identifiable {
    case home         = "Home"
    case neighborhood = "Neighborhood"
    case store        = "Pet-Friendly Store"
    case fullPublic   = "Full Public Access"

    var id: String { rawValue }

    /// Returns true if the skill can be practiced in the given available environment
    func isAvailableIn(_ available: SkillEnvironment) -> Bool {
        switch available {
        case .home:         return self == .home
        case .neighborhood: return self == .home || self == .neighborhood
        case .store:        return self == .home || self == .neighborhood || self == .store
        case .fullPublic:   return true
        }
    }

    var icon: String {
        switch self {
        case .home:         return "house.fill"
        case .neighborhood: return "map.fill"
        case .store:        return "cart.fill"
        case .fullPublic:   return "building.2.fill"
        }
    }
}

// MARK: - Session Duration

enum SessionDuration: Int, Codable, CaseIterable, Identifiable {
    case fiveMin   = 5
    case tenMin    = 10
    case twentyMin = 20
    case thirtyPlus = 30

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .fiveMin:    return "5 min"
        case .tenMin:     return "10 min"
        case .twentyMin:  return "20 min"
        case .thirtyPlus: return "30+ min"
        }
    }

    /// Maximum number of skills to include in a session plan
    var maxSkills: Int {
        switch self {
        case .fiveMin:    return 1
        case .tenMin:     return 2
        case .twentyMin:  return 3
        case .thirtyPlus: return 4
        }
    }

    /// Suggested duration per skill in minutes
    var minutesPerSkill: Int {
        switch self {
        case .fiveMin:    return 5
        case .tenMin:     return 5
        case .twentyMin:  return 7
        case .thirtyPlus: return 10
        }
    }
}

// MARK: - Energy Level

enum EnergyLevel: String, Codable, CaseIterable, Identifiable {
    case low    = "Low"
    case medium = "Medium"
    case high   = "High"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .low:    return "🌿"
        case .medium: return "⚡️"
        case .high:   return "🔥"
        }
    }

    var description: String {
        switch self {
        case .low:
            return "Easy maintenance wins. Gentle reps of known skills."
        case .medium:
            return "Active development. Working on improving skills."
        case .high:
            return "New skill intro or challenging environments."
        }
    }
}

// MARK: - Session Rating

enum SessionRating: String, Codable, CaseIterable, Identifiable {
    case great   = "Great"
    case okay    = "Okay"
    case tough   = "Tough Day"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .great: return "🌟"
        case .okay:  return "👍"
        case .tough: return "💙"
        }
    }

    var icon: String {
        switch self {
        case .great: return "star.fill"
        case .okay:  return "hand.thumbsup.fill"
        case .tough: return "heart.fill"
        }
    }
}

// MARK: - Weekday

enum Weekday: Int, Codable, CaseIterable, Identifiable {
    case sunday    = 1
    case monday    = 2
    case tuesday   = 3
    case wednesday = 4
    case thursday  = 5
    case friday    = 6
    case saturday  = 7

    var id: Int { rawValue }

    var shortName: String {
        switch self {
        case .sunday:    return "Sun"
        case .monday:    return "Mon"
        case .tuesday:   return "Tue"
        case .wednesday: return "Wed"
        case .thursday:  return "Thu"
        case .friday:    return "Fri"
        case .saturday:  return "Sat"
        }
    }

    var fullName: String {
        switch self {
        case .sunday:    return "Sunday"
        case .monday:    return "Monday"
        case .tuesday:   return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday:  return "Thursday"
        case .friday:    return "Friday"
        case .saturday:  return "Saturday"
        }
    }

    static var today: Weekday {
        let weekdayNumber = Calendar.current.component(.weekday, from: Date())
        return Weekday(rawValue: weekdayNumber) ?? .monday
    }
}
