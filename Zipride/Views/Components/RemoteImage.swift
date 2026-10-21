import SwiftUI

/// AsyncImage with a soft placeholder (initials on a tinted circle) so nothing is ever blank.
struct RemoteAvatar: View {
    let url: URL
    let initials: String
    var size: CGFloat = 56

    var body: some View {
        AsyncImage(url: url, transaction: Transaction(animation: .easeOut(duration: 0.25))) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
            default:
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(.white, lineWidth: 2))
        .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
    }

    private var placeholder: some View {
        ZStack {
            Circle().fill(Theme.accentSoft)
            Text(initials)
                .font(.system(size: size * 0.36, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.accent)
        }
    }
}
