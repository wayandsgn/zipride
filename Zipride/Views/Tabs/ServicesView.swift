import SwiftUI

/// Serviços: every way to ride in Itapipoca, each tile leads into the ride flow.
struct ServicesView: View {
    @Environment(RideStore.self) private var store
    @State private var showRental = false

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    banner
                    Text("Vá a qualquer lugar")
                        .font(.system(size: 20, weight: .bold))
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Fixtures.services) { tile in
                            Button { open(tile) } label: { ServiceCard(tile: tile) }
                                .buttonStyle(PressableStyle(scale: 0.96))
                                .accessibilityIdentifier("service_\(tile.id)")
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .navigationTitle("Serviços")
            .sheet(isPresented: $showRental) {
                RentalSheet()
                    .environment(store)
                    .presentationDetents([.medium])
                    .presentationCornerRadius(Theme.sheetRadius)
            }
        }
    }

    private func open(_ tile: ServiceTile) {
        if let rideID = tile.rideTypeID {
            store.openSearch(preferring: rideID)
        } else if tile.id == "agendar" {
            store.tab = .home
            store.showSchedule = true
        } else {
            showRental = true
        }
    }

    private var banner: some View {
        Button {
            store.openSearch(preferring: "moto")
        } label: {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: Fixtures.servicesBannerURL) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        LinearGradient(colors: [Theme.accent, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
                }
                .frame(height: 170)
                .clipped()
                LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .top, endPoint: .bottom)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Zipride Moto")
                        .font(.system(size: 22, weight: .heavy))
                    Text("Do Centro à Rodoviária a partir de \(BR.money(5.90))")
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(.white)
                .padding(16)
            }
            .frame(height: 170)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
        }
        .buttonStyle(PressableStyle(scale: 0.98))
        .accessibilityIdentifier("servicesBanner")
    }
}

private struct ServiceCard: View {
    let tile: ServiceTile

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: tile.symbol)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.black)
                .frame(width: 48, height: 48)
                .background(Theme.accentSoft, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(tile.title)
                    .font(.system(size: 17, weight: .bold))
                Text(tile.subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(.primary)
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
    }
}

/// Hourly rental: pick the hours, see the price, then choose where to start.
private struct RentalSheet: View {
    @Environment(RideStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var hours = 2

    private var price: Double { Double(hours) * 38.0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Motorista por hora")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 22)
            Text("Um Comfort fica com você para várias paradas: banco, feira, cartório.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Stepper(value: $hours, in: 1...8) {
                Text("\(hours) hora\(hours > 1 ? "s" : "") · \(BR.money(price))")
                    .font(.system(size: 17, weight: .semibold))
                    .contentTransition(.numericText())
            }
            .accessibilityIdentifier("rentalHours")
            Spacer(minLength: 0)
            Button("Escolher primeiro destino") {
                dismiss()
                store.openSearch(preferring: "comfort")
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier("rentalContinue")
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 12)
        .sensoryFeedback(.selection, trigger: hours)
        .animation(.snappy, value: hours)
    }
}
