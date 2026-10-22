import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/fixtures.dart';
import '../../core/ride_store.dart';
import '../../core/theme.dart';
import '../../widgets/brand.dart';
import '../../widgets/common.dart';
import '../ride/driver_card.dart';
import '../ride/finding_driver_card.dart';
import '../ride/rating_screen.dart';
import '../ride/ride_options_panel.dart';
import '../ride/trip_progress_card.dart';
import 'home_map.dart';
import 'home_panel.dart';

/// Início: the map with a bottom panel that changes with the ride phase.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RideStore? _store;
  bool _ratingOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = StoreScope.read(context);
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

  /// Opens the rating screen when the trip ends.
  void _watch() {
    final store = _store!;
    if (store.ratingPending && !_ratingOpen) {
      _ratingOpen = true;
      Navigator.of(context)
          .push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => const RatingScreen()))
          .whenComplete(() => _ratingOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return Stack(fit: StackFit.expand, children: [
      const Positioned.fill(child: HomeMap()),
      const Positioned(top: 0, left: 0, right: 0, child: SafeArea(child: _Header())),
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
            child: KeyedSubtree(key: ValueKey(_panelKey(store.phase)), child: _panel(store.phase)),
          ),
        ),
      ),
    ]);
  }

  String _panelKey(RidePhase phase) => switch (phase) {
        RidePhase.driverEnRoute || RidePhase.driverArrived => 'driver',
        _ => phase.name,
      };

  Widget _panel(RidePhase phase) => switch (phase) {
        RidePhase.idle => const HomePanel(),
        RidePhase.choosing => const RideOptionsPanel(),
        RidePhase.matching => const FindingDriverCard(),
        RidePhase.driverEnRoute || RidePhase.driverArrived => const DriverCard(),
        RidePhase.onTrip => const TripProgressCard(),
      };
}

/// Top bar over the map: logo and profile at rest, a back button while choosing a ride.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Row(children: [
        if (store.phase == RidePhase.choosing)
          CircleIconButton(key: const ValueKey('backToHome'), icon: CupertinoIcons.arrow_left, label: 'Voltar', onTap: store.backToHome)
        else
          Container(
            padding: const EdgeInsets.fromLTRB(8, 7, 13, 7),
            decoration: BoxDecoration(
              color: ZTheme.card,
              borderRadius: BorderRadius.circular(99),
              boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 2))],
            ),
            child: const ItaxWordmark(size: 28),
          ),
        const Spacer(),
        if (store.phase == RidePhase.idle)
          Pressable(
            onTap: () => store.select(AppTab.account),
            scale: 0.92,
            semanticLabel: 'Sua conta',
            child: RemoteAvatar(url: Fixtures.userPhotoUrl, initials: 'DF', size: 44),
          ),
      ]),
    );
  }
}
