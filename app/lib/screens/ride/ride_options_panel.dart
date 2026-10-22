import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/fixtures.dart';
import '../../core/formatters.dart';
import '../../core/models.dart';
import '../../core/ride_store.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/markers.dart';
import 'payment_sheet.dart';

/// Ride options for the chosen destination, with payment and the confirm button.
class RideOptionsPanel extends StatelessWidget {
  const RideOptionsPanel({super.key});

  static const _rowHeight = 70.0;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final selectedIndex = Fixtures.rideTypes.indexWhere((r) => r.id == store.selectedRideId);
    final listHeight = MediaQuery.sizeOf(context).height < 760 ? 220.0 : 300.0;
    return MapPanel(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Grabber(),
        const SizedBox(height: 10),
        const Text('Escolha uma viagem', textAlign: TextAlign.center, style: ZText.title),
        const SizedBox(height: 3),
        Text(
          '${store.destination?.name ?? ''} · ${BR.km(store.tripKm)} · ${store.tripMinutes} min',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ZText.sub,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: listHeight,
          child: SingleChildScrollView(
            child: Stack(children: [
              // The selection outline slides between rows like a matched-geometry highlight.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                top: selectedIndex * _rowHeight,
                left: 0,
                right: 0,
                height: _rowHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: ZTheme.accentSoft,
                    border: Border.all(color: ZTheme.ink, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Column(children: [for (final ride in Fixtures.rideTypes) _RideRow(ride: ride, height: _rowHeight)]),
            ]),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(children: [
            Pressable(
              key: const ValueKey('paymentRow'),
              onTap: () => showZSheet<void>(context, (_) => const PaymentSheet()),
              child: SizedBox(
                height: 46,
                child: Row(children: [
                  SizedBox(width: 28, child: Icon(paymentIcon(store.payment), size: 18, color: ZTheme.accent)),
                  const SizedBox(width: 8),
                  Text(store.payment.title, style: ZText.bodyStrong),
                  if (store.scheduleLabel != 'Agora') Text('  · ${store.scheduleLabel}', style: ZText.sub),
                  const Spacer(),
                  const Icon(CupertinoIcons.chevron_right, size: 14, color: ZTheme.secondary),
                ]),
              ),
            ),
            const SizedBox(height: 6),
            PrimaryButton('Escolher ${store.selectedRide.name}', key: const ValueKey('confirmRide'), onTap: store.confirmRide),
          ]),
        ),
      ]),
    );
  }
}

class _RideRow extends StatelessWidget {
  const _RideRow({required this.ride, required this.height});

  final RideType ride;
  final double height;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final selected = ride.id == store.selectedRideId;
    final dropoff = DateTime.now().add(Duration(minutes: ride.etaMinutes + store.tripMinutes));
    return Pressable(
      key: ValueKey('rideOption_${ride.id}'),
      onTap: () => store.selectRide(ride.id),
      haptic: false,
      scale: 0.98,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(children: [
            RideIllustration(ride: ride),
            const SizedBox(width: 12),
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(ride.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  const Icon(CupertinoIcons.person_fill, size: 11, color: ZTheme.secondary),
                  Text('${ride.seats}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ZTheme.secondary)),
                ]),
                Text('${ride.etaMinutes} min · chega às ${BR.time(dropoff)}', style: ZText.foot, maxLines: 1, overflow: TextOverflow.ellipsis),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  child: selected ? Text(ride.tagline, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: ZTheme.accent)) : const SizedBox.shrink(),
                ),
              ]),
            ),
            Text(BR.money(store.priceOf(ride)), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, fontFeatures: ZText.tabular)),
          ]),
        ),
      ),
    );
  }
}

IconData paymentIcon(PaymentMethod method) => switch (method) {
      PaymentMethod.pix => CupertinoIcons.qrcode,
      PaymentMethod.visa => CupertinoIcons.creditcard_fill,
      PaymentMethod.cash => CupertinoIcons.money_dollar_circle_fill,
    };
