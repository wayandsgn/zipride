import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/fixtures.dart';
import '../../core/formatters.dart';
import '../../core/ride_store.dart';
import '../../core/theme.dart';
import '../../widgets/brand.dart';
import '../../widgets/common.dart';
import 'chat_sheet.dart';

/// Matched driver: countdown header, driver and car, chat, call, start and cancel.
class DriverCard extends StatelessWidget {
  const DriverCard({super.key});

  Future<void> _openChat(BuildContext context) async {
    final store = StoreScope.read(context);
    store.setChatOpen(true);
    await showZSheet<void>(context, (_) => const ChatSheet(), expand: true);
    store.setChatOpen(false);
  }

  Future<void> _askCancel(BuildContext context) async {
    final store = StoreScope.read(context);
    final yes = await showConfirm(
      context,
      title: 'Cancelar a corrida?',
      message: 'O ${Fixtures.driver.name} já está a caminho.',
      cancel: 'Continuar',
      confirm: 'Cancelar',
    );
    if (yes) store.cancelRide();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final arrived = store.phase == RidePhase.driverArrived;
    return MapPanel(
      padding: const EdgeInsets.all(18),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(a), child: child),
                ),
                child: Text(
                  arrived ? 'Seu motorista chegou' : 'Chegando em ${store.arrivalMinutes} min',
                  key: ValueKey('status_${arrived ? 'arrived' : store.arrivalMinutes}'),
                  style: ZText.title,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                arrived ? 'Encontre o ${Fixtures.driver.name} no ponto de embarque' : 'Embarque na ${Fixtures.pickupAddress}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ZText.foot,
              ),
            ]),
          ),
          if (arrived)
            const Icon(CupertinoIcons.checkmark_seal_fill, color: ZTheme.accent, size: 28)
          else
            SizedBox.square(
              dimension: 26,
              child: CircularProgressIndicator(value: store.driverProgress, strokeWidth: 3, color: ZTheme.accent, backgroundColor: ZTheme.fill2),
            ),
        ]),
        const SizedBox(height: 14),
        const Divider(),
        const SizedBox(height: 14),
        const DriverSummary(),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: Pressable(
              key: const ValueKey('messageButton'),
              onTap: () => _openChat(context),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: ZTheme.fill2, borderRadius: BorderRadius.circular(99)),
                child: Row(children: [
                  const Icon(CupertinoIcons.chat_bubble_fill, size: 17),
                  const SizedBox(width: 8),
                  Flexible(child: Text('Mensagem para ${Fixtures.driver.name}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _round(CupertinoIcons.phone_fill, 'Ligar', () => showNotice(context, 'Ligação protegida', 'Seu número fica oculto. Na versão de demonstração a ligação não é feita.')),
          const SizedBox(width: 10),
          _round(CupertinoIcons.xmark, 'Cancelar corrida', () => _askCancel(context), key: const ValueKey('cancelRide')),
        ]),
        const SizedBox(height: 14),
        PrimaryButton(
          arrived ? 'Iniciar viagem' : 'Já estou no carro',
          key: const ValueKey('startTrip'),
          color: arrived ? ZTheme.accent : ZTheme.fill2,
          onTap: store.startTrip,
        ),
      ]),
    );
  }

  Widget _round(IconData icon, String label, VoidCallback onTap, {Key? key}) {
    return Pressable(
      key: key,
      onTap: onTap,
      scale: 0.9,
      semanticLabel: label,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(color: ZTheme.fill2, shape: BoxShape.circle),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

/// Driver photo, rating, car and Mercosul plate.
class DriverSummary extends StatelessWidget {
  const DriverSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final d = Fixtures.driver;
    return Row(children: [
      Stack(clipBehavior: Clip.none, children: [
        RemoteAvatar(url: d.photoUrl, initials: 'M', size: 60),
        Positioned(
          right: -8,
          bottom: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: ZTheme.card,
              borderRadius: BorderRadius.circular(99),
              boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 2, offset: Offset(0, 1))],
            ),
            child: Row(children: [
              const Icon(CupertinoIcons.star_fill, size: 9, color: ZTheme.sun),
              const SizedBox(width: 2),
              Text(BR.rating(d.rating), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ]),
      const SizedBox(width: 16),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text(d.car, style: ZText.sub),
          Text('${BR.integer(d.trips)} viagens', style: ZText.caption),
        ]),
      ),
      MercosulPlate(d.plate),
    ]);
  }
}
