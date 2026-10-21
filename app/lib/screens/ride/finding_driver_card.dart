import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../core/ride_store.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/markers.dart';

/// Shown for ~3 s while the radar pulses on the pickup point.
class FindingDriverCard extends StatefulWidget {
  const FindingDriverCard({super.key});

  @override
  State<FindingDriverCard> createState() => _FindingDriverCardState();
}

class _FindingDriverCardState extends State<FindingDriverCard> with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return MapPanel(
      padding: const EdgeInsets.all(18),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('Procurando seu motorista', textAlign: TextAlign.center, style: ZText.title),
        const SizedBox(height: 4),
        Text('Buscando ${store.selectedRide.name} perto da Praça da Matriz', textAlign: TextAlign.center, style: ZText.sub),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 5,
            child: LayoutBuilder(
              builder: (context, box) => Stack(children: [
                Container(color: ZTheme.fill2),
                AnimatedBuilder(
                  animation: _sweep,
                  builder: (context, _) => Positioned(
                    left: box.maxWidth * 0.65 * Curves.easeInOut.transform(_sweep.value),
                    width: box.maxWidth * 0.35,
                    top: 0,
                    bottom: 0,
                    child: Container(decoration: BoxDecoration(color: ZTheme.accent, borderRadius: BorderRadius.circular(3))),
                  ),
                ),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
          RideIllustration(ride: store.selectedRide),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(store.destination?.name ?? '', style: ZText.bodyStrong),
              Text('${store.payment.title} · ${BR.money(store.priceOf(store.selectedRide))}', style: ZText.foot),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        SecondaryButton('Cancelar', key: const ValueKey('cancelSearch'), onTap: store.cancelRide),
      ]),
    );
  }
}
