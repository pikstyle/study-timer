//
//  AppTheme.swift
//  study-timer
//
//  Created by Claude Code
//

import SwiftUI

struct AppTheme {
    // MARK: - Palette de verts
    static let darkestGreen = Color(hex: "10451d")
    static let darkerGreen = Color(hex: "155d27")
    static let darkGreen = Color(hex: "1a7431")
    static let primaryGreen = Color(hex: "208b3a")
    static let mediumGreen = Color(hex: "25a244")
    static let brightGreen = Color(hex: "2dc653")
    static let lightGreen = Color(hex: "4ad66d")
    static let lighterGreen = Color(hex: "92e6a7")
    static let lightestGreen = Color(hex: "b7efc5")

    // MARK: - Base Colors
    static let deepBlack = Color(hex: "000000")
    static let pureBlack = Color.black
    static let pureWhite = Color.white

    // MARK: - UI Colors
    static func backgroundView() -> some View {
        LinearGradient(
            stops: [
                .init(color: Color.black, location: 0.0),
                .init(color: Color(hex: "0a1f0a"), location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Backgrounds & Glass
    static let cardBackground = Color.white.opacity(0.03)
    static let cardBackgroundGlass = Color.white.opacity(0.08)
    static let darkGlass = Color.black.opacity(0.3)

    // MARK: - Text Hierarchy (cohérent dans toute l'app)
    static let textTitle = Color.white                      // Titres principaux - toujours blanc pur
    static let textSubtitle = Color.white.opacity(0.7)      // Sous-titres - blanc atténué
    static let textLabel = Color.white.opacity(0.5)         // Labels et texte secondaire - gris clair
    static let textTertiary = Color.white.opacity(0.4)      // Texte tertiaire - gris plus foncé

    // Alias pour compatibilité
    static let textPrimary = textTitle
    static let textSecondary = textLabel

    // MARK: - Green Hierarchy (cohérent pour tous les accents verts)
    static let accentPrimary = primaryGreen                 // Vert principal - actions importantes
    static let accentSecondary = darkGreen                  // Vert secondaire - actions moins importantes
    static let accentSubtle = darkerGreen                   // Vert subtil - backgrounds, icônes

    // MARK: - Period Accent Colors (blanc avec variations subtiles)
    static let todayAccent = Color.white.opacity(0.9)        // Le plus clair
    static let weekAccent = Color.white.opacity(0.7)         // Légèrement moins
    static let monthAccent = Color.white.opacity(0.5)        // Encore moins

    // MARK: - Gradients
    static let greenGradient = LinearGradient(
        colors: [Color(hex: "25a244"), Color(hex: "2dc653")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let glowGradient = LinearGradient(
        colors: [Color(hex: "2dc653").opacity(0.4), Color(hex: "4ad66d").opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Shadow & Glow Effects
    static func greenGlow(radius: CGFloat = 20, opacity: Double = 0.6) -> some View {
        Color(hex: "2dc653").opacity(opacity).blur(radius: radius)
    }

    static func cardShadow() -> some View {
        Color.black.opacity(0.5)
    }
}

// MARK: - Grain Effect Modifier
struct GrainEffect: ViewModifier {
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: .white.opacity(0.01), location: 0),
                                .init(color: .clear, location: 0.5),
                                .init(color: .white.opacity(0.005), location: 1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)
                    .allowsHitTesting(false)
            )
    }
}

extension View {
    func grainEffect(opacity: Double = 0.05) -> some View {
        modifier(GrainEffect(opacity: opacity))
    }
}

// MARK: - Glassmorphism Card Modifier
struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 24
    var padding: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    // Background with transparency
                    AppTheme.cardBackgroundGlass

                    // Subtle gradient overlay
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.03),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 24, padding: CGFloat = 24) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, padding: padding))
    }
}

// MARK: - Glow Effect Modifier
struct GlowEffect: ViewModifier {
    var color: Color
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.4), radius: radius * 1.5, x: 0, y: 0)
            .shadow(color: color.opacity(0.2), radius: radius * 2, x: 0, y: 0)
    }
}

extension View {
    func glowEffect(color: Color = AppTheme.brightGreen, radius: CGFloat = 10) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
}

// MARK: - Primary Button Style (for important actions)
struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                isEnabled
                    ? AppTheme.greenGradient
                    : LinearGradient(colors: [AppTheme.cardBackgroundGlass], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isEnabled ? AppTheme.brightGreen.opacity(0.3) : Color.clear, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.5)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.3), value: isEnabled)
    }
}

extension View {
    func primaryButtonStyle(isEnabled: Bool = true) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled))
    }
}

// MARK: - Glass Control Button Style (for timer controls)
struct GlassControlButtonStyle: ButtonStyle {
    var accentColor: Color = AppTheme.primaryGreen
    var isActive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white.opacity(0.05))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isActive ? accentColor.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension View {
    func glassControlButton(accentColor: Color = AppTheme.primaryGreen, isActive: Bool = false) -> some View {
        self.buttonStyle(GlassControlButtonStyle(accentColor: accentColor, isActive: isActive))
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Pastel Colors for Categories
struct PastelColors {
    static let all: [PastelColor] = [
        PastelColor(name: "", hex: "301A4B", id: "purple"),    // Violet profond
        PastelColor(name: "", hex: "6DB1BF", id: "cyan"),      // Cyan
        PastelColor(name: "", hex: "FFEAEC", id: "cream"),     // Crème rosé
        PastelColor(name: "", hex: "F39A9D", id: "coral"),     // Corail
        PastelColor(name: "", hex: "3F6C51", id: "forest")     // Vert forêt
    ]

    static func color(for id: String) -> Color {
        if let pastelColor = all.first(where: { $0.id == id }) {
            return Color(hex: pastelColor.hex)
        }
        return Color(hex: all[0].hex) // Default to first color
    }
}

struct PastelColor: Identifiable, Codable, Equatable {
    let name: String
    let hex: String
    let id: String

    var color: Color {
        Color(hex: hex)
    }
}

// MARK: - Category Colors
struct CategoryColors {
    static func color(for categoryName: String) -> Color {
        // Essayer de trouver la catégorie dans le repository
        let categories = StudyRepository.shared.getAllCategories()
        if let category = categories.first(where: { $0.name == categoryName }) {
            return PastelColors.color(for: category.colorId)
        }

        // Sinon, retourner la première couleur par défaut
        return PastelColors.color(for: PastelColors.all[0].id)
    }

    // Fonction pour transférer la couleur d'une ancienne catégorie vers une nouvelle lors du renommage
    // Cette fonction n'est plus nécessaire car les couleurs sont stockées dans les catégories
    static func renameCategory(from oldName: String, to newName: String) {
        // No-op: colors are now stored in Category objects
    }
}
