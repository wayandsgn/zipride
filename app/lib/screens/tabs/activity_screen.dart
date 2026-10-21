import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../core/models.dart';
import '../../core/ride_store.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/grouped.dart';
import 'receipt_screen.dart';
import 'trip_mini_map.dart';

/// Atividade: past trips with a mini route map; each opens its receipt.
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return LargeTitlePage(title: 'Atividade', children: [
      const Padding(padding: EdgeInsets.fromLTRB(4, 0, 0, 10), child: SectionLabel('Viagens anteriores')),
      for (final trip in store.trips)
        Padding(
          key: ValueKey('row_${trip.id}'),
          padding: const EdgeInsets.only(bottom: 14),
          child: _TripRow(trip: trip, isNew: trip.id == store.lastCompletedTripId),
        ),
    ]);
  }
}

class _TripRow extends StatelessWidget {
  const _TripRow({required this.trip, required this.isNew});

  final Trip trip;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      key: ValueKey('trip_${trip.id}'),
      scale: 0.98,
      semanticLabel: trip.destination.name,
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(builder: (_) => ReceiptScreen(trip: trip)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ZTheme.cardRadius),
        child: ColoredBox(
          color: ZTheme.fill,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              height: 120,
              child: Stack(fit: StackFit.expand, children: [
                TripMiniMap(destination: trip.destination),
                if (isNew)
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: const ShapeDecoration(color: ZTheme.accent, shape: StadiumBorder()),
                      child: const Text('Nova', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(trip.destination.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text('${BR.shortDate(trip.date)} · ${BR.time(trip.date)} · ${trip.rideName}', style: ZText.sub),
                  ]),
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(BR.money(trip.total), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, fontFeatures: ZText.tabular)),
                  const SizedBox(height: 3),
                  const Row(children: [
                    Text('Recibo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ZTheme.accent)),
                    SizedBox(width: 2),
                    Icon(CupertinoIcons.chevron_forward, size: 13, color: ZTheme.accent),
                  ]),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
