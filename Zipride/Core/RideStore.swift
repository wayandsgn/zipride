import Foundation
import SwiftUI
import MapKit
import Observation

enum RidePhase: Equatable {
    case idle
    case choosing
    case matching
    case driverEnRoute
    case driverArrived
    case onTrip
}

enum AppTab: Hashable {
    case home
    case services
    case activity
    case account
}

/// Single source of truth for the demo. Nothing is persisted: each launch starts from Fixtures.
@MainActor
@Observable
final class RideStore {
    // Navigation
    var tab: AppTab = .home
    var showSearch = false
    var showSchedule = false

    // Ride
    var phase: RidePhase = .idle
    var destination: Place?
    var route: [CLLocationCoordinate2D] = []
    var routeReveal: Double = 0
    var isRouting = false
    var selectedRideID = "x"
    var payment: PaymentMethod = .pix
    var scheduleLabel = "Agora"

    // Driver and trip
    var driverProgress: Double = 0
    var tripProgress: Double = 0
    var showRating = false
    var chat: [ChatMessage] = []
    var driverTyping = false
    var showChat = false
    var lastCompletedTrip: Trip?

    // History
    var trips: [Trip] = Fixtures.pastTrips

    // Map
    var camera: MapCameraPosition = RideStore.homeCamera
    var ambientClock: Double = 0

    @ObservationIgnored private var rideTask: Task<Void, Never>?
    @ObservationIgnored private var replyIndex = 0

    static let homeCamera = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: Fixtures.pickup.latitude - 0.0032, longitude: Fixtures.pickup.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.016, longitudeDelta: 0.016)
        )
    )

    var selectedRide: RideType { Fixtures.rideType(selectedRideID) }

    var tripKm: Double {
        guard let destination else { return 0 }
        let routed = Geo.length(route) / 1000
        return routed > 0.3 ? routed : destination.distanceKm
    }

    func price(of ride: RideType) -> Double { ride.price(forKm: tripKm) }

    var tripMinutes: Int { max(4, Int((tripKm / 0.55).rounded())) }

    // MARK: - Ambient traffic

    func position(of vehicle: AmbientVehicle) -> CLLocationCoordinate2D {
        Geo.point(on: vehicle.loop, at: fraction(of: vehicle))
    }

    func heading(of vehicle: AmbientVehicle) -> Double {
        Geo.heading(on: vehicle.loop, at: fraction(of: vehicle))
    }

    private func fraction(of vehicle: AmbientVehicle) -> Double {
        let raw = vehicle.offset + ambientClock * vehicle.speed
        return raw - floor(raw)
    }

    func tickAmbient(by seconds: Double) {
        ambientClock += seconds
    }

    // MARK: - Choosing a destination

    func openSearch(preferring rideID: String? = nil) {
        if let rideID { selectedRideID = rideID }
        tab = .home
        showSearch = true
    }

    func choose(_ place: Place) {
        rideTask?.cancel()
        destination = place
        phase = .choosing
        route = []
        routeReveal = 0
        isRouting = true
        showSearch = false
        let rough = Geo.fallbackRoute(from: Fixtures.pickup, to: place.coordinate)
        withAnimation(.smooth(duration: 0.6)) {
            camera = .rect(Geo.fittingRect(rough))
        }
        rideTask = Task { [weak self] in
            let coordinates = await RouteService.route(from: Fixtures.pickup, to: place.coordinate)
            guard let self, !Task.isCancelled else { return }
            self.route = coordinates
            self.isRouting = false
            withAnimation(.smooth(duration: 0.5)) {
                self.camera = .rect(Geo.fittingRect(coordinates))
            }
            await self.animate(duration: 0.9, steps: 30) { value in self.routeReveal = value }
        }
    }

    func backToHome() {
        rideTask?.cancel()
        resetRide()
    }

    // MARK: - Matching, pickup and trip

    func confirmRide() {
        guard destination != nil else { return }
        rideTask?.cancel()
        routeReveal = 1
        phase = .matching
        withAnimation(.smooth(duration: 0.5)) {
            camera = .region(MKCoordinateRegion(center: Fixtures.pickup, latitudinalMeters: 900, longitudinalMeters: 900))
        }
        rideTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(3))
            guard let self, !Task.isCancelled else { return }
            self.driverMatched()
        }
    }

    private func driverMatched() {
        driverProgress = 0
        chat = [ChatMessage(id: 0, text: "Oi, \(Fixtures.userFirstName)! Sou o \(Fixtures.driver.name), já estou indo te buscar.", fromDriver: true, time: Date())]
        withAnimation(.snappy) { phase = .driverEnRoute }
        withAnimation(.smooth(duration: 0.6)) {
            camera = .rect(Geo.fittingRect(Fixtures.driverApproach, bottomShare: 0.55))
        }
        rideTask = Task { [weak self] in
            guard let self else { return }
            await self.animate(duration: 8, steps: 80) { value in self.driverProgress = value }
            guard !Task.isCancelled else { return }
            withAnimation(.snappy) { self.phase = .driverArrived }
            try? await Task.sleep(for: .milliseconds(2500))
            guard !Task.isCancelled, self.phase == .driverArrived, !self.showChat else { return }
            self.startTrip()
        }
    }

    func startTrip() {
        guard phase == .driverArrived || phase == .driverEnRoute else { return }
        rideTask?.cancel()
        driverProgress = 1
        tripProgress = 0
        withAnimation(.snappy) { phase = .onTrip }
        withAnimation(.smooth(duration: 0.6)) {
            camera = .rect(Geo.fittingRect(route))
        }
        rideTask = Task { [weak self] in
            guard let self else { return }
            await self.animate(duration: 8, steps: 80) { value in self.tripProgress = value }
            guard !Task.isCancelled else { return }
            try? await Task.sleep(for: .milliseconds(400))
            self.showRating = true
        }
    }

    func cancelRide() {
        rideTask?.cancel()
        withAnimation(.snappy) { resetRide() }
    }

    func finishRating(stars: Int, tip: Double) {
        if let destination {
            let trip = Trip(
                id: "new-\(trips.count + 1)",
                date: Date(),
                pickupName: "Praça da Matriz",
                destination: destination,
                rideName: selectedRide.name,
                driverName: Fixtures.driver.name,
                payment: payment,
                fare: price(of: selectedRide),
                tip: tip,
                rating: stars,
                distanceKm: tripKm,
                durationMinutes: tripMinutes
            )
            trips.insert(trip, at: 0)
            lastCompletedTrip = trip
        }
        showRating = false
        withAnimation(.snappy) { resetRide() }
    }

    private func resetRide() {
        phase = .idle
        destination = nil
        route = []
        routeReveal = 0
        isRouting = false
        driverProgress = 0
        tripProgress = 0
        chat = []
        driverTyping = false
        showChat = false
        camera = RideStore.homeCamera
    }

    // MARK: - Positions used by the map

    var driverCoordinate: CLLocationCoordinate2D? {
        switch phase {
        case .driverEnRoute, .driverArrived:
            return Geo.point(on: Fixtures.driverApproach, at: driverProgress)
        case .onTrip:
            return Geo.point(on: route, at: tripProgress)
        default:
            return nil
        }
    }

    var driverHeading: Double {
        if phase == .onTrip { return Geo.heading(on: route, at: tripProgress) }
        return Geo.heading(on: Fixtures.driverApproach, at: driverProgress)
    }

    var visibleRoute: [CLLocationCoordinate2D] {
        guard route.count > 1 else { return [] }
        return Geo.prefix(of: route, fraction: routeReveal)
    }

    var arrivalMinutes: Int {
        let remaining = 1 - driverProgress
        return max(1, Int((3 * remaining).rounded(.up)))
    }

    var tripRemainingMinutes: Int {
        max(1, Int((Double(tripMinutes) * (1 - tripProgress)).rounded(.up)))
    }

    var tripArrivalTime: Date {
        Date().addingTimeInterval(Double(tripRemainingMinutes) * 60)
    }

    // MARK: - Chat

    func send(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        chat.append(ChatMessage(id: chat.count, text: trimmed, fromDriver: false, time: Date()))
        driverTyping = true
        let reply = Fixtures.driverReplies[replyIndex % Fixtures.driverReplies.count]
        replyIndex += 1
        Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(1300))
            guard let self else { return }
            self.driverTyping = false
            withAnimation(.snappy) {
                self.chat.append(ChatMessage(id: self.chat.count, text: reply, fromDriver: true, time: Date()))
            }
        }
    }

    // MARK: - Helpers

    private func animate(duration: Double, steps: Int, update: (Double) -> Void) async {
        let pause = duration / Double(steps)
        for step in 1...steps {
            if Task.isCancelled { return }
            try? await Task.sleep(for: .seconds(pause))
            if Task.isCancelled { return }
            let value = Double(step) / Double(steps)
            withAnimation(.linear(duration: pause)) { update(value) }
        }
    }
}
