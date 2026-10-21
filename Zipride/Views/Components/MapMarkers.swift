import SwiftUI

/// Pulsing blue "você está aqui" dot at the fixed pickup coordinate.
struct PulsingDot: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.youBlue.opacity(0.25))
                .frame(width: 64, height: 64)
                .scaleEffect(pulse ? 1 : 0.3)
                .opacity(pulse ? 0 : 1)
            Circle()
                .fill(.white)
                .frame(width: 22, height: 22)
                .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
            Circle()
                .fill(Theme.youBlue)
                .frame(width: 15, height: 15)
        }
        .frame(width: 64, height: 64)
        .onAppear {
            withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) {
                pulse = true
            }
        }
        .accessibilityLabel("Você está aqui")
    }
}

/// Radar rings drawn on the pickup while the driver search runs.
struct RadarPulse: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { ring in
                Circle()
                    .stroke(Theme.accent.opacity(0.7), lineWidth: 2)
                    .frame(width: 200, height: 200)
                    .scaleEffect(animate ? 1 : 0.1)
                    .opacity(animate ? 0 : 0.9)
                    .animation(
                        .easeOut(duration: 2.1).repeatForever(autoreverses: false).delay(Double(ring) * 0.7),
                        value: animate
                    )
            }
            Circle()
                .fill(Theme.accent.opacity(0.18))
                .frame(width: 90, height: 90)
        }
        .frame(width: 200, height: 200)
        .allowsHitTesting(false)
        .onAppear { animate = true }
    }
}

/// Top-down vehicle used for traffic and for the matched driver.
struct VehicleMarker: View {
    var kind: VehicleKind = .car
    var heading: Double = 0
    var highlighted = false

    var body: some View {
        Group {
            if kind == .car {
                carBody
            } else {
                motoBody
            }
        }
        .rotationEffect(.degrees(heading))
        .shadow(color: .black.opacity(0.3), radius: highlighted ? 5 : 2, y: 1)
        .scaleEffect(highlighted ? 1.25 : 1)
    }

    private var carBody: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(highlighted ? Color.black : Color.white)
                .frame(width: 14, height: 26)
            RoundedRectangle(cornerRadius: 2)
                .fill(highlighted ? Theme.accent : Color.black.opacity(0.75))
                .frame(width: 10, height: 6)
                .offset(y: -5)
            RoundedRectangle(cornerRadius: 2)
                .fill(highlighted ? Theme.accent.opacity(0.7) : Color.black.opacity(0.5))
                .frame(width: 10, height: 4)
                .offset(y: 7)
        }
        .frame(width: 28, height: 30)
    }

    private var motoBody: some View {
        ZStack {
            Capsule()
                .fill(Color.black)
                .frame(width: 6, height: 20)
            Circle()
                .fill(Theme.accent)
                .frame(width: 9, height: 9)
                .offset(y: 1)
        }
        .frame(width: 24, height: 24)
    }
}

/// Pickup pin: black circle with a white core.
struct PickupPin: View {
    var body: some View {
        ZStack {
            Circle().fill(.black).frame(width: 20, height: 20)
            Circle().fill(.white).frame(width: 8, height: 8)
        }
        .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
    }
}

/// Destination pin: black square with a white core, with the place name above.
struct DestinationPin: View {
    let title: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.white, in: Capsule())
                .shadow(color: .black.opacity(0.15), radius: 4, y: 1)
            ZStack {
                RoundedRectangle(cornerRadius: 3).fill(.black).frame(width: 20, height: 20)
                RoundedRectangle(cornerRadius: 1).fill(.white).frame(width: 8, height: 8)
            }
            .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
        }
    }
}

/// Side-view car (or moto) drawing used in the ride list.
struct RideIllustration: View {
    let ride: RideType

    var body: some View {
        ZStack {
            if ride.kind == .moto {
                Image(systemName: "scooter")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(ride.bodyColor)
            } else {
                car
            }
        }
        .frame(width: 72, height: 44)
    }

    private var car: some View {
        ZStack(alignment: .bottom) {
            CarCabin()
                .fill(ride.bodyColor.opacity(0.85))
                .frame(width: 40, height: 16)
                .overlay(CarCabin().stroke(Color.black.opacity(0.15), lineWidth: 1))
                .offset(y: -18)
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(ride.bodyColor)
                .frame(width: 66, height: 18)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.black.opacity(0.15), lineWidth: 1)
                )
                .offset(y: -6)
            HStack(spacing: 30) {
                wheel
                wheel
            }
        }
    }

    private var wheel: some View {
        ZStack {
            Circle().fill(Color.black).frame(width: 14, height: 14)
            Circle().fill(Color(white: 0.7)).frame(width: 6, height: 6)
        }
    }
}

struct CarCabin: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.22, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.75, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
