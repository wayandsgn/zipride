import 'package:flutter/cupertino.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../widgets/brand.dart';
import '../../widgets/common.dart';
import '../admin_data.dart';
import '../admin_store.dart';
import '../admin_widgets.dart';

/// Motoristas: approve sign-ups, block and unblock.
class DriversPage extends StatefulWidget {
  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  DriverStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final store = AdminScope.of(context);
    final list = store.drivers.where((d) => _filter == null || store.statusOf(d) == _filter).toList();
    int count(DriverStatus s) => store.drivers.where((d) => store.statusOf(d) == s).length;
    return ListView(padding: const EdgeInsets.all(24), children: [
      PageHeader('Motoristas', subtitle: '${store.drivers.length} cadastrados · ${store.pendingDrivers} aguardando aprovação'),
      Wrap(spacing: 8, runSpacing: 8, children: [
        FilterChipZ('Todos', selected: _filter == null, onTap: () => setState(() => _filter = null)),
        for (final s in DriverStatus.values) FilterChipZ('${s.label} (${count(s)})', selected: _filter == s, onTap: () => setState(() => _filter = s)),
      ]),
      const SizedBox(height: 14),
      AdminCard(
        padding: EdgeInsets.zero,
        child: AdminTable(
          minWidth: 960,
          columns: const [('Motorista', 4), ('Veículo', 4), ('Placa', 3), ('Avaliação', 2), ('Corridas', 2), ('Status', 3), ('Ações', 4)],
          rows: [
            for (final d in list)
              [
                Row(children: [
                  InitialsAvatar(d.name, size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                      Text('desde ${d.since}', style: ZText.caption),
                    ]),
                  ),
                ]),
                Text(d.car, overflow: TextOverflow.ellipsis),
                Align(alignment: Alignment.centerLeft, child: Transform.scale(scale: 0.8, alignment: Alignment.centerLeft, child: MercosulPlate(d.plate))),
                Text(d.rating == 0 ? '—' : '★ ${BR.rating(d.rating)}'),
                Text(BR.integer(d.trips)),
                Align(alignment: Alignment.centerLeft, child: StatusPill(store.statusOf(d).label, driverColor(store.statusOf(d)))),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  if (d.status == DriverStatus.review)
                    AdminButton('Aprovar', key: ValueKey('approve_${d.id}'), color: ZTheme.accent, onTap: () => store.approve(d)),
                  AdminButton(
                    d.status == DriverStatus.blocked ? 'Desbloquear' : 'Bloquear',
                    key: ValueKey('block_${d.id}'),
                    filled: false,
                    color: d.status == DriverStatus.blocked ? ZTheme.ink : ZTheme.danger,
                    onTap: () async {
                      if (d.status != DriverStatus.blocked) {
                        final ok = await showConfirm(context, title: 'Bloquear ${d.name}?', message: 'O motorista não recebe mais corridas até ser desbloqueado.', cancel: 'Voltar', confirm: 'Bloquear');
                        if (!ok) return;
                      }
                      store.toggleBlock(d);
                    },
                  ),
                ]),
              ],
          ],
        ),
      ),
    ]);
  }
}

/// Passageiros: contact data, number of rides and blocking.
class PassengersPage extends StatelessWidget {
  const PassengersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AdminScope.of(context);
    return ListView(padding: const EdgeInsets.all(24), children: [
      PageHeader('Passageiros', subtitle: '${store.passengers.length} passageiros ativos em Itapipoca'),
      AdminCard(
        padding: EdgeInsets.zero,
        child: AdminTable(
          minWidth: 760,
          columns: const [('Passageiro', 4), ('Telefone', 3), ('Corridas', 2), ('Avaliação', 2), ('Status', 2), ('Ações', 3)],
          rows: [
            for (final p in store.passengers)
              [
                Row(children: [
                  InitialsAvatar(p.name, size: 32),
                  const SizedBox(width: 10),
                  Expanded(child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                ]),
                Text(p.phone),
                Text(BR.integer(p.trips)),
                Text('★ ${BR.rating(p.rating)}'),
                Align(alignment: Alignment.centerLeft, child: StatusPill(p.blocked ? 'Bloqueado' : 'Ativo', p.blocked ? ZTheme.danger : ZTheme.accent)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AdminButton(
                    p.blocked ? 'Desbloquear' : 'Bloquear',
                    filled: false,
                    color: p.blocked ? ZTheme.ink : ZTheme.danger,
                    icon: p.blocked ? CupertinoIcons.lock_open : CupertinoIcons.lock,
                    onTap: () => store.toggleBlockPassenger(p),
                  ),
                ),
              ],
          ],
        ),
      ),
    ]);
  }
}
