import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

import 'fixtures.dart';
import 'geo.dart';
import 'models.dart';

enum RidePhase { idle, choosing, matching, driverEnRoute, driverArrived, onTrip }

enum AppTab { home, services, activity, account }

/// Where the map should look: either a centre and zoom, or a set of points to fit.
class CameraTarget {
  const CameraTarget.center(this.center, this.zoom) : points = const [], bottomShare = 0;
  const CameraTarget.fit(this.points, {this.bottomShare = 0.5}) : center = null, zoom = null;

  final LatLng? center;
  final double? zoom;
  final List<LatLng> points;
  final double bottomShare;
}

/// Single source of truth for the demo. Nothing is persisted: each launch starts from Fixtures.
class RideStore extends ChangeNotifier {
  RideStore({this.timeScale = 1, this.showMapTiles = true});

  /// 1 in the app; tests can speed the ride up.
  final double timeScale;

  /// Tests turn map tiles off so they never touch the network.
  final bool showMapTiles;

  // Navigation
  AppTab tab = AppTab.home;
  bool showChat = false;

  // Ride
  RidePhase phase = RidePhase.idle;
  Place? destination;
  List<LatLng> route = const [];
  double routeReveal = 0;
  String selectedRideId = 'x';
  PaymentMethod payment = PaymentMethod.pix;
  String scheduleLabel = 'Agora';

  // Driver and trip
  double driverProgress = 0;
  double tripProgress = 0;
  bool ratingPending = false;
  final List<ChatMessage> chat = [];
  bool driverTyping = false;
  String? lastCompletedTripId;

  // History
  final List<Trip> trips = [...Fixtures.pastTrips];

  // Map
  static const homeCamera = CameraTarget.center(LatLng(-3.4976, -39.5786), 15.6);
  CameraTarget camera = homeCamera;
  int cameraVersion = 0;

  int _run = 0;
  int _replyIndex = 0;

  RideType get selectedRide => Fixtures.rideType(selectedRideId);

  double get tripKm {
    final dest = destination;
    if (dest == null) return 0;
    return math.max(Geo.length(route) / 1000, dest.distanceKm);
  }

  double priceOf(RideType ride) => ride.priceFor(tripKm);

  int get tripMinutes => math.max(4, (tripKm / 0.55).round());

  int get arrivalMinutes => math.max(1, (3 * (1 - driverProgress)).ceil());

  int get tripRemainingMinutes => math.max(1, (tripMinutes * (1 - tripProgress)).ceil());

  DateTime get tripArrivalTime => DateTime.now().add(Duration(minutes: tripRemainingMinutes));

  LatLng? get driverPosition {
    switch (phase) {
      case RidePhase.driverEnRoute:
      case RidePhase.driverArrived:
        return Geo.pointOn(Fixtures.driverApproach, driverProgress);
      case RidePhase.onTrip:
        return Geo.pointOn(route, tripProgress);
      default:
        return null;
    }
  }

  double get driverHeading => phase == RidePhase.onTrip
      ? Geo.headingOn(route, tripProgress)
      : Geo.headingOn(Fixtures.driverApproach, driverProgress);

  List<LatLng> get visibleRoute => Geo.prefix(route, routeReveal);

  void _moveCamera(CameraTarget target) {
    camera = target;
    cameraVersion++;
  }

  // MARK: Tabs and settings

  void select(AppTab value) {
    if (tab == value) return;
    tab = value;
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void selectRide(String id) {
    if (selectedRideId == id) return;
    selectedRideId = id;
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void selectPayment(PaymentMethod value) {
    payment = value;
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void setSchedule(String label) {
    scheduleLabel = label;
    notifyListeners();
  }

  void setChatOpen(bool open) {
    showChat = open;
    notifyListeners();
    if (!open && phase == RidePhase.driverArrived) _scheduleAutoStart(_run);
  }

  // MARK: Choosing a destination

  void choose(Place place) {
    final run = ++_run;
    destination = place;
    phase = RidePhase.choosing;
    tab = AppTab.home;
    route = Geo.curvedRoute(Fixtures.pickup, place.point);
    routeReveal = 0;
    _moveCamera(CameraTarget.fit(route));
    HapticFeedback.selectionClick();
    notifyListeners();
    _animate(const Duration(milliseconds: 900), 30, run, (v) => routeReveal = v, delay: const Duration(milliseconds: 250));
  }

  void backToHome() {
    _run++;
    _reset();
    notifyListeners();
  }

  // MARK: Matching, pickup and trip

  Future<void> confirmRide() async {
    if (destination == null) return;
    final run = ++_run;
    routeReveal = 1;
    phase = RidePhase.matching;
    _moveCamera(const CameraTarget.center(LatLng(-3.4962, -39.5786), 16.2));
    HapticFeedback.mediumImpact();
    notifyListeners();
    await _sleep(const Duration(seconds: 3));
    if (run != _run) return;
    _driverMatched(run);
  }

  Future<void> _driverMatched(int run) async {
    driverProgress = 0;
    chat
      ..clear()
      ..add(ChatMessage('Oi, ${Fixtures.userFirstName}! Sou o ${Fixtures.driver.name}, já estou indo te buscar.', fromDriver: true, time: DateTime.now()));
    phase = RidePhase.driverEnRoute;
    _moveCamera(const CameraTarget.fit(Fixtures.driverApproach, bottomShare: 0.55));
    HapticFeedback.lightImpact();
    notifyListeners();
    await _animate(const Duration(seconds: 8), 80, run, (v) => driverProgress = v);
    if (run != _run) return;
    phase = RidePhase.driverArrived;
    HapticFeedback.heavyImpact();
    notifyListeners();
    _scheduleAutoStart(run);
  }

  Future<void> _scheduleAutoStart(int run) async {
    await _sleep(const Duration(milliseconds: 2500));
    if (run != _run || phase != RidePhase.driverArrived || showChat) return;
    startTrip();
  }

  Future<void> startTrip() async {
    if (phase != RidePhase.driverArrived && phase != RidePhase.driverEnRoute) return;
    final run = ++_run;
    driverProgress = 1;
    tripProgress = 0;
    phase = RidePhase.onTrip;
    _moveCamera(CameraTarget.fit(route, bottomShare: 0.42));
    HapticFeedback.mediumImpact();
    notifyListeners();
    await _animate(const Duration(seconds: 8), 80, run, (v) => tripProgress = v);
    if (run != _run) return;
    await _sleep(const Duration(milliseconds: 400));
    if (run != _run) return;
    ratingPending = true;
    notifyListeners();
  }

  void cancelRide() {
    _run++;
    _reset();
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  void finishRating({required int stars, required double tip}) {
    final dest = destination;
    if (dest != null) {
      final trip = Trip(
        id: 'new-${trips.length + 1}',
        date: DateTime.now(),
        pickupName: 'Praça da Matriz',
        destination: dest,
        rideName: selectedRide.name,
        driverName: Fixtures.driver.name,
        payment: payment,
        fare: priceOf(selectedRide),
        tip: tip,
        rating: stars,
        distanceKm: tripKm,
        durationMinutes: tripMinutes,
      );
      trips.insert(0, trip);
      lastCompletedTripId = trip.id;
    }
    ratingPending = false;
    _run++;
    _reset();
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void _reset() {
    phase = RidePhase.idle;
    destination = null;
    route = const [];
    routeReveal = 0;
    driverProgress = 0;
    tripProgress = 0;
    chat.clear();
    driverTyping = false;
    showChat = false;
    _moveCamera(homeCamera);
  }

  // MARK: Chat

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    chat.add(ChatMessage(trimmed, fromDriver: false, time: DateTime.now()));
    driverTyping = true;
    HapticFeedback.lightImpact();
    notifyListeners();
    final reply = Fixtures.driverReplies[_replyIndex % Fixtures.driverReplies.length];
    _replyIndex++;
    await _sleep(const Duration(milliseconds: 1300));
    driverTyping = false;
    if (phase == RidePhase.idle) return;
    chat.add(ChatMessage(reply, fromDriver: true, time: DateTime.now()));
    notifyListeners();
  }

  // MARK: Helpers

  Future<void> _sleep(Duration d) => Future.delayed(d * (1 / timeScale));

  Future<void> _animate(Duration duration, int steps, int run, void Function(double) update, {Duration delay = Duration.zero}) async {
    if (delay > Duration.zero) await _sleep(delay);
    final pause = duration * (1 / steps);
    for (var step = 1; step <= steps; step++) {
      if (run != _run) return;
      await _sleep(pause);
      if (run != _run) return;
      update(step / steps);
      notifyListeners();
    }
  }
}

/// Makes the store available to the widget tree and rebuilds dependents on change.
class StoreScope extends InheritedNotifier<RideStore> {
  const StoreScope({super.key, required RideStore store, required super.child}) : super(notifier: store);

  static RideStore of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<StoreScope>()!.notifier!;

  static RideStore read(BuildContext context) => context.getInheritedWidgetOfExactType<StoreScope>()!.notifier!;
}
