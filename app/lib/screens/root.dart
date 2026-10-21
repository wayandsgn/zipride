import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/ride_store.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'home/home_screen.dart';
import 'tabs/account_screen.dart';
import 'tabs/activity_screen.dart';
import 'tabs/services_screen.dart';

/// Four tabs under a floating glass tab bar, in the iOS 26 style.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

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
        const Positioned(left: 14, right: 14, bottom: 0, child: SafeArea(top: false, minimum: EdgeInsets.only(bottom: 14), child: _TabBar())),
      ]),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar();

  static const _items = [
    (AppTab.home, 'Início', CupertinoIcons.house_fill),
    (AppTab.services, 'Serviços', CupertinoIcons.square_grid_2x2_fill),
    (AppTab.activity, 'Atividade', CupertinoIcons.list_bullet_below_rectangle),
    (AppTab.account, 'Conta', CupertinoIcons.person_crop_circle_fill),
  ];

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(31),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 62,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(31),
            border: Border.all(color: ZTheme.hairline),
          ),
          child: Row(children: [
            for (final (tab, label, icon) in _items)
              Expanded(
                child: Pressable(
                  onTap: () => store.select(tab),
                  haptic: false,
                  scale: 0.92,
                  semanticLabel: label,
                  child: AnimatedContainer(
                    key: ValueKey('tab_$label'),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: store.tab == tab ? ZTheme.accentSoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(27),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(icon, size: 22, color: store.tab == tab ? ZTheme.accent : const Color(0xFF555555)),
                      const SizedBox(height: 2),
                      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: store.tab == tab ? ZTheme.accent : const Color(0xFF555555))),
                    ]),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

/// Bottom space every scrolling tab leaves for the floating tab bar.
const tabBarClearance = 110.0;
