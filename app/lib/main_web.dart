import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'web/app_choice.dart';
import 'web/demo_hub.dart';
import 'web/standalone.dart';

/// Browser entry: the demo hub with all three apps, or one app on its own
/// when the page asks for it (cliente, motorista or admin).
void main() {
  final kind = switch (pageAppChoice()) {
    'cliente' => StandaloneKind.rider,
    'motorista' => StandaloneKind.driver,
    'admin' => StandaloneKind.admin,
    _ => null,
  };
  runApp(MaterialApp(
    title: switch (kind) {
      StandaloneKind.rider => 'ITAX',
      StandaloneKind.driver => 'ITAX Motorista',
      StandaloneKind.admin => 'ITAX Admin',
      null => 'ITAX · Demonstração',
    },
    debugShowCheckedModeBanner: false,
    theme: ZTheme.data(),
    locale: ZTheme.locale,
    supportedLocales: ZTheme.locales,
    localizationsDelegates: ZTheme.delegates,
    home: kind == null ? const DemoHub() : StandaloneApp(kind: kind),
  ));
}
