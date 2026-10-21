import SwiftUI
import MapKit

/// The muted map behind every Home state: traffic, you-are-here dot, route and driver.
struct HomeMap: View {
    @Environment(RideStore.self) private var store

    var body: some View {
        @Bindable var store = store
        Map(position: $store.camera, interactionModes: [.pan, .zoom]) {
            if store.phase == .idle {
                ForEach(Fixtures.ambientVehicles) { vehicle in
                    Annotation("", coordinate: store.position(of: vehicle), anchor: .center) {
                        VehicleMarker(kind: vehicle.kind, heading: store.heading(of: vehicle))
                    }
                    .annotationTitles(.hidden)
                }
            }

            if store.visibleRoute.count > 1 {
                MapPolyline(coordinates: store.visibleRoute)
                    .stroke(.black, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
            }

            routeEnds
            driver
        }
        .mapStyle(.standard(emphasis: .muted, pointsOfInterest: .excludingAll))
        .mapControlVisibility(.hidden)
    }

    @MapContentBuilder
    private var routeEnds: some MapContent {
        if store.phase == .idle {
            Annotation("Você está aqui", coordinate: Fixtures.pickup, anchor: .center) {
                PulsingDot()
            }
            .annotationTitles(.hidden)
        } else {
            Annotation("Embarque", coordinate: Fixtures.pickup, anchor: .center) {
                ZStack {
                    if store.phase == .matching { RadarPulse() }
                    PickupPin()
                }
            }
            .annotationTitles(.hidden)
        }

        if let destination = store.destination {
            Annotation(destination.name, coordinate: destination.coordinate, anchor: .bottom) {
                DestinationPin(title: destination.name)
            }
            .annotationTitles(.hidden)
        }
    }

    @MapContentBuilder
    private var driver: some MapContent {
        if let coordinate = store.driverCoordinate {
            Annotation(Fixtures.driver.name, coordinate: coordinate, anchor: .center) {
                VehicleMarker(kind: store.selectedRide.kind, heading: store.driverHeading, highlighted: true)
            }
            .annotationTitles(.hidden)
        }
    }
}
