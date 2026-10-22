import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../admin_data.dart';
import '../admin_store.dart';
import '../admin_widgets.dart';

/// Corridas: every ride of the day with search, filters and a detail panel.
class RidesPage extends StatefulWidget {
  const RidesPage({super.key});

  @override
  State<RidesPage> createState() => _RidesPageState();
}

class _RidesPageState extends State<RidesPage> {
  RideStatus? _filter;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final store = AdminScope.of(context);
    final q = BR.searchKey(_query);
    final rides = store.rides.where((r) {
      if (_filter != null && r.status != _filter) return false;
      if (q.isEmpty) return true;
      return BR.searchKey('${r.id} ${r.passenger} ${r.driver} ${r.to.name} ${r.from.name}').contains(q);
    }).toList();
    return ListView(padding: const EdgeInsets.all(24), children: [
      PageHeader('Corridas', subtitle: '${store.rides.length} corridas hoje · clique em uma para ver detalhes'),
      Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        SizedBox(
          width: 280,
          child: CupertinoSearchTextField(
            key: const ValueKey('rideSearch'),
            placeholder: 'Buscar passageiro, motorista, destino',
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        FilterChipZ('Todas', selected: _filter == null, onTap: () => setState(() => _filter = null)),
        for (final s in RideStatus.values) FilterChipZ(s.label, selected: _filter == s, onTap: () => setState(() => _filter = s)),
      ]),
      const SizedBox(height: 14),
      AdminCard(
        padding: EdgeInsets.zero,
        child: rides.isEmpty
            ? const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Nenhuma corrida encontrada.', style: ZText.sub)))
            : AdminTable(
                minWidth: 980,
                rowKeys: [for (final r in rides) ValueKey('ride_${r.id}')],
                onTap: (i) => _openDetail(context, rides[i]),
                columns: const [('Corrida', 2), ('Hora', 2), ('Passageiro', 3), ('Motorista', 3), ('Trajeto', 5), ('Tipo', 2), ('Valor', 2), ('Pagamento', 2), ('Status', 3)],
                rows: [
                  for (final r in rides)
                    [
                      Text(r.id, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(BR.time(r.time)),
                      Text(r.passenger, overflow: TextOverflow.ellipsis),
                      Text(r.driver, overflow: TextOverflow.ellipsis),
                      Text('${r.from.name} → ${r.to.name}', overflow: TextOverflow.ellipsis),
                      Text(r.rideName),
                      Text(BR.money(r.fare), style: const TextStyle(fontFeatures: ZText.tabular)),
                      Text(r.payment.title.split(' ').first),
                      Align(alignment: Alignment.centerLeft, child: StatusPill(r.status.label, rideColor(r.status))),
                    ],
                ],
              ),
      ),
    ]);
  }

  void _openDetail(BuildContext context, AdminRide r) {
    final store = AdminScope.read(context);
    showDialog<void>(
      useRootNavigator: false,
      context: context,
      builder: (dialogContext) => StatefulBuilder(builder: (context, setLocal) {
        Widget line(String a, String b) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(children: [
                SizedBox(width: 130, child: Text(a, style: ZText.sub)),
                Expanded(child: Text(b, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
              ]),
            );
        return Dialog(
          backgroundColor: ZTheme.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Text('Corrida ${r.id}', style: ZText.title),
                  const SizedBox(width: 10),
                  StatusPill(r.status.label, rideColor(r.status)),
                  const Spacer(),
                  IconButton(key: const ValueKey('closeRide'), onPressed: () => Navigator.of(dialogContext).pop(), icon: const Icon(CupertinoIcons.xmark)),
                ]),
                const SizedBox(height: 10),
                line('Horário', BR.longDate(r.time)),
                line('Passageiro', r.passenger),
                line('Motorista', r.driver),
                line('Origem', '${r.from.name} · ${r.from.address}'),
                line('Destino', '${r.to.name} · ${r.to.address}'),
                line('Distância', BR.km(r.km)),
                line('Tipo', r.rideName),
                line('Valor', '${BR.money(r.fare)} · ${r.payment.title}'),
                line('Ganho do motorista', BR.money(r.fare * 0.8)),
                if (r.rating != null) line('Avaliação', '★' * r.rating!),
                const SizedBox(height: 18),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  AdminButton('Reembolsar', key: const ValueKey('refundRide'), icon: CupertinoIcons.arrow_uturn_left, onTap: r.status == RideStatus.done
                      ? () async {
                          final ok = await showConfirm(context, title: 'Reembolsar ${BR.money(r.fare)}?', message: 'O valor volta para ${r.passenger} pelo mesmo meio de pagamento.', cancel: 'Voltar', confirm: 'Reembolsar');
                          if (ok) {
                            store.refund(r);
                            setLocal(() {});
                          }
                        }
                      : null),
                  AdminButton('Falar com o passageiro', filled: false, onTap: () => showNotice(context, 'Mensagem', 'Na demonstração a mensagem não é enviada para ${r.passenger}.')),
                ]),
              ]),
            ),
          ),
        );
      }),
    );
  }
}
