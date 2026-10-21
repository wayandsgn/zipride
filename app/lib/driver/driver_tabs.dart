import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/driver_store.dart';
import '../core/fixtures.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../widgets/brand.dart';
import '../widgets/common.dart';
import '../widgets/grouped.dart';

/// Ganhos: the week as bars, today's total and every ride of the day.
class DriverEarnings extends StatelessWidget {
  const DriverEarnings({super.key});

  static const _days = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
  static const _todayIndex = 2;

  @override
  Widget build(BuildContext context) {
    final store = DriverScope.of(context);
    final week = [...DriverStore.week]..[_todayIndex] = store.earningsToday;
    final total = week.fold(0.0, (a, b) => a + b);
    final top = week.reduce((a, b) => a > b ? a : b);
    return LargeTitlePage(title: 'Ganhos', background: ZTheme.fill, children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(ZTheme.cardRadius)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Esta semana', style: ZText.sub),
          Text(BR.money(total), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -0.8, fontFeatures: ZText.tabular)),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    if (week[i] > 0) Text(week[i].round().toString(), style: ZText.caption),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      height: week[i] == 0 ? 4 : 96 * week[i] / top,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: i == _todayIndex ? ZTheme.accent : ZTheme.fill2,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(_days[i], style: TextStyle(fontSize: 12, fontWeight: i == _todayIndex ? FontWeight.w800 : FontWeight.w500)),
                  ]),
                ),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 22),
      GroupSection(header: 'Hoje', children: [
        ValueRow('Ganhos', BR.money(store.earningsToday), bold: true),
        ValueRow('Corridas', '${store.tripsToday}'),
        const ValueRow('Tempo online', '5 h 12 min'),
        ValueRow('Corridas perdidas', '${store.missed}'),
      ]),
      GroupSection(header: 'Corridas de hoje', children: [
        for (final t in store.today)
          _TripLine(time: BR.time(t.finishedAt), place: t.request.destination.name, who: t.request.passenger, value: t.request.driverShare),
        const _TripLine(time: '11:40', place: 'Rodoviária de Itapipoca', who: 'Cícera Alves', value: 7.92),
        const _TripLine(time: '09:15', place: 'IFCE Campus Itapipoca', who: 'Lucas Rocha', value: 7.92),
        const _TripLine(time: '07:02', place: 'Praia da Baleia', who: 'Maria Sousa', value: 52.56),
      ]),
      GroupSection(children: [
        NavRow(icon: CupertinoIcons.arrow_down_circle_fill, title: 'Sacar para o Pix', subtitle: 'Saldo disponível ${BR.money(store.earningsToday)}', chevron: false, onTap: () {
          showNotice(context, 'Saque pelo Pix', 'Na demonstração nenhum dinheiro é transferido. No app real o saque cai em segundos.');
        }),
      ]),
    ]);
  }
}

class _TripLine extends StatelessWidget {
  const _TripLine({required this.time, required this.place, required this.who, required this.value});
  final String time;
  final String place;
  final String who;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(children: [
        SizedBox(width: 48, child: Text(time, style: const TextStyle(fontWeight: FontWeight.w600, fontFeatures: ZText.tabular))),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(place, style: ZText.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(who, style: ZText.foot),
          ]),
        ),
        Text(BR.money(value), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFeatures: ZText.tabular)),
      ]),
    );
  }
}

/// Conta do motorista: profile, vehicle, documents and preferences.
class DriverAccount extends StatefulWidget {
  const DriverAccount({super.key});

  @override
  State<DriverAccount> createState() => _DriverAccountState();
}

class _DriverAccountState extends State<DriverAccount> {
  bool _longTrips = true;
  bool _cash = true;

  @override
  Widget build(BuildContext context) {
    final d = Fixtures.driver;
    return LargeTitlePage(title: 'Conta', background: ZTheme.fill, children: [
      GroupSection(children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            RemoteAvatar(url: d.photoUrl, initials: 'M', size: 68),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Marcos Vieira', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                Text('★ ${BR.rating(d.rating)} · ${BR.integer(d.trips)} viagens', style: ZText.sub),
                const Text('Motorista parceiro desde 2024', style: ZText.foot),
              ]),
            ),
          ]),
        ),
      ]),
      GroupSection(header: 'Veículo', children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Chevrolet Onix', style: ZText.bodyStrong),
                Text('Prata · 2022 · ZiprideX e Comfort', style: ZText.foot),
              ]),
            ),
            MercosulPlate(d.plate),
          ]),
        ),
      ]),
      GroupSection(header: 'Documentos', children: [
        for (final doc in ['CNH com EAR', 'CRLV 2026', 'Antecedentes criminais'])
          NavRow(icon: CupertinoIcons.checkmark_shield_fill, title: doc, subtitle: 'Aprovado', chevron: false, onTap: () {
            showNotice(context, doc, 'Documento verificado pela equipe Zipride.');
          }),
      ]),
      GroupSection(header: 'Preferências', children: [
        SwitchRow('Aceitar corridas para o litoral', key: const ValueKey('pref_long'), value: _longTrips, onChanged: (v) => setState(() => _longTrips = v)),
        SwitchRow('Aceitar pagamento em dinheiro', value: _cash, onChanged: (v) => setState(() => _cash = v)),
      ]),
      GroupSection(children: [
        NavRow(icon: CupertinoIcons.question_circle_fill, title: 'Suporte ao motorista', subtitle: 'Resposta em até 5 minutos', chevron: false, onTap: () {
          showNotice(context, 'Suporte Zipride', 'Nossa equipe atende motoristas pelo chat todos os dias, das 6h à meia-noite.');
        }),
      ]),
    ]);
  }
}
