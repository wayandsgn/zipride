import Foundation
import CoreLocation
import MapKit

/// Small geometry helpers for moving markers along polylines and framing routes.
enum Geo {
    static func meters(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> Double {
        let la = CLLocation(latitude: a.latitude, longitude: a.longitude)
        let lb = CLLocation(latitude: b.latitude, longitude: b.longitude)
        return la.distance(from: lb)
    }

    /// Roads are never straight: 1.3x the crow-flies distance is a good town estimate.
    static func roadDistanceKm(from a: CLLocationCoordinate2D, to b: CLLocationCoordinate2D) -> Double {
        let km = meters(a, b) * 1.3 / 1000
        return max(0.4, km)
    }

    static func length(_ path: [CLLocationCoordinate2D]) -> Double {
        guard path.count > 1 else { return 0 }
        var total = 0.0
        for index in 1..<path.count {
            total += meters(path[index - 1], path[index])
        }
        return total
    }

    /// Position at a 0...1 fraction of the path's length.
    static func point(on path: [CLLocationCoordinate2D], at fraction: Double) -> CLLocationCoordinate2D {
        guard let first = path.first else { return Fixtures.pickup }
        guard path.count > 1 else { return first }
        let clamped = min(max(fraction, 0), 1)
        let target = length(path) * clamped
        var walked = 0.0
        for index in 1..<path.count {
            let a = path[index - 1]
            let b = path[index]
            let segment = meters(a, b)
            if walked + segment >= target, segment > 0 {
                let t = (target - walked) / segment
                return interpolate(a, b, t)
            }
            walked += segment
        }
        return path[path.count - 1]
    }

    /// Prefix of the path up to a 0...1 fraction, ending exactly at that point.
    static func prefix(of path: [CLLocationCoordinate2D], fraction: Double) -> [CLLocationCoordinate2D] {
        guard path.count > 1 else { return path }
        if fraction >= 1 { return path }
        let target = length(path) * max(fraction, 0)
        var result: [CLLocationCoordinate2D] = [path[0]]
        var walked = 0.0
        for index in 1..<path.count {
            let a = path[index - 1]
            let b = path[index]
            let segment = meters(a, b)
            if walked + segment >= target {
                let t = segment > 0 ? (target - walked) / segment : 0
                result.append(interpolate(a, b, t))
                return result
            }
            result.append(b)
            walked += segment
        }
        return result
    }

    /// Compass bearing in degrees for the marker heading at a fraction of the path.
    static func heading(on path: [CLLocationCoordinate2D], at fraction: Double) -> Double {
        let a = point(on: path, at: max(0, fraction - 0.01))
        let b = point(on: path, at: min(1, fraction + 0.01))
        return bearing(from: a, to: b)
    }

    static func bearing(from a: CLLocationCoordinate2D, to b: CLLocationCoordinate2D) -> Double {
        let lat1 = a.latitude * .pi / 180
        let lat2 = b.latitude * .pi / 180
        let dLon = (b.longitude - a.longitude) * .pi / 180
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let degrees = atan2(y, x) * 180 / .pi
        return (degrees + 360).truncatingRemainder(dividingBy: 360)
    }

    static func interpolate(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D, _ t: Double) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: a.latitude + (b.latitude - a.latitude) * t,
            longitude: a.longitude + (b.longitude - a.longitude) * t
        )
    }

    /// A gently curved fixture route used when MKDirections is unavailable.
    static func fallbackRoute(from a: CLLocationCoordinate2D, to b: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
        let midLat = (a.latitude + b.latitude) / 2
        let midLon = (a.longitude + b.longitude) / 2
        let dLat = b.latitude - a.latitude
        let dLon = b.longitude - a.longitude
        let control = CLLocationCoordinate2D(latitude: midLat - dLon * 0.18, longitude: midLon + dLat * 0.18)
        var points: [CLLocationCoordinate2D] = []
        let steps = 48
        for step in 0...steps {
            let t = Double(step) / Double(steps)
            let u = 1 - t
            let lat = u * u * a.latitude + 2 * u * t * control.latitude + t * t * b.latitude
            let lon = u * u * a.longitude + 2 * u * t * control.longitude + t * t * b.longitude
            points.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }
        return points
    }

    /// Map rect that fits every point, with extra room at the bottom for the sheet.
    static func fittingRect(_ points: [CLLocationCoordinate2D], bottomShare: Double = 0.5) -> MKMapRect {
        var rect = MKMapRect.null
        for coordinate in points {
            let point = MKMapPoint(coordinate)
            let tiny = MKMapRect(x: point.x, y: point.y, width: 1, height: 1)
            rect = rect.union(tiny)
        }
        let side = max(rect.width, rect.height, 1200)
        let padded = rect.insetBy(dx: -side * 0.22, dy: -side * 0.22)
        let extraHeight = padded.height * bottomShare / (1 - bottomShare)
        let topRoom = padded.height * 0.12
        return MKMapRect(
            x: padded.minX,
            y: padded.minY - topRoom,
            width: padded.width,
            height: padded.height + extraHeight + topRoom
        )
    }
}
