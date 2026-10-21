import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zipride/core/models.dart';
import 'package:zipride/core/ride_store.dart';
import 'package:zipride/main.dart';

/// Drives the whole demo the way a person would: every main button is tapped at least once.
void main() {
  late RideStore store;

  // Load the real Inter files so text measures the same as on a phone.
  setUpAll(() async {
    final loader = FontLoader('Inter');
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold', 'Black']) {
      final bytes = File('assets/fonts/Inter-$w.ttf').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  });

  Future<void> boot(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    store = RideStore(timeScale: 4, showMapTiles: false);
    await tester.pumpWidget(ZiprideApp(store: store));
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> settle(WidgetTester tester, [int ms = 500]) async {
    for (var i = 0; i < ms ~/ 50; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> tap(WidgetTester tester, String key) async {
    final finder = find.byKey(ValueKey(key));
    if (finder.evaluate().isEmpty) {
      // Lazy lists only build what is on screen: scroll down to reach it.
      await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).last);
    }
    expect(finder, findsOneWidget, reason: 'missing $key');
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(finder);
    await settle(tester);
  }

  testWidgets('full ride, then every tab', (tester) async {
    await boot(tester);
    expect(find.text('Para onde?'), findsOneWidget);

    // Search and choose a destination.
    await tap(tester, 'whereTo');
    await tester.enterText(find.byKey(const ValueKey('searchField')), 'rodoviaria');
    await settle(tester);
    await tap(tester, 'place_rodoviaria');
    expect(store.phase, RidePhase.choosing);
    expect(store.destination?.id, 'rodoviaria');

    // Ride type and payment.
    await tap(tester, 'rideOption_moto');
    expect(store.selectedRideId, 'moto');
    await tap(tester, 'paymentRow');
    await tap(tester, 'payment_visa');
    expect(store.payment, PaymentMethod.visa);
    await tap(tester, 'paymentDone');

    // Confirm, match, chat.
    await tap(tester, 'confirmRide');
    expect(store.phase, RidePhase.matching);
    await settle(tester, 600);
    expect(store.phase, RidePhase.driverEnRoute);
    await tap(tester, 'messageButton');
    expect(store.showChat, isTrue);
    await tap(tester, 'quickReply_0');
    await settle(tester, 300);
    expect(store.chat.where((m) => !m.fromDriver).length, 1);
    expect(store.chat.last.fromDriver, isTrue);
    await tap(tester, 'chatClose');

    // Trip and rating.
    await tap(tester, 'startTrip');
    expect(store.phase, RidePhase.onTrip);
    await settle(tester, 3000);
    expect(find.byKey(const ValueKey('ratingDone')), findsOneWidget);
    await tap(tester, 'ratingStar_5');
    await tap(tester, 'tip_5');
    await tap(tester, 'ratingDone');
    expect(store.phase, RidePhase.idle);
    expect(store.trips.first.id, 'new-5');
    expect(store.trips.first.tip, 5);

    // Activity: the new trip, its receipt, ride again.
    await tap(tester, 'tab_Atividade');
    expect(find.text('Nova'), findsOneWidget);
    await tap(tester, 'trip_new-5');
    expect(find.text('Recibo'), findsWidgets);
    await tap(tester, 'tripHelp');
    await tester.tap(find.text('OK'));
    await settle(tester);
    await tap(tester, 'rideAgain');
    expect(store.tab, AppTab.home);
    expect(store.phase, RidePhase.choosing);
    await tap(tester, 'backToHome');
    expect(store.phase, RidePhase.idle);

    // Services: hourly rental leads into search.
    await tap(tester, 'tab_Serviços');
    await tap(tester, 'service_aluguel');
    await tap(tester, 'rentalPlus');
    expect(find.textContaining('3 horas'), findsOneWidget);
    await tap(tester, 'rentalContinue');
    expect(store.selectedRideId, 'comfort');
    expect(find.byKey(const ValueKey('searchField')), findsOneWidget);
    await tap(tester, 'closeSearch');

    // Account: wallet, settings.
    await tap(tester, 'tab_Conta');
    await tap(tester, 'walletLink');
    await tap(tester, 'payment_cash');
    expect(store.payment, PaymentMethod.cash);
    await tap(tester, 'back');
    await tap(tester, 'settingsLink');
    final promos = find.descendant(of: find.byKey(const ValueKey('switch_promos')), matching: find.byType(CupertinoSwitch));
    expect(tester.widget<CupertinoSwitch>(promos).value, isFalse);
    await tester.tap(promos);
    await settle(tester);
    expect(tester.widget<CupertinoSwitch>(promos).value, isTrue);
    await tap(tester, 'back');
    await tap(tester, 'savedLink');
    await tap(tester, 'savedPlace_casa');
    expect(store.destination?.id, 'casa');
    expect(store.tab, AppTab.home);
  });
}
