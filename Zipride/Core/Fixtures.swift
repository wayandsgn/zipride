import Foundation
import CoreLocation
import SwiftUI

/// Deterministic demo data. Every launch starts from exactly this state.
enum Fixtures {
    // MARK: - Map

    /// Fixed "você está aqui" point beside the Igreja Matriz, Centro de Itapipoca.
    static let pickup = CLLocationCoordinate2D(latitude: -3.4944, longitude: -39.5786)
    static let pickupName = "Local atual"
    static let pickupAddress = "Praça da Matriz, Centro · Itapipoca"
    static let cityName = "Itapipoca, CE"

    // MARK: - People

    static let userName = "Davi Filipe"
    static let userFirstName = "Davi"
    static let userRating = 4.89
    static let userTrips = 128
    static let userPhone = "(88) 99812-4417"
    static let userEmail = "davi.filipe@zipride.app"
    static let userPhotoURL = image("photo-1507003211169-0a1dd7228f2d")

    static let driver = Driver(
        name: "Marcos",
        rating: 4.92,
        trips: 2341,
        car: "Chevrolet Onix · Prata",
        plate: "PNX4E21",
        photoURL: image("photo-1500648767791-00dcc994a43e")
    )

    static let quickReplies = ["Estou a caminho", "Já estou no ponto de embarque"]

    static let driverReplies = [
        "Beleza, já tô chegando, visse! 👍",
        "Show! Tô pertinho da Praça da Matriz, um minutinho.",
        "Tranquilo, te espero aqui na frente."
    ]

    // MARK: - Places

    static let home = Place(
        id: "casa", name: "Casa", address: "Rua Anastácio Braga, 1458 – Centro",
        symbol: "house.fill", latitude: -3.4921, longitude: -39.5753
    )

    static let work = Place(
        id: "trabalho", name: "Trabalho", address: "IFCE Campus Itapipoca – Ladeira",
        symbol: "briefcase.fill", latitude: -3.4797, longitude: -39.5703
    )

    static let places: [Place] = [
        Place(id: "matriz", name: "Igreja Matriz de N. Sra. das Mercês", address: "Praça da Matriz – Centro",
              symbol: "building.columns.fill", latitude: -3.4951, longitude: -39.5795),
        Place(id: "praca", name: "Praça da Matriz", address: "Centro – Itapipoca",
              symbol: "tree.fill", latitude: -3.4957, longitude: -39.5776),
        Place(id: "mercado", name: "Mercado Público", address: "Rua Coronel Raimundo Matos – Centro",
              symbol: "basket.fill", latitude: -3.4926, longitude: -39.5809),
        Place(id: "rodoviaria", name: "Rodoviária de Itapipoca", address: "Av. Perimetral – Fazendinha",
              symbol: "bus.fill", latitude: -3.5034, longitude: -39.5840),
        Place(id: "ifce", name: "IFCE Campus Itapipoca", address: "Ladeira – Itapipoca",
              symbol: "graduationcap.fill", latitude: -3.4797, longitude: -39.5703),
        Place(id: "facedi", name: "FACEDI / UECE", address: "Av. Monsenhor Tabosa – Boa Vista",
              symbol: "book.fill", latitude: -3.5012, longitude: -39.5917),
        Place(id: "estacao", name: "Estação Ferroviária", address: "Rua da Estação – Centro",
              symbol: "tram.fill", latitude: -3.4987, longitude: -39.5752),
        Place(id: "acude", name: "Açude Poço Verde", address: "Estrada do Poço Verde – Zona rural",
              symbol: "drop.fill", latitude: -3.4602, longitude: -39.6125),
        Place(id: "baleia", name: "Praia da Baleia", address: "Distrito da Baleia – Litoral",
              symbol: "beach.umbrella.fill", latitude: -3.2391, longitude: -39.6742),
        Place(id: "pedrinhas", name: "Praia de Pedrinhas", address: "Litoral de Itapipoca",
              symbol: "water.waves", latitude: -3.2655, longitude: -39.6198),
        Place(id: "arapari", name: "Distrito de Arapari", address: "Arapari – Itapipoca",
              symbol: "house.lodge.fill", latitude: -3.3786, longitude: -39.6301),
        Place(id: "aeroporto", name: "Aeroporto de Fortaleza", address: "Av. Senador Carlos Jereissati – Fortaleza",
              symbol: "airplane", latitude: -3.7763, longitude: -38.5326)
    ]

    static func place(_ id: String) -> Place {
        if id == home.id { return home }
        if id == work.id { return work }
        return places.first { $0.id == id } ?? places[0]
    }

    static let recentIDs = ["mercado", "rodoviaria", "baleia"]
    static var recents: [Place] { recentIDs.map(place) }

    static let suggestionIDs = ["matriz", "praca", "estacao", "facedi", "acude", "pedrinhas"]
    static var suggestions: [Place] { suggestionIDs.map(place) }

    // MARK: - Rides

    static let rideTypes: [RideType] = [
        RideType(id: "x", name: "ZiprideX", tagline: "Viagens do dia a dia", seats: 4, etaMinutes: 3,
                 basePrice: 9.90, perKm: 1.45, kind: .car, bodyColor: Color(white: 0.92)),
        RideType(id: "moto", name: "Moto", tagline: "Chega mais rápido", seats: 1, etaMinutes: 2,
                 basePrice: 5.90, perKm: 0.85, kind: .moto, bodyColor: Theme.accent),
        RideType(id: "comfort", name: "Comfort", tagline: "Carros novos e mais espaço", seats: 4, etaMinutes: 4,
                 basePrice: 13.50, perKm: 1.95, kind: .car, bodyColor: Color(red: 0.55, green: 0.62, blue: 0.70)),
        RideType(id: "xl", name: "XL", tagline: "Para até 6 pessoas", seats: 6, etaMinutes: 6,
                 basePrice: 17.80, perKm: 2.50, kind: .car, bodyColor: Color(red: 0.35, green: 0.40, blue: 0.48)),
        RideType(id: "black", name: "Black", tagline: "Motoristas mais bem avaliados", seats: 4, etaMinutes: 7,
                 basePrice: 22.40, perKm: 3.10, kind: .car, bodyColor: Color(white: 0.12))
    ]

    static func rideType(_ id: String) -> RideType {
        rideTypes.first { $0.id == id } ?? rideTypes[0]
    }

    // MARK: - Services

    static let services: [ServiceTile] = [
        ServiceTile(id: "viagem", title: "Viagem", subtitle: "Vá para qualquer lugar", symbol: "car.fill", rideTypeID: "x"),
        ServiceTile(id: "moto", title: "Moto", subtitle: "Rápido e barato", symbol: "scooter", rideTypeID: "moto"),
        ServiceTile(id: "agendar", title: "Agendar", subtitle: "Reserve com antecedência", symbol: "calendar", rideTypeID: nil),
        ServiceTile(id: "entrega", title: "Entrega", subtitle: "Envie pacotes na cidade", symbol: "shippingbox.fill", rideTypeID: "moto"),
        ServiceTile(id: "comfort", title: "Comfort", subtitle: "Mais espaço", symbol: "car.side.fill", rideTypeID: "comfort"),
        ServiceTile(id: "xl", title: "XL", subtitle: "Para o grupo todo", symbol: "person.3.fill", rideTypeID: "xl"),
        ServiceTile(id: "black", title: "Black", subtitle: "Viagem premium", symbol: "star.fill", rideTypeID: "black"),
        ServiceTile(id: "aluguel", title: "Aluguel", subtitle: "Motorista por hora", symbol: "clock.fill", rideTypeID: nil)
    ]

    // MARK: - Driver path and ambient traffic

    /// Where the matched driver starts and the streets he drives to reach the pickup.
    static let driverApproach: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: -3.4878, longitude: -39.5714),
        CLLocationCoordinate2D(latitude: -3.4893, longitude: -39.5729),
        CLLocationCoordinate2D(latitude: -3.4906, longitude: -39.5748),
        CLLocationCoordinate2D(latitude: -3.4922, longitude: -39.5762),
        CLLocationCoordinate2D(latitude: -3.4934, longitude: -39.5777),
        pickup
    ]

    static let ambientVehicles: [AmbientVehicle] = [
        AmbientVehicle(id: 0, kind: .car, loop: loop(dLat: 0.0000, dLon: -0.0030, w: 0.0040, h: 0.0024), speed: 0.020, offset: 0.10),
        AmbientVehicle(id: 1, kind: .car, loop: loop(dLat: 0.0035, dLon: 0.0018, w: 0.0030, h: 0.0030), speed: 0.016, offset: 0.55),
        AmbientVehicle(id: 2, kind: .car, loop: loop(dLat: -0.0040, dLon: 0.0005, w: 0.0050, h: 0.0020), speed: 0.012, offset: 0.30),
        AmbientVehicle(id: 3, kind: .moto, loop: loop(dLat: 0.0012, dLon: 0.0030, w: 0.0022, h: 0.0034), speed: 0.026, offset: 0.75),
        AmbientVehicle(id: 4, kind: .moto, loop: loop(dLat: -0.0018, dLon: -0.0042, w: 0.0026, h: 0.0028), speed: 0.022, offset: 0.40)
    ]

    /// A closed rectangular block around the city centre.
    private static func loop(dLat: Double, dLon: Double, w: Double, h: Double) -> [CLLocationCoordinate2D] {
        let lat = pickup.latitude + dLat
        let lon = pickup.longitude + dLon
        return [
            CLLocationCoordinate2D(latitude: lat - h / 2, longitude: lon - w / 2),
            CLLocationCoordinate2D(latitude: lat - h / 2, longitude: lon + w / 2),
            CLLocationCoordinate2D(latitude: lat + h / 2, longitude: lon + w / 2),
            CLLocationCoordinate2D(latitude: lat + h / 2, longitude: lon - w / 2),
            CLLocationCoordinate2D(latitude: lat - h / 2, longitude: lon - w / 2)
        ]
    }

    // MARK: - History

    static let pastTrips: [Trip] = [
        Trip(id: "t1", date: date(2026, 10, 19, 18, 42), pickupName: "Casa", destination: place("praca"),
             rideName: "ZiprideX", driverName: "Francisca", payment: .pix, fare: 9.90, tip: 2,
             rating: 5, distanceKm: 1.1, durationMinutes: 6),
        Trip(id: "t2", date: date(2026, 10, 17, 7, 55), pickupName: "Casa", destination: place("ifce"),
             rideName: "Moto", driverName: "Raimundo", payment: .pix, fare: 5.90, tip: 0,
             rating: 5, distanceKm: 2.4, durationMinutes: 8),
        Trip(id: "t3", date: date(2026, 10, 12, 9, 10), pickupName: "Rodoviária", destination: place("baleia"),
             rideName: "Comfort", driverName: "Antônia", payment: .visa, fare: 73.80, tip: 5,
             rating: 4, distanceKm: 33.2, durationMinutes: 41),
        Trip(id: "t4", date: date(2026, 10, 5, 20, 15), pickupName: "Mercado Público", destination: place("facedi"),
             rideName: "ZiprideX", driverName: "Cícero", payment: .cash, fare: 9.90, tip: 0,
             rating: 5, distanceKm: 1.9, durationMinutes: 7)
    ]

    static func date(_ y: Int, _ m: Int, _ d: Int, _ h: Int, _ min: Int) -> Date {
        var parts = DateComponents()
        parts.year = y
        parts.month = m
        parts.day = d
        parts.hour = h
        parts.minute = min
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = BR.timeZone
        return calendar.date(from: parts) ?? Date(timeIntervalSince1970: 1_792_000_000)
    }

    // MARK: - Images (verified by scripts/check-urls.sh in CI)

    static let servicesBannerURL = image("photo-1558981403-c5f9899a28bc")
    static let walletBannerURL = image("photo-1449965408869-eaa3f722e40d")

    static func image(_ id: String) -> URL {
        URL(string: "https://images.unsplash.com/\(id)?w=800&q=80&fit=crop") ?? URL(fileURLWithPath: "/")
    }
}
