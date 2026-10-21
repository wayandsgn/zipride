import SwiftUI
import MapKit

/// Atividade: past trips with a mini route map; each opens its receipt.
struct ActivityView: View {
    @Environment(RideStore.self) private var store

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    Text("Viagens anteriores")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    ForEach(store.trips) { trip in
                        NavigationLink(value: trip) {
                            TripRow(trip: trip, isNew: trip.id == store.lastCompletedTrip?.id)
                        }
                        .buttonStyle(PressableStyle(scale: 0.98))
                        .accessibilityIdentifier("trip_\(trip.id)")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                .animation(.spring(duration: 0.32), value: store.trips.count)
            }
            .navigationTitle("Atividade")
            .navigationDestination(for: Trip.self) { trip in
                ReceiptView(trip: trip)
            }
        }
    }
}

private struct TripRow: View {
    let trip: Trip
    let isNew: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TripMiniMap(destination: trip.destination)
                .frame(height: 120)
                .overlay(alignment: .topLeading) {
                    if isNew {
                        Text("Nova")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Theme.accent, in: Capsule())
                            .padding(10)
                    }
                }
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(trip.destination.name)
                        .font(.system(size: 17, weight: .bold))
                    Text("\(BR.shortDate(trip.date)) · \(BR.time(trip.date)) · \(trip.rideName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text(BR.money(trip.total))
                        .font(.system(size: 17, weight: .bold))
                    Label("Recibo", systemImage: "chevron.right")
                        .labelStyle(TrailingIconLabelStyle())
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                }
            }
            .foregroundStyle(.primary)
            .padding(14)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
    }
}

/// Static, non-interactive map of the route from the pickup to a destination.
struct TripMiniMap: View {
    let destination: Place

    private var route: [CLLocationCoordinate2D] {
        Geo.fallbackRoute(from: Fixtures.pickup, to: destination.coordinate)
    }

    var body: some View {
        Map(initialPosition: .rect(Geo.fittingRect(route, bottomShare: 0.1)), interactionModes: []) {
            MapPolyline(coordinates: route)
                .stroke(.black, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            Annotation("", coordinate: Fixtures.pickup, anchor: .center) {
                Circle().fill(.black).frame(width: 10, height: 10)
                    .overlay(Circle().fill(.white).frame(width: 4, height: 4))
            }
            .annotationTitles(.hidden)
            Annotation("", coordinate: destination.coordinate, anchor: .center) {
                RoundedRectangle(cornerRadius: 2).fill(.black).frame(width: 10, height: 10)
                    .overlay(RoundedRectangle(cornerRadius: 1).fill(.white).frame(width: 4, height: 4))
            }
            .annotationTitles(.hidden)
        }
        .mapStyle(.standard(emphasis: .muted, pointsOfInterest: .excludingAll))
        .mapControlVisibility(.hidden)
        .allowsHitTesting(false)
    }
}

struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 3) {
            configuration.title
            configuration.icon
        }
    }
}
