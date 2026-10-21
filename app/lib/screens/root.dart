import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/ride_store.dart';
import '../widgets/glass_tab_bar.dart';
import 'home/home_screen.dart';
import 'tabs/account_screen.dart';
import 'tabs/activity_screen.dart';
import 'tabs/services_screen.dart';

/// Four tabs under a floating glass tab bar, in the iOS 26 style.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  static const _items = [
    ('Início', CupertinoIcons.house_fill),
    ('Serviços', CupertinoIcons.square_grid_2x2_fill),
    ('Atividade', CupertinoIcons.list_bullet_below_rectangle),
    ('Conta', CupertinoIcons.person_crop_circle_fill),
  ];

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        IndexedStack(
          index: store.tab.index,
          sizing: StackFit.expand,
          children: const [HomeScreen(), ServicesScreen(), ActivityScreen(), AccountScreen()],
        ),
        Positioned(
          left: 14,
          right: 14,
          bottom: 0,
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 14),
            child: GlassTabBar(items: _items, selected: store.tab.index, onSelect: (i) => store.select(AppTab.values[i])),
          ),
        ),
      ]),
    );
  }
}

/// Bottom space every scrolling tab leaves for the floating tab bar.
const tabBarClearance = 110.0;
