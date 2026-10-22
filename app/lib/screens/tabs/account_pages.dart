import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/fixtures.dart';
import '../../core/formatters.dart';
import '../../core/models.dart';
import '../../core/ride_store.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/grouped.dart';
import '../ride/payment_sheet.dart';

/// Carteira: ITAX balance and the payment method used by default.
class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailPage(title: 'Carteira', children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ZTheme.cardRadius),
          gradient: const LinearGradient(colors: [ZTheme.accent, Colors.black], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Saldo ITAX', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xCCFFFFFF))),
          const SizedBox(height: 4),
          Text(BR.money(23.50), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, fontFeatures: ZText.tabular)),
          const SizedBox(height: 4),
          const Text('Use em viagens e entregas em Itapipoca', style: TextStyle(fontSize: 13, color: Color(0xCCFFFFFF))),
        ]),
      ),
      const SizedBox(height: 24),
      const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 8), child: SectionLabel('Pagamento padrão')),
      for (final m in PaymentMethod.values) ...[PaymentRow(method: m), const SizedBox(height: 8)],
      const SizedBox(height: 14),
      GroupSection(children: [
        NavRow(icon: CupertinoIcons.plus_circle_fill, title: 'Adicionar forma de pagamento', chevron: false, onTap: () {
          showNotice(context, 'Adicionar pagamento', 'Na versão de demonstração você pode usar Pix, o Visa •••• 4242 ou dinheiro.');
        }),
      ]),
    ]);
  }
}

/// Casa and Trabalho, each one tap away from a ride.
class SavedPlacesPage extends StatelessWidget {
  const SavedPlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailPage(title: 'Lugares salvos', children: [
      GroupSection(children: [
        for (final place in [Fixtures.home, Fixtures.work])
          NavRow(key: ValueKey('savedPlace_${place.id}'), icon: place.icon, title: place.name, subtitle: place.address, onTap: () {
            final store = StoreScope.read(context);
            Navigator.of(context).pop();
            store.choose(place);
          }),
      ]),
    ]);
  }
}

/// Configurações: switches live only for this session (nothing is saved).
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _tripAlerts = true;
  bool _promos = false;
  bool _shareTrips = true;
  bool _pinCheck = false;

  void _toggle(void Function() change) {
    HapticFeedback.selectionClick();
    setState(change);
  }

  @override
  Widget build(BuildContext context) {
    return DetailPage(title: 'Configurações', children: [
      const GroupSection(header: 'Conta', children: [
        ValueRow('Nome', Fixtures.userName),
        ValueRow('Telefone', Fixtures.userPhone),
        ValueRow('E-mail', Fixtures.userEmail),
        ValueRow('Cidade', Fixtures.cityName),
      ]),
      GroupSection(header: 'Notificações', children: [
        SwitchRow('Avisos da viagem', key: const ValueKey('switch_tripAlerts'), value: _tripAlerts, onChanged: (v) => _toggle(() => _tripAlerts = v)),
        SwitchRow('Promoções e cupons', key: const ValueKey('switch_promos'), value: _promos, onChanged: (v) => _toggle(() => _promos = v)),
      ]),
      GroupSection(header: 'Segurança', children: [
        SwitchRow('Compartilhar viagens com contatos', value: _shareTrips, onChanged: (v) => _toggle(() => _shareTrips = v)),
        SwitchRow('Confirmar embarque com PIN', value: _pinCheck, onChanged: (v) => _toggle(() => _pinCheck = v)),
      ]),
      GroupSection(children: [
        const ValueRow('Versão', '1.0 (Itapipoca)'),
        TextActionRow('Excluir conta', key: const ValueKey('deleteAccount'), color: ZTheme.danger, onTap: () {
          showNotice(context, 'Excluir conta', 'Na versão de demonstração nenhuma conta é excluída.');
        }),
      ]),
    ]);
  }
}
