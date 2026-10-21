import SwiftUI

/// Recibo for one trip, with "Pedir de novo" back into the ride flow.
struct ReceiptView: View {
    @Environment(RideStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var showHelp = false
    let trip: Trip

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                TripMiniMap(destination: trip.destination)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(BR.money(trip.total))
                        .font(.system(size: 34, weight: .heavy))
                    Text(BR.longDate(trip.date))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                route
                card {
                    line("Viagem \(trip.rideName)", BR.money(trip.fare))
                    line("Gorjeta", BR.money(trip.tip))
                    Divider()
                    line("Total", BR.money(trip.total), bold: true)
                    line("Pago com", trip.payment.title)
                }
                card {
                    line("Motorista", trip.driverName)
                    line("Sua avaliação", String(repeating: "★", count: trip.rating))
                    line("Distância", BR.km(trip.distanceKm))
                    line("Duração", "\(trip.durationMinutes) min")
                }

                Button("Pedir de novo") {
                    dismiss()
                    store.tab = .home
                    store.choose(trip.destination)
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier("rideAgain")

                Button("Preciso de ajuda com esta viagem") { showHelp = true }
                    .buttonStyle(SecondaryButtonStyle())
            }
            .padding(16)
        }
        .navigationTitle("Recibo")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Ajuda Zipride", isPresented: $showHelp) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Nosso suporte responde pelo chat em até 5 minutos, todos os dias.")
        }
    }

    private var route: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 3) {
                Circle().fill(.black).frame(width: 8, height: 8)
                Rectangle().fill(Color(.tertiaryLabel)).frame(width: 2, height: 30)
                Rectangle().fill(.black).frame(width: 8, height: 8)
            }
            .padding(.top, 6)
            VStack(alignment: .leading, spacing: 18) {
                Text(trip.pickupName).font(.system(size: 16, weight: .semibold))
                VStack(alignment: .leading, spacing: 1) {
                    Text(trip.destination.name).font(.system(size: 16, weight: .semibold))
                    Text(trip.destination.address).font(.footnote).foregroundStyle(.secondary)
                }
            }
        }
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 10) { content() }
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
    }

    private func line(_ title: String, _ value: String, bold: Bool = false) -> some View {
        HStack {
            Text(title).foregroundStyle(bold ? Color.primary : Color.secondary)
            Spacer()
            Text(value)
        }
        .font(.system(size: 16, weight: bold ? .bold : .regular))
    }
}
