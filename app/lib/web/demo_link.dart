import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../admin/admin_store.dart';
import '../core/driver_store.dart';
import '../core/fixtures.dart';
import '../core/formatters.dart';
import '../core/models.dart';
import '../core/ride_store.dart';

/// Wires the customer app, the driver app and the admin panel together in the browser,
/// so a ride asked for in one shows up in the other two. Everything stays in memory.
class DemoLink {
  DemoLink() {
    rider.dispatch = _dispatch;
    rider.onCancelled = () {
      driver.passengerCancelled();
      admin.log('ride.cancelled', '${Fixtures.userName} cancelou a corrida');
    };
    rider.onTripStarted = () => driver.startTrip(fromLink: true);
    driver.onTripStarted = () {
      rider.startTrip(fromLink: true);
      admin.log('ride.started', 'Marcos iniciou a viagem com ${Fixtures.userFirstName}');
    };
    driver.onArrived = () => admin.log('driver.arrived', 'Marcos chegou na Praça da Matriz');
  }

  final rider = RideStore();
  final driver = DriverStore();
  late final admin = AdminStore(rider: rider, driver: driver);

  Future<bool> _dispatch(RideStore store) {
    final dest = store.destination!;
    final ride = store.selectedRide;
    admin.log('ride.requested', '${Fixtures.userName} pediu ${ride.name} para ${dest.name} · ${BR.money(store.priceOf(ride))}');
    if (!driver.canReceive) {
      admin.log('dispatch.simulated', 'Motorista do app offline: outro motorista simulado aceitou');
      return Future.value(false);
    }
    final answer = Completer<bool>();
    driver.onAccept = () {
      admin.log('driver.accepted', 'Marcos aceitou a corrida de ${Fixtures.userFirstName}');
      if (!answer.isCompleted) answer.complete(true);
    };
    driver.onDecline = () {
      admin.log('driver.declined', 'Marcos recusou: corrida passada para outro motorista');
      if (!answer.isCompleted) answer.complete(false);
    };
    driver.offer(DriverRequest(
      id: 'live',
      passenger: Fixtures.userName,
      passengerRating: Fixtures.userRating,
      pickup: const Place('local', 'Praça da Matriz', Fixtures.pickupAddress, CupertinoIcons.location_solid, -3.4944, -39.5786),
      destination: dest,
      rideName: ride.name,
      fare: store.priceOf(ride),
      payment: store.payment,
      linked: true,
    ));
    return answer.future;
  }

  void dispose() {
    admin.dispose();
  }
}
