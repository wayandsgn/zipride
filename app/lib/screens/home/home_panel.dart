import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/fixtures.dart';
import '../../core/formatters.dart';
import '../../core/models.dart';
import '../../core/ride_store.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../ride/schedule_sheet.dart';
import '../ride/search_screen.dart';

/// Opens the full-screen destination search, optionally preselecting a ride type.
void openSearch(BuildContext context, {String? rideId}) {
  final store = StoreScope.read(context);
  if (rideId != null) store.selectRide(rideId);
  store.select(AppTab.home);
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => const SearchScreen()),
  );
}

void openSchedule(BuildContext context) {
  StoreScope.read(context).select(AppTab.home);
  showZSheet<void>(context, (_) => const ScheduleSheet());
}

/// Resting panel: "Para onde?", shortcuts, saved places and recent trips.
class HomePanel extends StatelessWidget {
  const HomePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return MapPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        const Grabber(),
        const SizedBox(height: 12),
        Text('${BR.greeting(DateTime.now())}, ${Fixtures.userFirstName}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
        const SizedBox(height: 14),
        const _WhereToPill(),
        const SizedBox(height: 14),
        Row(children: [
          _Shortcut('Viagem', CupertinoIcons.car_fill, () => openSearch(context, rideId: 'x')),
          const SizedBox(width: 10),
          _Shortcut('Moto', CupertinoIcons.speedometer, () => openSearch(context, rideId: 'moto')),
          const SizedBox(width: 10),
          _Shortcut('Agendar', CupertinoIcons.calendar_badge_plus, () => openSchedule(context)),
          const SizedBox(width: 10),
          _Shortcut('Entrega', CupertinoIcons.cube_box_fill, () => openSearch(context, rideId: 'moto')),
        ]),
        const SizedBox(height: 14),
        const Row(children: [
          Expanded(child: _SavedChip(place: Fixtures.home)),
          SizedBox(width: 10),
          Expanded(child: _SavedChip(place: Fixtures.work)),
        ]),
        const SizedBox(height: 6),
        for (final (i, place) in Fixtures.recents.indexed) ...[
          if (i > 0) const Divider(indent: 52),
          PlaceRow(
            key: ValueKey('recent_${place.id}'),
            place: place,
            icon: CupertinoIcons.clock,
            onTap: () => StoreScope.read(context).choose(place),
          ),
        ],
      ]),
    );
  }
}

class _WhereToPill extends StatelessWidget {
  const _WhereToPill();

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return Container(
      height: 56,
      decoration: BoxDecoration(color: ZTheme.fill2, borderRadius: BorderRadius.circular(99)),
      child: Row(children: [
        Expanded(
          child: Pressable(
            key: const ValueKey('whereTo'),
            onTap: () => openSearch(context),
            child: const Padding(
              padding: EdgeInsets.only(left: 18),
              child: Row(children: [
                Icon(CupertinoIcons.search, size: 20, color: ZTheme.ink),
                SizedBox(width: 12),
                Text('Para onde?', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
        Pressable(
          key: const ValueKey('scheduleChip'),
          onTap: () => openSchedule(context),
          scale: 0.94,
          child: Container(
            height: 38,
            margin: const EdgeInsets.only(right: 9),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99)),
            child: Row(children: [
              const Icon(CupertinoIcons.clock_fill, size: 15),
              const SizedBox(width: 6),
              Text(store.scheduleLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              const Icon(CupertinoIcons.chevron_down, size: 12),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut(this.title, this.icon, this.onTap);

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Pressable(
        key: ValueKey('shortcut_$title'),
        onTap: onTap,
        scale: 0.94,
        child: Container(
          height: 72,
          decoration: BoxDecoration(color: ZTheme.fill2, borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 24),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

class _SavedChip extends StatelessWidget {
  const _SavedChip({required this.place});
  final Place place;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      key: ValueKey('saved_${place.id}'),
      onTap: () => StoreScope.read(context).choose(place),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(border: Border.all(color: ZTheme.hairline), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(color: ZTheme.accent, shape: BoxShape.circle),
            child: Icon(place.icon, size: 15, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(place.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Text(place.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: ZText.caption),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// One place in a list: icon, name, address and road distance.
class PlaceRow extends StatelessWidget {
  const PlaceRow({super.key, required this.place, required this.onTap, this.icon});

  final Place place;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(color: ZTheme.fill2, shape: BoxShape.circle),
            child: Icon(icon ?? place.icon, size: 17),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(place.name, style: ZText.bodyStrong),
              const SizedBox(height: 2),
              Text(place.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: ZText.sub),
            ]),
          ),
          const SizedBox(width: 8),
          Text(BR.km(place.distanceKm), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ZTheme.secondary, fontFeatures: ZText.tabular)),
        ]),
      ),
    );
  }
}
