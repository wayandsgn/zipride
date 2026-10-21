import SwiftUI

/// Original Zipride mark: a "Z" drawn as a route with a pickup dot at its start
/// and a destination square at its end, set in a rounded tile.
struct ZiprideMark: View {
    var size: CGFloat = 32

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(Color.black)
            ZRoute()
                .stroke(Theme.accent, style: StrokeStyle(lineWidth: size * 0.12, lineCap: .round, lineJoin: .round))
                .padding(size * 0.24)
            Circle()
                .fill(.white)
                .frame(width: size * 0.17, height: size * 0.17)
                .position(x: size * 0.25, y: size * 0.27)
            RoundedRectangle(cornerRadius: size * 0.03)
                .fill(Theme.sun)
                .frame(width: size * 0.15, height: size * 0.15)
                .position(x: size * 0.75, y: size * 0.73)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

/// The Z-shaped route stroke.
struct ZRoute: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: rect.minX + w * 0.02, y: rect.minY + h * 0.05))
        path.addLine(to: CGPoint(x: rect.minX + w * 0.95, y: rect.minY + h * 0.05))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + w * 0.05, y: rect.minY + h * 0.95),
            control: CGPoint(x: rect.minX + w * 0.55, y: rect.minY + h * 0.45)
        )
        path.addLine(to: CGPoint(x: rect.minX + w * 0.98, y: rect.minY + h * 0.95))
        return path
    }
}

/// Mark plus wordmark, used in headers.
struct ZiprideWordmark: View {
    var size: CGFloat = 30

    var body: some View {
        HStack(spacing: 8) {
            ZiprideMark(size: size)
            Text("zipride")
                .font(.system(size: size * 0.78, weight: .heavy, design: .rounded))
                .tracking(-0.5)
                .foregroundStyle(.black)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Zipride")
    }
}

#Preview {
    VStack(spacing: 24) {
        ZiprideMark(size: 120)
        ZiprideWordmark()
    }
}
