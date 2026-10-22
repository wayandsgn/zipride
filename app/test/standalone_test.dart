import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zipride/core/theme.dart';
import 'package:zipride/web/standalone.dart';

import 'helpers.dart';

Widget _page(StandaloneKind kind) => MaterialApp(
      theme: ZTheme.data(),
      locale: ZTheme.locale,
      supportedLocales: ZTheme.locales,
      localizationsDelegates: ZTheme.delegates,
      home: StandaloneApp(kind: kind),
    );

void main() {
  setUpAll(loadTestFonts);

  testWidgets('each app opens on its own page, framed on a computer', (tester) async {
    setScreen(tester, const Size(1440, 900));

    await tester.pumpWidget(_page(StandaloneKind.rider));
    await settle(tester);
    expect(find.text('Para onde?'), findsOneWidget);
    expect(find.text('ITAX'), findsWidgets);

    await tester.pumpWidget(_page(StandaloneKind.driver));
    await settle(tester);
    expect(find.text('Você está offline'), findsOneWidget);
    expect(find.text('ITAX Motorista'), findsOneWidget);

    await tester.pumpWidget(_page(StandaloneKind.admin));
    await settle(tester);
    expect(find.text('Visão geral'), findsWidgets);
    expect(find.text('Cliente + Motorista'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
  });

  testWidgets('on a phone-sized window the app fills the screen', (tester) async {
    setScreen(tester, const Size(393, 852), ratio: 3);
    await tester.pumpWidget(_page(StandaloneKind.rider));
    await settle(tester);
    expect(find.text('Para onde?'), findsOneWidget);
    expect(find.text('ITAX Motorista'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
  });
}
