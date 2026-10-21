import 'package:flutter/material.dart';

import '../core/driver_store.dart';
import '../core/fixtures.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'driver_map.dart';
import 'driver_panels.dart';

/// Driver home: map, today's earnings on top and the panel for the current phase.
class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  DriverStore? _store;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = DriverScope.read(context);
    if (_store != store) {
      _store?.removeListener(_watch);
      _store = store..addListener(_watch);
    }
  }

  @override
  void dispose() {
    _store?.removeListener(_watch);
    super.dispose();
  }

  /// Shows one-off notices (missed ride, passenger cancelled) as a snackbar.
  void _watch() {
    final message = _store!.notice;
    if (message == null || !mounted) return;
    _store!.notice = null;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: ZTheme.ink,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final store = DriverScope.of(context);
    return Stack(fit: StackFit.expand, children: [
      const Positioned.fill(child: DriverMap()),
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Row(children: [
              _OnlineDot(online: store.phase != DriverPhase.offline),
              const Spacer(),
              Pressable(
                key: const ValueKey('earningsPill'),
                onTap: () => store.select(DriverTab.earnings),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(color: ZTheme.ink, borderRadius: BorderRadius.circular(99)),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      BR.money(store.earningsToday),
                      key: ValueKey(store.earningsToday),
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, fontFeatures: ZText.tabular),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Pressable(
                onTap: () => store.select(DriverTab.account),
                semanticLabel: 'Sua conta',
                child: RemoteAvatar(url: Fixtures.driver.photoUrl, initials: 'M', size: 44),
              ),
            ]),
          ),
        ),
      ),
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 92),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(position: Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(animation), child: child),
            ),
            layoutBuilder: (current, previous) => Stack(alignment: Alignment.bottomCenter, children: [...previous, ?current]),
            child: KeyedSubtree(
              key: ValueKey(store.phase == DriverPhase.atPickup ? DriverPhase.toPickup : store.phase),
              child: driverPanel(store),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot({required this.online});
  final bool online;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
        boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: online ? ZTheme.accent : ZTheme.tertiary),
        ),
        const SizedBox(width: 7),
        Text(online ? 'Online' : 'Offline', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
