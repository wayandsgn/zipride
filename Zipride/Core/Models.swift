import Foundation
import CoreLocation
import SwiftUI

struct Place: Identifiable, Hashable {
    let id: String
    let name: String
    let address: String
    let symbol: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Road distance from the fixed pickup point, estimated from the straight line.
    var distanceKm: Double {
        Geo.roadDistanceKm(from: Fixtures.pickup, to: coordinate)
    }
}

enum VehicleKind: Hashable {
    case car
    case moto
}

struct RideType: Identifiable, Hashable {
    let id: String
    let name: String
    let tagline: String
    let seats: Int
    let etaMinutes: Int
    let basePrice: Double
    let perKm: Double
    let kind: VehicleKind
    let bodyColor: Color

    /// In-town trips (up to 3 km) cost the base price; longer trips add a per-km rate.
    func price(forKm km: Double) -> Double {
        let extra = max(0, km - 3) * perKm
        return ((basePrice + extra) * 10).rounded() / 10 + 0.0
    }
}

enum PaymentMethod: String, CaseIterable, Identifiable, Hashable {
    case pix
    case visa
    case cash

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pix: return "Pix"
        case .visa: return "Visa •••• 4242"
        case .cash: return "Dinheiro"
        }
    }

    var subtitle: String {
        switch self {
        case .pix: return "Pagamento na hora, sem taxa"
        case .visa: return "Crédito · vence 08/29"
        case .cash: return "Pague direto ao motorista"
        }
    }

    var symbol: String {
        switch self {
        case .pix: return "qrcode"
        case .visa: return "creditcard.fill"
        case .cash: return "banknote.fill"
        }
    }
}

struct Driver: Hashable {
    let name: String
    let rating: Double
    let trips: Int
    let car: String
    let plate: String
    let photoURL: URL
}

struct ChatMessage: Identifiable, Hashable {
    let id: Int
    let text: String
    let fromDriver: Bool
    let time: Date
}

struct Trip: Identifiable, Hashable {
    let id: String
    let date: Date
    let pickupName: String
    let destination: Place
    let rideName: String
    let driverName: String
    let payment: PaymentMethod
    let fare: Double
    let tip: Double
    let rating: Int
    let distanceKm: Double
    let durationMinutes: Int

    var total: Double { fare + tip }

    static func == (lhs: Trip, rhs: Trip) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct ServiceTile: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let rideTypeID: String?
}

struct AmbientVehicle: Identifiable {
    let id: Int
    let kind: VehicleKind
    let loop: [CLLocationCoordinate2D]
    let speed: Double
    let offset: Double
}
