import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../core/models.dart';
import '../../core/ride_store.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/grouped.dart';
import 'trip_mini_map.dart';

/// Recibo for one trip, with "Pedir de novo" back into the ride flow.
class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return DetailPage(title: 'Recibo', background: ZTheme.surface, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(ZTheme.cardRadius),
        child: SizedBox(height: 180, child: TripMiniMap(destination: trip.destination)),
      ),
      const SizedBox(height: 18),
      Text(BR.money(trip.total), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -0.8, fontFeatures: ZText.tabular)),
      Text(BR.longDate(trip.date), style: ZText.sub),
      const SizedBox(height: 18),
      _Route(trip: trip),
      const SizedBox(height: 18),
      _Card(children: [
        ValueRow('Viagem ${trip.rideName}', BR.money(trip.fare)),
        ValueRow('Gorjeta', BR.money(trip.tip)),
        const Divider(indent: 16, endIndent: 16),
        ValueRow('Total', BR.money(trip.total), bold: true),
        ValueRow('Pago com', trip.payment.title),
      ]),
      const SizedBox(height: 14),
      _Card(children: [
        ValueRow('Motorista', trip.driverName),
        ValueRow('Sua avaliação', '★' * trip.rating),
        ValueRow('Distância', BR.km(trip.distanceKm)),
        ValueRow('Duração', '${trip.durationMinutes} min'),
      ]),
      const SizedBox(height: 20),
      PrimaryButton('Pedir de novo', key: const ValueKey('rideAgain'), onTap: () {
        final store = StoreScope.read(context);
        Navigator.of(context).pop();
        store.choose(trip.destination);
      }),
      const SizedBox(height: 10),
      SecondaryButton('Preciso de ajuda com esta viagem', key: const ValueKey('tripHelp'), onTap: () {
        showNotice(context, 'Ajuda ITAX', 'Nosso suporte responde pelo chat em até 5 minutos, todos os dias.');
      }),
    ]);
  }
}

class _Route extends StatelessWidget {
  const _Route({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: ZTheme.ink, shape: BoxShape.circle)),
          const SizedBox(height: 3),
          Container(width: 2, height: 30, color: ZTheme.tertiary),
          const SizedBox(height: 3),
          Container(width: 8, height: 8, color: ZTheme.ink),
        ]),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(trip.pickupName, style: ZText.bodyStrong),
          const SizedBox(height: 18),
          Text(trip.destination.name, style: ZText.bodyStrong),
          Text(trip.destination.address, style: ZText.foot),
        ]),
      ),
    ]);
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(color: ZTheme.fill, borderRadius: BorderRadius.circular(ZTheme.cardRadius)),
      child: Column(children: children),
    );
  }
}
