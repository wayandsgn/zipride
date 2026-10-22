import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

import 'fixtures.dart';
import 'geo.dart';
import 'models.dart';
import 'ride_store.dart';

enum DriverPhase { offline, searching, request, toPickup, atPickup, onTrip, finished }

enum DriverTab { home, earnings, account }

/// A ride offered to the driver.
class DriverRequest {
  const DriverRequest({
    required this.id,
    required this.passenger,
    required this.passengerRating,
    required this.pickup,
    required this.destination,
    required this.rideName,
    required this.fare,
    required this.payment,
    this.linked = false,
  });

  final String id;
  final String passenger;
  final double passengerRating;
  final Place pickup;
  final Place destination;
  final String rideName;
  final double fare;
  final PaymentMethod payment;

  /// True when it came from the customer app open next to this one.
  final bool linked;

  double get tripKm => Geo.roadDistanceKm(pickup.point, destination.point);
  int get tripMinutes => (tripKm / 0.55).round().clamp(4, 999);

  /// ITAX keeps 20%; the driver receives the rest.
  double get driverShare => (fare * 0.8 * 100).round() / 100;
}

/// A finished ride in the driver's day.
class DriverTrip {
  const DriverTrip(this.request, this.finishedAt, this.stars);
  final DriverRequest request;
  final DateTime finishedAt;
  final int stars;
}

/// State of the driver app. Like the customer app, nothing is saved.
class DriverStore extends ChangeNotifier {
  DriverStore({this.timeScale = 1});

  final double timeScale;

  DriverTab tab = DriverTab.home;
  DriverPhase phase = DriverPhase.offline;
  DriverRequest? request;
  double countdown = 1;
  double progress = 0;
  String? notice;
  int missed = 0;
  final List<DriverTrip> today = [];

  /// Earnings already made earlier in the day and over the week (Mon..Sun).
  static const earlierToday = 86.40;
  static const week = [142.30, 168.90, 121.50, 187.20, 0.0, 0.0, 0.0];
  static final start = Fixtures.driverApproach.first;

  // Hooks used when the customer app runs next to this one.
  VoidCallback? onAccept;
  VoidCallback? onDecline;
  VoidCallback? onTripStarted;
  VoidCallback? onArrived;

  CameraTarget camera = const CameraTarget.center(LatLng(-3.4930, -39.5760), 15.4);
  int cameraVersion = 0;
  int _run = 0;
  int _pool = 0;

  double get earningsToday => earlierToday + today.fold(0.0, (sum, t) => sum + t.request.driverShare);
  int get tripsToday => 7 + today.length;

  List<LatLng> get approach {
    final r = request;
    if (r == null) return const [];
    // Same streets the customer app shows when the pickup is the Praça da Matriz.
    if (r.pickup.point == Fixtures.pickup) return Fixtures.driverApproach;
    return Geo.curvedRoute(start, r.pickup.point);
  }
  List<LatLng> get tripRoute => request == null ? const [] : Geo.curvedRoute(request!.pickup.point, request!.destination.point);

  LatLng get position => switch (phase) {
        DriverPhase.toPickup => Geo.pointOn(approach, progress),
        DriverPhase.atPickup => request!.pickup.point,
        DriverPhase.onTrip => Geo.pointOn(tripRoute, progress),
        DriverPhase.finished => request?.destination.point ?? start,
        _ => start,
      };

  double get heading => switch (phase) {
        DriverPhase.toPickup => Geo.headingOn(approach, progress),
        DriverPhase.onTrip => Geo.headingOn(tripRoute, progress),
        _ => 0,
      };

  int get minutesLeft {
    final total = phase == DriverPhase.onTrip ? (request?.tripMinutes ?? 4) : 3;
    return (total * (1 - progress)).ceil().clamp(1, 999);
  }

  void select(DriverTab value) {
    tab = value;
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void _move(CameraTarget target) {
    camera = target;
    cameraVersion++;
  }

  void clearNotice() {
    notice = null;
    notifyListeners();
  }

  // MARK: Online / offline

  void goOnline() {
    if (phase != DriverPhase.offline) return;
    phase = DriverPhase.searching;
    HapticFeedback.mediumImpact();
    notifyListeners();
    _offerSoon(++_run);
  }

  void goOffline() {
    if (phase != DriverPhase.searching) return;
    _run++;
    phase = DriverPhase.offline;
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  /// Without a customer app linked, a demo request arrives after a few seconds.
  Future<void> _offerSoon(int run) async {
    await _sleep(const Duration(seconds: 5));
    if (run != _run || phase != DriverPhase.searching || autoOffers == false) return;
    final demo = _demoRequests[_pool % _demoRequests.length];
    _pool++;
    offer(demo);
  }

  /// Turned off while a customer app is linked, so only real requests come in.
  bool autoOffers = true;

  void setAutoOffers(bool value) {
    if (autoOffers == value) return;
    autoOffers = value;
    if (value && phase == DriverPhase.searching) _offerSoon(++_run);
  }

  bool get canReceive => phase == DriverPhase.searching;

  void offer(DriverRequest value) {
    final run = ++_run;
    request = value;
    phase = DriverPhase.request;
    countdown = 1;
    _move(CameraTarget.fit([start, value.pickup.point, value.destination.point], bottomShare: 0.55));
    HapticFeedback.heavyImpact();
    notifyListeners();
    _countDown(run);
  }

  Future<void> _countDown(int run) async {
    const steps = 150;
    for (var i = 1; i <= steps; i++) {
      await _sleep(const Duration(milliseconds: 100));
      if (run != _run || phase != DriverPhase.request) return;
      countdown = 1 - i / steps;
      notifyListeners();
    }
    missed++;
    decline(timedOut: true);
  }

  void decline({bool timedOut = false}) {
    if (phase != DriverPhase.request) return;
    final linked = request?.linked ?? false;
    _run++;
    request = null;
    phase = DriverPhase.searching;
    notice = timedOut ? 'Corrida perdida: o tempo para aceitar acabou.' : null;
    notifyListeners();
    if (linked) onDecline?.call();
    _offerSoon(++_run);
  }

  // MARK: Ride

  Future<void> accept() async {
    if (phase != DriverPhase.request) return;
    final run = ++_run;
    phase = DriverPhase.toPickup;
    progress = 0;
    _move(CameraTarget.fit(approach, bottomShare: 0.5));
    HapticFeedback.mediumImpact();
    notifyListeners();
    if (request!.linked) onAccept?.call();
    await _animate(const Duration(seconds: 8), run);
    if (run != _run) return;
    phase = DriverPhase.atPickup;
    HapticFeedback.heavyImpact();
    notifyListeners();
    if (request!.linked) onArrived?.call();
  }

  Future<void> startTrip({bool fromLink = false}) async {
    if (phase != DriverPhase.atPickup && phase != DriverPhase.toPickup) return;
    final run = ++_run;
    phase = DriverPhase.onTrip;
    progress = 0;
    _move(CameraTarget.fit(tripRoute, bottomShare: 0.45));
    HapticFeedback.mediumImpact();
    notifyListeners();
    if (!fromLink && request!.linked) onTripStarted?.call();
    await _animate(const Duration(seconds: 8), run);
    if (run != _run) return;
    phase = DriverPhase.finished;
    HapticFeedback.heavyImpact();
    notifyListeners();
  }

  void finish(int stars) {
    final r = request;
    if (r != null) today.insert(0, DriverTrip(r, DateTime.now(), stars));
    request = null;
    phase = DriverPhase.searching;
    _move(const CameraTarget.center(LatLng(-3.4930, -39.5760), 15.4));
    HapticFeedback.mediumImpact();
    notifyListeners();
    _offerSoon(++_run);
  }

  /// The passenger cancelled in the customer app.
  void passengerCancelled() {
    if (request == null || phase == DriverPhase.finished) return;
    _run++;
    request = null;
    phase = DriverPhase.searching;
    notice = 'O passageiro cancelou a corrida.';
    _move(const CameraTarget.center(LatLng(-3.4930, -39.5760), 15.4));
    notifyListeners();
    _offerSoon(++_run);
  }

  // MARK: Helpers

  Future<void> _sleep(Duration d) => Future.delayed(d * (1 / timeScale));

  Future<void> _animate(Duration duration, int run) async {
    const steps = 80;
    for (var i = 1; i <= steps; i++) {
      await _sleep(duration * (1 / steps));
      if (run != _run) return;
      progress = i / steps;
      notifyListeners();
    }
  }

  static final _demoRequests = [
    DriverRequest(id: 'd1', passenger: 'Ana Beatriz', passengerRating: 4.95, pickup: Fixtures.place('mercado'), destination: Fixtures.place('rodoviaria'), rideName: 'ITAX Go', fare: 9.90, payment: PaymentMethod.pix),
    DriverRequest(id: 'd2', passenger: 'João Pedro', passengerRating: 4.81, pickup: Fixtures.place('estacao'), destination: Fixtures.place('ifce'), rideName: 'ITAX Go', fare: 9.90, payment: PaymentMethod.cash),
    DriverRequest(id: 'd3', passenger: 'Francisca Lima', passengerRating: 4.98, pickup: Fixtures.place('praca'), destination: Fixtures.place('pedrinhas'), rideName: 'Comfort', fare: 65.70, payment: PaymentMethod.visa),
  ];
}

/// Makes the driver store available to the driver app.
class DriverScope extends InheritedNotifier<DriverStore> {
  const DriverScope({super.key, required DriverStore store, required super.child}) : super(notifier: store);

  static DriverStore of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<DriverScope>()!.notifier!;
  static DriverStore read(BuildContext context) => context.getInheritedWidgetOfExactType<DriverScope>()!.notifier!;
}
