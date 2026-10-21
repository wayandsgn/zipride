import SwiftUI

/// Resting panel: "Para onde?", saved places, shortcuts and recent trips.
struct HomeSheet: View {
    @Environment(RideStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Capsule()
                .fill(Color(.tertiaryLabel))
                .frame(width: 36, height: 5)
                .frame(maxWidth: .infinity)

            Text(greeting)
                .font(.system(size: 22, weight: .bold))

            WhereToPill()
            shortcuts
            savedPlaces
            recents
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
        .padding(.bottom, 18)
        .mapPanel()
    }

    private var greeting: String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = BR.timeZone
        let hour = calendar.component(.hour, from: Date())
        let salute = hour < 12 ? "Bom dia" : (hour < 18 ? "Boa tarde" : "Boa noite")
        return "\(salute), \(Fixtures.userFirstName)"
    }

    private var shortcuts: some View {
        HStack(spacing: 10) {
            ShortcutTile(title: "Viagem", symbol: "car.fill") { store.openSearch(preferring: "x") }
            ShortcutTile(title: "Moto", symbol: "scooter") { store.openSearch(preferring: "moto") }
            ShortcutTile(title: "Agendar", symbol: "calendar.badge.clock") { store.showSchedule = true }
            ShortcutTile(title: "Entrega", symbol: "shippingbox.fill") { store.openSearch(preferring: "moto") }
        }
    }

    private var savedPlaces: some View {
        HStack(spacing: 10) {
            SavedPlaceChip(place: Fixtures.home, symbol: "house.fill")
            SavedPlaceChip(place: Fixtures.work, symbol: "briefcase.fill")
        }
    }

    private var recents: some View {
        VStack(spacing: 0) {
            ForEach(Fixtures.recents) { place in
                Button {
                    store.choose(place)
                } label: {
                    PlaceRow(place: place, symbol: "clock.arrow.circlepath")
                }
                .buttonStyle(PressableStyle())
                .accessibilityIdentifier("recent_\(place.id)")
                if place.id != Fixtures.recents.last?.id {
                    Divider().padding(.leading, 52)
                }
            }
        }
    }
}

/// The big grey "Para onde?" search pill with the schedule chip.
private struct WhereToPill: View {
    @Environment(RideStore.self) private var store

    var body: some View {
        HStack(spacing: 0) {
            Button {
                store.openSearch()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .bold))
                    Text("Para onde?")
                        .font(.system(size: 19, weight: .semibold))
                    Spacer(minLength: 0)
                }
                .foregroundStyle(.primary)
                .padding(.leading, 18)
                .frame(height: 56)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressableStyle())
            .accessibilityIdentifier("whereTo")

            Button {
                store.showSchedule = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                    Text(store.scheduleLabel)
                    Image(systemName: "chevron.down").font(.caption.weight(.bold))
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
                .frame(height: 38)
                .background(.white, in: Capsule())
            }
            .buttonStyle(PressableStyle(scale: 0.94))
            .padding(.trailing, 9)
            .accessibilityIdentifier("scheduleChip")
        }
        .background(Color(.secondarySystemFill), in: Capsule())
    }
}

private struct ShortcutTile: View {
    let title: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(height: 26)
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(Color(.secondarySystemFill), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(PressableStyle(scale: 0.94))
        .accessibilityIdentifier("shortcut_\(title)")
    }
}

private struct SavedPlaceChip: View {
    @Environment(RideStore.self) private var store
    let place: Place
    let symbol: String

    var body: some View {
        Button {
            store.choose(place)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(Theme.accent, in: Circle())
                VStack(alignment: .leading, spacing: 1) {
                    Text(place.name).font(.system(size: 15, weight: .semibold))
                    Text(place.address).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .foregroundStyle(.primary)
            .padding(10)
            .frame(maxWidth: .infinity)
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Theme.hairline, lineWidth: 1))
        }
        .buttonStyle(PressableStyle())
        .accessibilityIdentifier("saved_\(place.id)")
    }
}

/// One place in a list: icon, name, address and road distance.
struct PlaceRow: View {
    let place: Place
    var symbol: String? = nil

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol ?? place.symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 38, height: 38)
                .background(Color(.secondarySystemFill), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(place.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(place.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            Text(BR.km(place.distanceKm))
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
