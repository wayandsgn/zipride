import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zipride/core/ride_store.dart';
import 'package:zipride/main.dart';

/// Runs the real app on a device or emulator and screenshots every screen of the demo.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  var shot = 0;

  Future<void> wait(WidgetTester tester, int ms) async {
    final end = DateTime.now().add(Duration(milliseconds: ms));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 16));
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }

  Future<void> snap(WidgetTester tester, String name) async {
    await wait(tester, 700);
    shot++;
    await binding.takeScreenshot('${shot.toString().padLeft(2, '0')}_$name');
  }

  Future<void> tap(WidgetTester tester, String key) async {
    final finder = find.byKey(ValueKey(key));
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).last);
    }
    expect(finder, findsOneWidget, reason: 'missing $key');
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await wait(tester, 600);
  }

  testWidgets('ITAX demo on Android', (tester) async {
    final store = RideStore(timeScale: 1.5);
    await tester.pumpWidget(ItaxApp(store: store));
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
    await wait(tester, 4000); // map tiles and photos load
    await snap(tester, 'inicio');

    await tap(tester, 'scheduleChip');
    await snap(tester, 'agendar');
    await tap(tester, 'scheduleDone');

    await tap(tester, 'whereTo');
    await snap(tester, 'busca');
    await tester.enterText(find.byKey(const ValueKey('searchField')), 'praia');
    await snap(tester, 'busca_praia');
    await tap(tester, 'place_baleia');
    await wait(tester, 1500);
    await snap(tester, 'opcoes_de_corrida');

    await tap(tester, 'rideOption_moto');
    await snap(tester, 'moto_selecionada');
    await tap(tester, 'paymentRow');
    await snap(tester, 'pagamento');
    await tap(tester, 'payment_pix');
    await tap(tester, 'paymentDone');

    await tap(tester, 'confirmRide');
    await snap(tester, 'procurando_motorista');
    await wait(tester, 2500);
    await snap(tester, 'motorista_a_caminho');

    await tap(tester, 'messageButton');
    await tap(tester, 'quickReply_0');
    await wait(tester, 1200);
    await snap(tester, 'chat');
    await tap(tester, 'chatClose');

    await tap(tester, 'startTrip');
    await wait(tester, 2500);
    await snap(tester, 'em_viagem');
    await wait(tester, 4500);
    expect(find.byKey(const ValueKey('ratingDone')), findsOneWidget);
    await snap(tester, 'avaliacao');
    await tap(tester, 'ratingStar_5');
    await tap(tester, 'tip_5');
    await snap(tester, 'avaliacao_gorjeta');
    await tap(tester, 'ratingDone');

    await tap(tester, 'tab_Atividade');
    await wait(tester, 2000);
    await snap(tester, 'atividade');
    await tap(tester, 'trip_new-5');
    await wait(tester, 1500);
    await snap(tester, 'recibo');
    await tap(tester, 'back');
    await wait(tester, 600);

    await tap(tester, 'tab_Serviços');
    await wait(tester, 1500);
    await snap(tester, 'servicos');
    await tap(tester, 'service_aluguel');
    await snap(tester, 'aluguel');
    await tester.tapAt(const Offset(200, 100)); // dismiss the sheet
    await wait(tester, 600);

    await tap(tester, 'tab_Conta');
    await snap(tester, 'conta');
    await tap(tester, 'walletLink');
    await snap(tester, 'carteira');
    await tap(tester, 'back');
    await tap(tester, 'settingsLink');
    await snap(tester, 'configuracoes');
    await tap(tester, 'back');

    await tap(tester, 'tab_Início');
    await snap(tester, 'inicio_final');
  });
}
