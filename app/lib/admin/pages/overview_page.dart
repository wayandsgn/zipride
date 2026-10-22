import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../admin_data.dart';
import '../admin_store.dart';
import '../admin_widgets.dart';

/// Visão geral: today's numbers, rides per hour, recent rides and the event feed.
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  static const _hourly = [1, 0, 0, 0, 1, 3, 9, 14, 11, 7, 6, 8, 10, 7, 6, 8, 11, 15, 13, 9, 7, 5, 3, 2];

  @override
  Widget build(BuildContext context) {
    final store = AdminScope.of(context);
    final now = BR.local(DateTime.now());
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth > 1100 ? 4 : (c.maxWidth > 640 ? 2 : 1);
      final kpis = [
        KpiCard(label: 'Corridas hoje', value: '${store.ridesToday}', icon: CupertinoIcons.car_fill, note: '+12% vs. quarta passada'),
        KpiCard(label: 'Receita hoje', value: BR.money(store.revenueToday), icon: CupertinoIcons.money_dollar_circle_fill, note: '78% via Pix'),
        KpiCard(label: 'Motoristas online', value: '${store.onlineDrivers}', icon: CupertinoIcons.person_2_fill, color: ZTheme.youBlue),
        KpiCard(label: 'Chamados abertos', value: '${store.openTickets}', icon: CupertinoIcons.chat_bubble_2_fill, color: const Color(0xFFE0A030), note: 'Tempo médio de resposta 4 min'),
      ];
      return ListView(padding: const EdgeInsets.all(24), children: [
        PageHeader('Visão geral', subtitle: 'Itapipoca, CE · ${BR.longDate(DateTime.now())}'),
        GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: cols == 1 ? 2.8 : 1.9,
          children: kpis,
        ),
        const SizedBox(height: 14),
        Flex(
          direction: c.maxWidth > 1000 ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _flex(c, 3, AdminCard(
              title: 'Corridas por hora',
              child: SizedBox(
                height: 180,
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  for (var h = 0; h < 24; h++)
                    Expanded(
                      child: Tooltip(
                        message: '${h}h · ${_hourly[h]} corridas',
                        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                          Container(
                            height: 4 + 140.0 * _hourly[h] / 15,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: h == now.hour ? ZTheme.accent : (h > now.hour ? ZTheme.fill2 : ZTheme.accent.withValues(alpha: 0.45)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(h % 3 == 0 ? '${h}h' : '', style: ZText.caption),
                        ]),
                      ),
                    ),
                ]),
              ),
            )),
            const SizedBox(width: 14, height: 14),
            _flex(c, 2, AdminCard(
              title: 'Atividade do sistema',
              trailing: TextButton(onPressed: () => store.go(AdminPage.system), child: const Text('Ver tudo')),
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
              child: Column(children: [
                for (final e in store.events.take(6)) EventLine(e),
              ]),
            )),
          ],
        ),
        const SizedBox(height: 14),
        AdminCard(
          title: 'Últimas corridas',
          trailing: TextButton(onPressed: () => store.go(AdminPage.rides), child: const Text('Ver todas')),
          padding: const EdgeInsets.only(top: 10),
          child: AdminTable(
            columns: const [('Corrida', 2), ('Hora', 2), ('Passageiro', 3), ('Motorista', 3), ('Destino', 4), ('Valor', 2), ('Status', 3)],
            rows: [
              for (final r in store.rides.take(6))
                [
                  Text(r.id, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(BR.time(r.time)),
                  Text(r.passenger, overflow: TextOverflow.ellipsis),
                  Text(r.driver, overflow: TextOverflow.ellipsis),
                  Text(r.to.name, overflow: TextOverflow.ellipsis),
                  Text(BR.money(r.fare), style: const TextStyle(fontFeatures: ZText.tabular)),
                  Align(alignment: Alignment.centerLeft, child: StatusPill(r.status.label, rideColor(r.status))),
                ],
            ],
          ),
        ),
      ]);
    });
  }

  Widget _flex(BoxConstraints c, int flex, Widget child) => c.maxWidth > 1000 ? Expanded(flex: flex, child: child) : child;
}

class EventLine extends StatelessWidget {
  const EventLine(this.e, {super.key});
  final AdminEvent e;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 44, child: Text(BR.time(e.time), style: const TextStyle(fontSize: 13, color: ZTheme.secondary, fontFeatures: ZText.tabular))),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.message, style: const TextStyle(fontSize: 14)),
            Text(e.kind, style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: ZTheme.secondary)),
          ]),
        ),
      ]),
    );
  }
}
