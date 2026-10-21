import SwiftUI

/// Zipride palette: "verde-jangada" accent on a clean light UI with black primary actions.
enum Theme {
    static let accent = Color(red: 0.0, green: 0.62, blue: 0.53)
    static let accentSoft = Color(red: 0.0, green: 0.62, blue: 0.53).opacity(0.12)
    static let sun = Color(red: 1.0, green: 0.71, blue: 0.20)
    static let ink = Color.black
    static let surface = Color(.systemBackground)
    static let groupedSurface = Color(.secondarySystemBackground)
    static let hairline = Color.black.opacity(0.08)
    static let youBlue = Color(red: 0.16, green: 0.47, blue: 1.0)

    static let sheetRadius: CGFloat = 28
    static let cardRadius: CGFloat = 18
}

/// Press feedback used on every tappable surface.
struct PressableStyle: ButtonStyle {
    var scale: CGFloat = 0.97

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.snappy(duration: 0.18), value: configuration.isPressed)
    }
}

/// Big black call to action.
struct PrimaryButtonStyle: ButtonStyle {
    var tint: Color = .black

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(tint, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.snappy(duration: 0.18), value: configuration.isPressed)
    }
}

/// Grey secondary action.
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.18), value: configuration.isPressed)
    }
}

extension View {
    /// The floating white panel used for every bottom sheet on the map.
    func mapPanel() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: Theme.sheetRadius, style: .continuous)
                    .fill(Theme.surface)
                    .shadow(color: .black.opacity(0.12), radius: 24, y: 6)
            )
            .padding(.horizontal, 8)
    }
}
