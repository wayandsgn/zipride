import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/fixtures.dart';
import '../../core/formatters.dart';
import '../../core/models.dart';
import '../../core/ride_store.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/grouped.dart';
import 'account_pages.dart';

/// Conta: profile, rating, wallet and settings.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return LargeTitlePage(title: 'Conta', background: ZTheme.fill, children: [
      const GroupSection(children: [_Profile()]),
      Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Row(children: [
          _Tile('Carteira', CupertinoIcons.creditcard_fill, () {
            store.selectPayment(PaymentMethod.pix);
            showNotice(context, 'Pix selecionado', 'Suas próximas viagens serão pagas com Pix, sem taxa.');
          }),
          const SizedBox(width: 10),
          _Tile('Segurança', CupertinoIcons.shield_lefthalf_fill, () {
            showNotice(context, 'Central de segurança', 'Compartilhe a viagem, confira a placa e ligue 190 em emergências.');
          }),
          const SizedBox(width: 10),
          _Tile('Atividade', CupertinoIcons.clock_fill, () => store.select(AppTab.activity)),
        ]),
      ),
      GroupSection(children: [
        NavRow(key: const ValueKey('walletLink'), icon: CupertinoIcons.creditcard_fill, title: 'Carteira', subtitle: 'Pix, cartões e saldo Zipride', onTap: () => _push(context, const WalletPage())),
        NavRow(key: const ValueKey('savedLink'), icon: CupertinoIcons.map_pin_ellipse, title: 'Lugares salvos', subtitle: 'Casa e Trabalho', onTap: () => _push(context, const SavedPlacesPage())),
        NavRow(key: const ValueKey('settingsLink'), icon: CupertinoIcons.gear_solid, title: 'Configurações', subtitle: 'Notificações, privacidade e conta', onTap: () => _push(context, const SettingsPage())),
      ]),
      GroupSection(children: [
        NavRow(icon: CupertinoIcons.gift_fill, title: 'Convide amigos', subtitle: 'Ganhe R\$ 10 na próxima viagem', chevron: false, onTap: () {
          showNotice(context, 'Seu código: DAVI10', 'Quem usar seu código ganha R\$ 10 na primeira viagem, e você também.');
        }),
        NavRow(icon: CupertinoIcons.question_circle_fill, title: 'Ajuda', subtitle: 'Fale com o suporte Zipride', chevron: false, onTap: () {
          showNotice(context, 'Ajuda Zipride', 'O suporte responde pelo chat em até 5 minutos, todos os dias.');
        }),
      ]),
      GroupSection(children: [
        TextActionRow('Sair da conta', key: const ValueKey('logout'), color: ZTheme.danger, onTap: () {
          showNotice(context, 'Modo demonstração', 'Nesta versão de demonstração você continua conectado.');
        }),
      ]),
    ]);
  }
}

class _Profile extends StatelessWidget {
  const _Profile();

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final trips = Fixtures.userTrips + store.trips.length - Fixtures.pastTrips.length;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        RemoteAvatar(url: Fixtures.userPhotoUrl, initials: 'DF', size: 68),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(Fixtures.userName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Row(children: [
              const Icon(CupertinoIcons.star_fill, size: 14, color: ZTheme.sun),
              const SizedBox(width: 4),
              Text(BR.rating(Fixtures.userRating), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text(' · ${BR.integer(trips)} viagens', style: ZText.sub),
            ]),
            const SizedBox(height: 2),
            const Text(Fixtures.cityName, style: ZText.foot),
          ]),
        ),
      ]),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.title, this.icon, this.onTap);

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Pressable(
        key: ValueKey('accountTile_$title'),
        onTap: onTap,
        scale: 0.95,
        child: Container(
          height: 78,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 22),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}
