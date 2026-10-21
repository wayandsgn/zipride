import Foundation
import CoreLocation
import MapKit

/// Asks MapKit for a driving route and falls back to a fixture curve if it is slow or offline.
enum RouteService {
    static func route(from a: CLLocationCoordinate2D, to b: CLLocationCoordinate2D) async -> [CLLocationCoordinate2D] {
        let fallback = Geo.fallbackRoute(from: a, to: b)
        let result: [CLLocationCoordinate2D]? = await withTaskGroup(of: [CLLocationCoordinate2D]?.self) { group in
            group.addTask {
                await directions(from: a, to: b)
            }
            group.addTask {
                try? await Task.sleep(for: .milliseconds(2200))
                return nil
            }
            let first = await group.next()
            group.cancelAll()
            return first ?? nil
        }
        guard let coordinates = result, coordinates.count > 1 else { return fallback }
        return coordinates
    }

    private static func directions(from a: CLLocationCoordinate2D, to b: CLLocationCoordinate2D) async -> [CLLocationCoordinate2D]? {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: a))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: b))
        request.transportType = .automobile
        do {
            let response = try await MKDirections(request: request).calculate()
            guard let polyline = response.routes.first?.polyline else { return nil }
            let count = polyline.pointCount
            guard count > 1 else { return nil }
            var coordinates = [CLLocationCoordinate2D](repeating: CLLocationCoordinate2D(), count: count)
            polyline.getCoordinates(&coordinates, range: NSRange(location: 0, length: count))
            return coordinates
        } catch {
            return nil
        }
    }
}
