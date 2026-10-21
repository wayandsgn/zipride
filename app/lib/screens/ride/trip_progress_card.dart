import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/fixtures.dart';
import '../../core/formatters.dart';
import '../../core/ride_store.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

/// On the way to the destination: progress bar, ETA and trip details.
class TripProgressCard extends StatelessWidget {
  const TripProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final ride = store.selectedRide;
    return MapPanel(
      padding: const EdgeInsets.all(18),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Indo para ${store.destination?.name ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: ZText.title),
              const SizedBox(height: 2),
              Text('Chegada às ${BR.time(store.tripArrivalTime)}', style: ZText.sub),
            ]),
          ),
          const SizedBox(width: 10),
          Text('${store.tripRemainingMinutes} min', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: ZTheme.accent)),
        ]),
        const SizedBox(height: 14),
        Semantics(
          label: 'Progresso da viagem',
          value: '${(store.tripProgress * 100).round()}%',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(value: store.tripProgress.clamp(0.03, 1), minHeight: 6, color: ZTheme.accent, backgroundColor: ZTheme.fill2),
          ),
        ),
        const SizedBox(height: 14),
        Row(children: [
          RemoteAvatar(url: Fixtures.driver.photoUrl, initials: 'M', size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${Fixtures.driver.name} · ${Fixtures.driver.plate}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Text('${ride.name} · ${store.payment.title} · ${BR.money(store.priceOf(ride))}', maxLines: 1, overflow: TextOverflow.ellipsis, style: ZText.foot),
            ]),
          ),
          Pressable(
            onTap: () => showNotice(context, 'Viagem compartilhada', 'Seus contatos de confiança acompanham a rota até ${store.destination?.name ?? 'o destino'}.'),
            scale: 0.9,
            semanticLabel: 'Compartilhar viagem',
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: ZTheme.fill2, shape: BoxShape.circle),
              child: const Icon(CupertinoIcons.share, size: 18),
            ),
          ),
        ]),
      ]),
    );
  }
}
