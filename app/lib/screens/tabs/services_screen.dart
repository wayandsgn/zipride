import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/fixtures.dart';
import '../../core/formatters.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/grouped.dart';
import '../home/home_panel.dart';

/// Serviços: every way to ride in Itapipoca; each tile leads into the ride flow.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  Future<void> _open(BuildContext context, ServiceTile tile) async {
    final rideId = tile.rideTypeId;
    if (rideId != null) {
      openSearch(context, rideId: rideId);
    } else if (tile.id == 'agendar') {
      openSchedule(context);
    } else {
      final go = await showZSheet<bool>(context, (_) => const _RentalSheet());
      if (go == true && context.mounted) openSearch(context, rideId: 'comfort');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LargeTitlePage(title: 'Serviços', children: [
      const _Banner(),
      const SizedBox(height: 22),
      const Text('Vá a qualquer lugar', style: ZText.title),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.32,
        children: [
          for (final tile in Fixtures.services)
            Pressable(
              key: ValueKey('service_${tile.id}'),
              onTap: () => _open(context, tile),
              scale: 0.96,
              semanticLabel: tile.title,
              child: _ServiceCard(tile: tile),
            ),
        ],
      ),
    ]);
  }
}

class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    const gradient = DecoratedBox(
      decoration: BoxDecoration(gradient: LinearGradient(colors: [ZTheme.accent, Colors.black], begin: Alignment.topLeft, end: Alignment.bottomRight)),
    );
    return Pressable(
      key: const ValueKey('servicesBanner'),
      onTap: () => openSearch(context, rideId: 'moto'),
      scale: 0.98,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ZTheme.cardRadius),
        child: SizedBox(
          height: 170,
          child: Stack(fit: StackFit.expand, children: [
            Image.network(
              Fixtures.servicesBannerUrl,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, sync) => frame == null && !sync ? gradient : child,
              errorBuilder: (context, error, stack) => gradient,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Color(0xC0000000)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('ITAX Moto', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 2),
                Text('Do Centro à Rodoviária a partir de ${BR.money(5.90)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.tile});
  final ServiceTile tile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: ZTheme.fill, borderRadius: BorderRadius.circular(ZTheme.cardRadius)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: ZTheme.accentSoft, borderRadius: BorderRadius.circular(14)),
          child: Icon(tile.icon, size: 25, color: ZTheme.ink),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tile.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          Text(tile.subtitle, style: ZText.foot, maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ]),
    );
  }
}

/// Hourly rental: pick the hours, see the price, then choose where to start.
class _RentalSheet extends StatefulWidget {
  const _RentalSheet();

  @override
  State<_RentalSheet> createState() => _RentalSheetState();
}

class _RentalSheetState extends State<_RentalSheet> {
  int _hours = 2;

  void _change(int delta) {
    final next = (_hours + delta).clamp(1, 8);
    if (next == _hours) return;
    HapticFeedback.selectionClick();
    setState(() => _hours = next);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Grabber(),
          const SizedBox(height: 18),
          const Text('Motorista por hora', style: ZText.title),
          const SizedBox(height: 6),
          const Text('Um Comfort fica com você para várias paradas: banco, feira, cartório.', style: ZText.sub),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, a) => FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(a), child: child)),
                child: Text(
                  '$_hours hora${_hours > 1 ? 's' : ''} · ${BR.money(_hours * 38.0)}',
                  key: ValueKey(_hours),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, fontFeatures: ZText.tabular),
                ),
              ),
            ),
            _Stepper(onMinus: _hours > 1 ? () => _change(-1) : null, onPlus: _hours < 8 ? () => _change(1) : null),
          ]),
          const SizedBox(height: 24),
          PrimaryButton('Escolher primeiro destino', key: const ValueKey('rentalContinue'), onTap: () => Navigator.of(context).pop(true)),
        ]),
      ),
    );
  }
}

/// iOS-style minus/plus stepper.
class _Stepper extends StatelessWidget {
  const _Stepper({required this.onMinus, required this.onPlus});
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    Widget half(IconData icon, VoidCallback? onTap, String key) => Pressable(
          key: ValueKey(key),
          onTap: onTap,
          haptic: false,
          scale: 0.9,
          child: SizedBox(width: 46, height: 34, child: Icon(icon, size: 18, color: onTap == null ? ZTheme.tertiary : ZTheme.ink)),
        );
    return Container(
      decoration: BoxDecoration(color: ZTheme.fill2, borderRadius: BorderRadius.circular(9)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        half(CupertinoIcons.minus, onMinus, 'rentalMinus'),
        Container(width: 1, height: 18, color: ZTheme.tertiary),
        half(CupertinoIcons.plus, onPlus, 'rentalPlus'),
      ]),
    );
  }
}
