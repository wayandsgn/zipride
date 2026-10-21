import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zipride/admin/admin_data.dart';
import 'package:zipride/core/driver_store.dart';
import 'package:zipride/core/fixtures.dart';
import 'package:zipride/core/models.dart';
import 'package:zipride/core/ride_store.dart';
import 'package:zipride/driver/driver_app.dart';
import 'package:zipride/web/demo_hub.dart';

import 'helpers.dart';

void main() {
  setUpAll(loadTestFonts);

  testWidgets('driver app on its own: online, accept, pick up, trip, earnings', (tester) async {
    setScreen(tester, const Size(393, 852), ratio: 3);
    final store = DriverStore(timeScale: 5);
    await tester.pumpWidget(DriverApp(store: store));
    await settle(tester);
    expect(find.text('Você está offline'), findsOneWidget);

    await tapKey(tester, 'goOnline');
    expect(store.phase, DriverPhase.searching);
    await settle(tester, 700);
    expect(store.phase, DriverPhase.request);
    await tapKey(tester, 'acceptRide');
    expect(store.phase, DriverPhase.toPickup);
    await settle(tester, 2000);
    expect(store.phase, DriverPhase.atPickup);
    await tapKey(tester, 'driverStartTrip');
    expect(store.phase, DriverPhase.onTrip);
    await settle(tester, 2000);
    expect(store.phase, DriverPhase.finished);
    await tapKey(tester, 'passengerStar_4');
    await tapKey(tester, 'driverFinish');
    expect(store.today.single.stars, 4);
    expect(store.earningsToday, greaterThan(DriverStore.earlierToday));

    // A missed request goes back to searching.
    await settle(tester, 700);
    expect(store.phase, DriverPhase.request);
    await settle(tester, 3200);
    expect(store.phase, DriverPhase.searching);
    expect(store.missed, 1);

    await tapKey(tester, 'tab_Ganhos');
    expect(find.text('Esta semana'), findsOneWidget);
    await tapKey(tester, 'tab_Conta');
    expect(find.text('Marcos Vieira'), findsOneWidget);

    // Let the next demo offer and its countdown run out before the test ends.
    if (store.phase == DriverPhase.request) store.decline();
    store.goOffline();
    await settle(tester, 1500);
  });

  testWidgets('web demo: customer and driver linked, then every admin page', (tester) async {
    setScreen(tester, const Size(1600, 1000));
    Pricing.instance.reset();
    await tester.pumpWidget(const CupertinoApp(home: DemoHub()));
    await settle(tester);
    final hub = tester.state(find.byType(DemoHub)) as dynamic;
    final RideStore rider = hub.link.rider;
    final DriverStore driver = hub.link.driver;

    await tapKey(tester, 'goOnline');
    await tapKey(tester, 'whereTo');
    await tester.enterText(find.byKey(const ValueKey('searchField')), 'baleia');
    await settle(tester);
    await tapKey(tester, 'place_baleia');
    await tapKey(tester, 'confirmRide');
    await settle(tester, 300);
    expect(rider.phase, RidePhase.matching);
    expect(driver.phase, DriverPhase.request);
    expect(driver.request!.linked, isTrue);
    expect(driver.request!.destination.id, 'baleia');

    await tapKey(tester, 'acceptRide');
    expect(rider.phase, RidePhase.driverEnRoute);
    expect(rider.linkedDriver, isTrue);
    await settle(tester, 9000);
    expect(driver.phase, DriverPhase.atPickup);
    expect(rider.phase, RidePhase.driverArrived);
    await settle(tester, 3000);
    expect(rider.phase, RidePhase.driverArrived, reason: 'a linked ride waits for the driver to start');

    await tapKey(tester, 'driverStartTrip');
    expect(rider.phase, RidePhase.onTrip);
    await settle(tester, 9000);
    expect(driver.phase, DriverPhase.finished);
    await tapKey(tester, 'ratingStar_5');
    await tapKey(tester, 'ratingDone');
    await tapKey(tester, 'driverFinish');
    expect(rider.trips.first.id, 'new-5');

    // Admin panel sees the ride and every page opens.
    await tapKey(tester, 'mode_admin');
    expect(find.text('Z4845'), findsWidgets);
    for (final page in ['map', 'rides', 'drivers', 'passengers', 'support', 'pricing', 'system', 'overview']) {
      await tapKey(tester, 'nav_$page');
    }

    await tapKey(tester, 'nav_rides');
    await tapKey(tester, 'ride_Z4845');
    expect(find.textContaining('Davi Filipe'), findsWidgets);
    await tapKey(tester, 'refundRide');
    await tester.tap(find.text('Reembolsar').last);
    await settle(tester);
    await tapKey(tester, 'closeRide');

    await tapKey(tester, 'nav_drivers');
    await tapKey(tester, 'approve_m10');
    final admin = hub.link.admin;
    expect((admin.drivers as List<AdminDriver>).firstWhere((d) => d.id == 'm10').status, DriverStatus.offline);

    await tapKey(tester, 'nav_support');
    await tester.enterText(find.byKey(const ValueKey('ticketReply')), 'Estamos verificando o Pix.');
    await tapKey(tester, 'sendReply');
    expect(find.text('Estamos verificando o Pix.'), findsOneWidget);
    await tapKey(tester, 'resolveTicket');

    await tapKey(tester, 'nav_pricing');
    final before = Fixtures.rideType('x').priceFor(2);
    await tapKey(tester, 'base_x_plus');
    expect(Fixtures.rideType('x').priceFor(2), closeTo(before + 0.5, 0.01));

    await tapKey(tester, 'restartDemo');
    expect(Pricing.instance.base(Fixtures.rideType('x')), Fixtures.rideType('x').basePrice);
  });
}
