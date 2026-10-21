import SwiftUI

/// Shown for ~3 s while the radar pulses on the pickup point.
struct FindingDriverCard: View {
    @Environment(RideStore.self) private var store
    @State private var sweep = false

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Text("Procurando seu motorista")
                    .font(.system(size: 20, weight: .bold))
                Text("Buscando \(store.selectedRide.name) perto da Praça da Matriz")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)

            searchBar

            HStack(spacing: 12) {
                RideIllustration(ride: store.selectedRide)
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.destination?.name ?? "")
                        .font(.system(size: 16, weight: .semibold))
                    Text("\(store.payment.title) · \(BR.money(store.price(of: store.selectedRide)))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Button("Cancelar") { store.cancelRide() }
                .buttonStyle(SecondaryButtonStyle())
                .accessibilityIdentifier("cancelSearch")
        }
        .padding(18)
        .mapPanel()
        .accessibilityIdentifier("findingDriver")
        .onAppear { sweep = true }
    }

    private var searchBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Color(.tertiarySystemFill))
                Capsule()
                    .fill(Theme.accent)
                    .frame(width: proxy.size.width * 0.35)
                    .offset(x: sweep ? proxy.size.width * 0.65 : 0)
                    .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: sweep)
            }
        }
        .frame(height: 5)
        .clipShape(Capsule())
    }
}
