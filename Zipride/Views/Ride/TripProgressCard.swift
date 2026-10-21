import SwiftUI

/// On the way to the destination: progress bar, ETA and trip details.
struct TripProgressCard: View {
    @Environment(RideStore.self) private var store
    @State private var showShare = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Indo para \(store.destination?.name ?? "")")
                        .font(.system(size: 20, weight: .bold))
                        .lineLimit(1)
                    Text("Chegada às \(BR.time(store.tripArrivalTime))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(store.tripRemainingMinutes) min")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Theme.accent)
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.snappy, value: store.tripRemainingMinutes)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.tertiarySystemFill))
                    Capsule()
                        .fill(Theme.accent)
                        .frame(width: max(8, proxy.size.width * store.tripProgress))
                }
            }
            .frame(height: 6)
            .accessibilityElement()
            .accessibilityLabel("Progresso da viagem")
            .accessibilityValue("\(Int(store.tripProgress * 100))%")
            .accessibilityIdentifier("tripProgress")

            HStack(spacing: 12) {
                RemoteAvatar(url: Fixtures.driver.photoURL, initials: "M", size: 40)
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(Fixtures.driver.name) · \(Fixtures.driver.plate)")
                        .font(.system(size: 15, weight: .semibold))
                    Text("\(store.selectedRide.name) · \(store.payment.title) · \(BR.money(store.price(of: store.selectedRide)))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    showShare = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color(.secondarySystemFill), in: Circle())
                }
                .buttonStyle(PressableStyle(scale: 0.9))
                .accessibilityLabel("Compartilhar viagem")
            }
        }
        .padding(18)
        .mapPanel()
        .accessibilityIdentifier("tripCard")
        .alert("Viagem compartilhada", isPresented: $showShare) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Seus contatos de confiança acompanham a rota até \(store.destination?.name ?? "o destino").")
        }
    }
}
