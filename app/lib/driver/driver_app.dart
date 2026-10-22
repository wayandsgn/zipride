import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/driver_store.dart';
import '../core/theme.dart';
import '../widgets/glass_tab_bar.dart';
import 'driver_home.dart';
import 'driver_tabs.dart';

/// ITAX Motorista: the driver's side of a ride.
class DriverApp extends StatelessWidget {
  const DriverApp({super.key, required this.store});

  final DriverStore store;

  @override
  Widget build(BuildContext context) {
    return DriverScope(
      store: store,
      child: MaterialApp(
        title: 'ITAX Motorista',
        debugShowCheckedModeBanner: false,
        theme: ZTheme.data(),
        locale: ZTheme.locale,
        supportedLocales: ZTheme.locales,
        localizationsDelegates: ZTheme.delegates,
        home: const _DriverRoot(),
      ),
    );
  }
}

class _DriverRoot extends StatelessWidget {
  const _DriverRoot();

  static const _items = [
    ('Início', CupertinoIcons.car_detailed),
    ('Ganhos', CupertinoIcons.chart_bar_alt_fill),
    ('Conta', CupertinoIcons.person_crop_circle_fill),
  ];

  @override
  Widget build(BuildContext context) {
    final store = DriverScope.of(context);
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        IndexedStack(
          index: store.tab.index,
          sizing: StackFit.expand,
          children: const [DriverHome(), DriverEarnings(), DriverAccount()],
        ),
        Positioned(
          left: 14,
          right: 14,
          bottom: 0,
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 14),
            child: GlassTabBar(items: _items, selected: store.tab.index, onSelect: (i) => store.select(DriverTab.values[i])),
          ),
        ),
      ]),
    );
  }
}
