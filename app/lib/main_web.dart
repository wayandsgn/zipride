import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'web/demo_hub.dart';

/// Browser demo: customer app, driver app and admin panel on one page.
void main() => runApp(MaterialApp(
      title: 'ITAX · Demonstração',
      debugShowCheckedModeBanner: false,
      theme: ZTheme.data(),
      locale: ZTheme.locale,
      supportedLocales: ZTheme.locales,
      localizationsDelegates: ZTheme.delegates,
      home: const DemoHub(),
    ));
