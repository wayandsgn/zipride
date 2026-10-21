import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zipride/widgets/map_tiles.dart';

/// Loads the real Inter files so text measures the same as on a phone, and turns map tiles off.
Future<void> loadTestFonts() async {
  MapTiles.enabled = false;
  final loader = FontLoader('Inter');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold', 'Black']) {
    final bytes = File('assets/fonts/Inter-$w.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

void setScreen(WidgetTester tester, Size logical, {double ratio = 1}) {
  tester.view.physicalSize = logical * ratio;
  tester.view.devicePixelRatio = ratio;
  addTearDown(tester.view.reset);
}

/// Pumps frames for [ms] milliseconds of fake time (the maps tick forever, so no pumpAndSettle).
Future<void> settle(WidgetTester tester, [int ms = 500]) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).last);
  }
  expect(finder, findsOneWidget, reason: 'missing $key');
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(finder);
  await settle(tester);
}
