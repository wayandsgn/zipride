import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zipride/core/models.dart';
import 'package:zipride/core/ride_store.dart';
import 'package:zipride/main.dart';

import 'helpers.dart';

/// Drives the whole demo the way a person would: every main button is tapped at least once.
void main() {
  late RideStore store;

  setUpAll(loadTestFonts);

  Future<void> boot(WidgetTester tester) async {
    setScreen(tester, const Size(393, 852), ratio: 3);
    store = RideStore(timeScale: 4);
    await tester.pumpWidget(ZiprideApp(store: store));
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('full ride, then every tab', (tester) async {
    await boot(tester);
    expect(find.text('Para onde?'), findsOneWidget);

    // Search and choose a destination.
    await tapKey(tester, 'whereTo');
    await tester.enterText(find.byKey(const ValueKey('searchField')), 'rodoviaria');
    await settle(tester);
    await tapKey(tester, 'place_rodoviaria');
    expect(store.phase, RidePhase.choosing);
    expect(store.destination?.id, 'rodoviaria');

    // Ride type and payment.
    await tapKey(tester, 'rideOption_moto');
    expect(store.selectedRideId, 'moto');
    await tapKey(tester, 'paymentRow');
    await tapKey(tester, 'payment_visa');
    expect(store.payment, PaymentMethod.visa);
    await tapKey(tester, 'paymentDone');

    // Confirm, match, chat.
    await tapKey(tester, 'confirmRide');
    expect(store.phase, RidePhase.matching);
    await settle(tester, 600);
    expect(store.phase, RidePhase.driverEnRoute);
    await tapKey(tester, 'messageButton');
    expect(store.showChat, isTrue);
    await tapKey(tester, 'quickReply_0');
    await settle(tester, 300);
    expect(store.chat.where((m) => !m.fromDriver).length, 1);
    expect(store.chat.last.fromDriver, isTrue);
    await tapKey(tester, 'chatClose');

    // Trip and rating.
    await tapKey(tester, 'startTrip');
    expect(store.phase, RidePhase.onTrip);
    await settle(tester, 3000);
    expect(find.byKey(const ValueKey('ratingDone')), findsOneWidget);
    await tapKey(tester, 'ratingStar_5');
    await tapKey(tester, 'tip_5');
    await tapKey(tester, 'ratingDone');
    expect(store.phase, RidePhase.idle);
    expect(store.trips.first.id, 'new-5');
    expect(store.trips.first.tip, 5);

    // Activity: the new trip, its receipt, ride again.
    await tapKey(tester, 'tab_Atividade');
    expect(find.text('Nova'), findsOneWidget);
    await tapKey(tester, 'trip_new-5');
    expect(find.text('Recibo'), findsWidgets);
    await tapKey(tester, 'tripHelp');
    await tester.tap(find.text('OK'));
    await settle(tester);
    await tapKey(tester, 'rideAgain');
    expect(store.tab, AppTab.home);
    expect(store.phase, RidePhase.choosing);
    await tapKey(tester, 'backToHome');
    expect(store.phase, RidePhase.idle);

    // Services: hourly rental leads into search.
    await tapKey(tester, 'tab_Serviços');
    await tapKey(tester, 'service_aluguel');
    await tapKey(tester, 'rentalPlus');
    expect(find.textContaining('3 horas'), findsOneWidget);
    await tapKey(tester, 'rentalContinue');
    expect(store.selectedRideId, 'comfort');
    expect(find.byKey(const ValueKey('searchField')), findsOneWidget);
    await tapKey(tester, 'closeSearch');

    // Account: wallet, settings.
    await tapKey(tester, 'tab_Conta');
    await tapKey(tester, 'walletLink');
    await tapKey(tester, 'payment_cash');
    expect(store.payment, PaymentMethod.cash);
    await tapKey(tester, 'back');
    await tapKey(tester, 'settingsLink');
    final promos = find.descendant(of: find.byKey(const ValueKey('switch_promos')), matching: find.byType(CupertinoSwitch));
    expect(tester.widget<CupertinoSwitch>(promos).value, isFalse);
    await tester.tap(promos);
    await settle(tester);
    expect(tester.widget<CupertinoSwitch>(promos).value, isTrue);
    await tapKey(tester, 'back');
    await tapKey(tester, 'savedLink');
    await tapKey(tester, 'savedPlace_casa');
    expect(store.destination?.id, 'casa');
    expect(store.tab, AppTab.home);
  });
}
