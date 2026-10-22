import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/driver_store.dart';
import '../core/formatters.dart';
import '../core/geo.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../screens/ride/ride_options_panel.dart' show paymentIcon;
import '../widgets/common.dart';

/// Bottom panel of the driver home for the current phase. Each panel keeps its own copy
/// of the request so it can still draw while it animates out after the ride is cleared.
Widget driverPanel(DriverStore store) {
  final r = store.request;
  if (r == null) return store.phase == DriverPhase.offline ? const _OfflinePanel() : const _SearchingPanel();
  return switch (store.phase) {
    DriverPhase.offline => const _OfflinePanel(),
    DriverPhase.searching => const _SearchingPanel(),
    DriverPhase.request => _RequestCard(r),
    DriverPhase.toPickup || DriverPhase.atPickup => _PickupPanel(r),
    DriverPhase.onTrip => _TripPanel(r),
    DriverPhase.finished => _FinishedPanel(r),
  };
}

class _OfflinePanel extends StatelessWidget {
  const _OfflinePanel();

  @override
  Widget build(BuildContext context) {
    final store = DriverScope.of(context);
    return MapPanel(
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Grabber(),
        const SizedBox(height: 14),
        const Text('Você está offline', style: ZText.title, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        const Text('Fique online para receber corridas em Itapipoca.', style: ZText.sub, textAlign: TextAlign.center),
        const SizedBox(height: 18),
        Row(children: [
          _Stat('${store.tripsToday}', 'corridas hoje'),
          _Stat(BR.rating(4.92), 'avaliação'),
          const _Stat('96%', 'aceitação'),
        ]),
        const SizedBox(height: 18),
        PrimaryButton('Ficar online', key: const ValueKey('goOnline'), color: ZTheme.accent, onTap: store.goOnline),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, fontFeatures: ZText.tabular)),
        Text(label, style: ZText.caption),
      ]),
    );
  }
}

class _SearchingPanel extends StatelessWidget {
  const _SearchingPanel();

  @override
  Widget build(BuildContext context) {
    final store = DriverScope.of(context);
    return MapPanel(
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Grabber(),
        const SizedBox(height: 14),
        const Row(children: [
          Icon(CupertinoIcons.dot_radiowaves_left_right, color: ZTheme.accent),
          SizedBox(width: 10),
          Text('Procurando corridas…', style: ZText.title),
        ]),
        const SizedBox(height: 6),
        const Text('Mais pedidos agora: Centro e Rodoviária.', style: ZText.sub),
        const SizedBox(height: 14),
        const ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          child: LinearProgressIndicator(minHeight: 4, color: ZTheme.accent, backgroundColor: ZTheme.fill2),
        ),
        const SizedBox(height: 18),
        SecondaryButton('Ficar offline', key: const ValueKey('goOffline'), onTap: store.goOffline),
      ]),
    );
  }
}

/// Incoming ride with a 15 second countdown ring.
class _RequestCard extends StatelessWidget {
  const _RequestCard(this.r);
  final DriverRequest r;

  @override
  Widget build(BuildContext context) {
    final store = DriverScope.of(context);
    final pickupKm = Geo.length(store.approach) / 1000;
    return MapPanel(
      padding: const EdgeInsets.all(18),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: const ShapeDecoration(color: ZTheme.ink, shape: StadiumBorder()),
            child: Text(r.rideName, style: const TextStyle(color: ZTheme.onInk, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
          if (r.linked) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: const ShapeDecoration(color: ZTheme.accentSoft, shape: StadiumBorder()),
              child: const Text('Do app do cliente', style: TextStyle(color: ZTheme.accent, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(value: store.countdown, strokeWidth: 4, color: ZTheme.accent, backgroundColor: ZTheme.fill2),
              Text('${(store.countdown * 15).ceil()}', style: const TextStyle(fontWeight: FontWeight.w800, fontFeatures: ZText.tabular)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Text(BR.money(r.driverShare), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1, fontFeatures: ZText.tabular)),
        Text('${BR.km(pickupKm)} até o passageiro · viagem de ${BR.km(r.tripKm)} (${r.tripMinutes} min)', style: ZText.sub),
        const SizedBox(height: 14),
        _Stop(icon: CupertinoIcons.circle_fill, title: r.pickup.name, subtitle: r.pickup.address),
        const SizedBox(height: 8),
        _Stop(icon: CupertinoIcons.square_fill, title: r.destination.name, subtitle: r.destination.address),
        const SizedBox(height: 12),
        Row(children: [
          const Icon(CupertinoIcons.person_fill, size: 15, color: ZTheme.secondary),
          const SizedBox(width: 6),
          Text('${r.passenger} · ★ ${BR.rating(r.passengerRating)}', style: ZText.foot),
          const Spacer(),
          Icon(paymentIcon(r.payment), size: 15, color: ZTheme.secondary),
          const SizedBox(width: 4),
          Text(r.payment == PaymentMethod.visa ? 'Cartão' : r.payment.title, style: ZText.foot),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: SecondaryButton('Recusar', key: const ValueKey('declineRide'), onTap: store.decline)),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: PrimaryButton('Aceitar', key: const ValueKey('acceptRide'), color: ZTheme.accent, onTap: store.accept)),
        ]),
      ]),
    );
  }
}

class _Stop extends StatelessWidget {
  const _Stop({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 10),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: ZText.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(subtitle, style: ZText.foot, maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    ]);
  }
}

class _PickupPanel extends StatelessWidget {
  const _PickupPanel(this.r);
  final DriverRequest r;

  @override
  Widget build(BuildContext context) {
    final store = DriverScope.of(context);
    final arrived = store.phase == DriverPhase.atPickup;
    return MapPanel(
      padding: const EdgeInsets.all(18),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(arrived ? 'Você chegou' : 'Buscando ${r.passenger}', style: ZText.title),
        const SizedBox(height: 2),
        Text(arrived ? '${r.passenger} foi avisado(a) que você está no local.' : 'Chega em ${store.minutesLeft} min · ${r.pickup.name}', style: ZText.sub),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(value: arrived ? 1 : store.progress, minHeight: 4, color: ZTheme.accent, backgroundColor: ZTheme.fill2),
        ),
        const SizedBox(height: 14),
        Row(children: [
          InitialsAvatar(r.passenger, size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.passenger, style: ZText.bodyStrong),
              Text('★ ${BR.rating(r.passengerRating)} · ${r.pickup.address}', style: ZText.foot, maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          CircleIconButton(icon: CupertinoIcons.chat_bubble_fill, label: 'Mensagem', onTap: () => showNotice(context, 'Mensagem enviada', '"Estou chegando, aguarde no ponto." foi enviada para ${r.passenger}.')),
          const SizedBox(width: 8),
          CircleIconButton(icon: CupertinoIcons.phone_fill, label: 'Ligar', onTap: () => showNotice(context, 'Ligação protegida', 'Na demonstração a ligação não é feita. No app real o número fica oculto.')),
        ]),
        const SizedBox(height: 16),
        PrimaryButton(
          arrived ? 'Iniciar viagem' : 'Iniciar viagem (aguarde chegar)',
          key: const ValueKey('driverStartTrip'),
          color: ZTheme.accent,
          onTap: arrived ? () => store.startTrip() : null,
        ),
      ]),
    );
  }
}

class _TripPanel extends StatelessWidget {
  const _TripPanel(this.r);
  final DriverRequest r;

  @override
  Widget build(BuildContext context) {
    final store = DriverScope.of(context);
    return MapPanel(
      padding: const EdgeInsets.all(18),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text('Levando ${r.passenger.split(' ').first}', style: ZText.title)),
          Text('${store.minutesLeft} min', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: ZTheme.accent)),
        ]),
        const SizedBox(height: 2),
        Text('Destino: ${r.destination.name}', style: ZText.sub),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(value: store.progress, minHeight: 4, color: ZTheme.accent, backgroundColor: ZTheme.fill2),
        ),
        const SizedBox(height: 12),
        Text('A corrida termina sozinha ao chegar · ${BR.money(r.fare)} no ${r.payment.title}', style: ZText.foot),
      ]),
    );
  }
}

class _FinishedPanel extends StatefulWidget {
  const _FinishedPanel(this.r);
  final DriverRequest r;

  @override
  State<_FinishedPanel> createState() => _FinishedPanelState();
}

class _FinishedPanelState extends State<_FinishedPanel> {
  int _stars = 5;

  @override
  Widget build(BuildContext context) {
    final store = DriverScope.of(context);
    final r = widget.r;
    Widget line(String a, String b, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Expanded(child: Text(a, style: TextStyle(fontSize: 15, fontWeight: bold ? FontWeight.w800 : FontWeight.w400))),
            Text(b, style: TextStyle(fontSize: 15, fontWeight: bold ? FontWeight.w800 : FontWeight.w500, fontFeatures: ZText.tabular)),
          ]),
        );
    return MapPanel(
      padding: const EdgeInsets.all(18),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Icon(CupertinoIcons.checkmark_seal_fill, color: ZTheme.accent, size: 34),
        const SizedBox(height: 6),
        Text('Você ganhou ${BR.money(r.driverShare)}', textAlign: TextAlign.center, style: ZText.title),
        if (r.payment == PaymentMethod.cash)
          Text('Receba ${BR.money(r.fare)} em dinheiro do passageiro.', textAlign: TextAlign.center, style: ZText.sub),
        const SizedBox(height: 12),
        line('Valor da corrida', BR.money(r.fare)),
        line('Taxa ITAX (20%)', '− ${BR.money(r.fare - r.driverShare)}'),
        const Divider(),
        line('Seu ganho', BR.money(r.driverShare), bold: true),
        const SizedBox(height: 12),
        Text('Avalie ${r.passenger.split(' ').first}', textAlign: TextAlign.center, style: ZText.bodyStrong),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var i = 1; i <= 5; i++)
            Pressable(
              key: ValueKey('passengerStar_$i'),
              onTap: () => setState(() => _stars = i),
              scale: 0.85,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(i <= _stars ? CupertinoIcons.star_fill : CupertinoIcons.star, size: 30, color: i <= _stars ? ZTheme.sun : ZTheme.tertiary),
              ),
            ),
        ]),
        const SizedBox(height: 12),
        PrimaryButton('Concluir', key: const ValueKey('driverFinish'), onTap: () => store.finish(_stars)),
      ]),
    );
  }
}

