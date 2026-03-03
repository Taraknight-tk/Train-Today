// Theme.swift
// Train Today — Brand Colors, Typography & Style Constants
// Developed by Tara Knight | @Hopetheservicedoodle

import SwiftUI

// MARK: - Brand Colors

extension Color {
    /// Warm cream — primary background
    static let ttBackground      = Color(hex: "#FAF7F2")
    /// Muted sage green — primary brand color, buttons, accents
    static let ttPrimary         = Color(hex: "#7C9A7E")
    /// Lighter sage — secondary fills, selected states
    static let ttPrimaryLight    = Color(hex: "#B2C9B4")
    /// Warm taupe — secondary UI elements, card borders
    static let ttSecondary       = Color(hex: "#C4A882")
    /// Soft taupe tint — card backgrounds, dividers
    static let ttSecondaryLight  = Color(hex: "#EDE5D8")
    /// Near-black — body text, primary labels
    static let ttText            = Color(hex: "#1C1C1E")
    /// Mid-gray — secondary labels, placeholders
    static let ttTextSecondary   = Color(hex: "#6B6B6B")
    /// Warm white — surface cards, modals
    static let ttSurface         = Color(hex: "#FFFFFF")
    /// Soft warm red — error states, destructive actions
    static let ttError           = Color(hex: "#C0392B")
    /// Warm amber — warning, streak nudge
    static let ttWarning         = Color(hex: "#D4A017")
    /// Soft green confirmation
    static let ttSuccess         = Color(hex: "#4A7C59")

    // Dark mode variants are handled automatically via adaptive Color assets.
    // For a production build, these should be migrated to an Asset Catalog
    // with Light / Dark appearances defined.
}

// MARK: - Category Colors

extension Color {
    static let ttObedience       = Color(hex: "#7C9A7E")   // Sage green
    static let ttPublicAccess    = Color(hex: "#7A9CB8")   // Dusty blue
    static let ttTask            = Color(hex: "#C4A882")   // Warm taupe
    static let ttRelationship    = Color(hex: "#B89AC4")   // Soft lavender

    static func forCategory(_ category: TrainingCategoryType) -> Color {
        switch category {
        case .obedience:    return .ttObedience
        case .publicAccess: return .ttPublicAccess
        case .task:         return .ttTask
        case .relationship: return .ttRelationship
        }
    }
}

// MARK: - Typography

struct TTFont {
    /// Large display title — onboarding headers, session plan headline
    static let display      = Font.system(size: 28, weight: .bold, design: .rounded)
    /// Screen titles
    static let title        = Font.system(size: 22, weight: .semibold, design: .rounded)
    /// Card titles, section headers
    static let headline     = Font.system(size: 17, weight: .semibold, design: .rounded)
    /// Primary body text
    static let body         = Font.system(size: 16, weight: .regular, design: .rounded)
    /// Supporting body, descriptions
    static let bodySmall    = Font.system(size: 14, weight: .regular, design: .rounded)
    /// Captions, metadata, timestamps
    static let caption      = Font.system(size: 12, weight: .regular, design: .rounded)
    /// Pill labels, tags
    static let tag          = Font.system(size: 11, weight: .medium, design: .rounded)
}

// MARK: - Spacing

struct TTSpacing {
    static let xxs:  CGFloat = 4
    static let xs:   CGFloat = 8
    static let sm:   CGFloat = 12
    static let md:   CGFloat = 16
    static let lg:   CGFloat = 24
    static let xl:   CGFloat = 32
    static let xxl:  CGFloat = 48
}

// MARK: - Corner Radius

struct TTRadius {
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 24
    static let pill: CGFloat = 999
}

// MARK: - Shadow

extension View {
    func ttCardShadow() -> some View {
        self.shadow(color: Color.ttText.opacity(0.06), radius: 8, x: 0, y: 2)
    }
    func ttElevatedShadow() -> some View {
        self.shadow(color: Color.ttText.opacity(0.10), radius: 16, x: 0, y: 4)
    }
}

// MARK: - Reusable Card Style

struct TTCardModifier: ViewModifier {
    var padding: CGFloat = TTSpacing.md

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.ttSurface)
            .clipShape(RoundedRectangle(cornerRadius: TTRadius.lg))
            .ttCardShadow()
    }
}

extension View {
    func ttCard(padding: CGFloat = TTSpacing.md) -> some View {
        modifier(TTCardModifier(padding: padding))
    }
}

// MARK: - Primary Button Style

struct TTPrimaryButtonStyle: ButtonStyle {
    var isDestructive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TTFont.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, TTSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: TTRadius.md)
                    .fill(isDestructive ? Color.ttError : Color.ttPrimary)
                    .opacity(configuration.isPressed ? 0.85 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct TTSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TTFont.headline)
            .foregroundColor(.ttPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, TTSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: TTRadius.md)
                    .strokeBorder(Color.ttPrimary, lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Hex Color Helper

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
