import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/fixtures.dart';
import '../../core/formatters.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import '../admin_store.dart';
import '../admin_widgets.dart';

/// Preços: base fare, price per km and surge. Changes reach the customer app at once.
class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AdminScope.of(context);
    final pricing = Pricing.instance;
    return ListenableBuilder(
      listenable: pricing,
      builder: (context, _) => ListView(padding: const EdgeInsets.all(24), children: [
        PageHeader('Preços', subtitle: 'Até 3 km cobra só a tarifa base; depois soma o valor por km.', actions: [
          AdminButton('Restaurar padrão', key: const ValueKey('resetPricing'), filled: false, icon: CupertinoIcons.arrow_counterclockwise, onTap: () {
            pricing.reset();
            store.log('pricing.reset', 'Preços voltaram ao padrão');
          }),
        ]),
        AdminCard(
          title: 'Tarifa dinâmica',
          child: Row(children: [
            Expanded(
              child: Slider(
                key: const ValueKey('surgeSlider'),
                value: pricing.surge,
                min: 1,
                max: 2,
                divisions: 10,
                activeColor: ZTheme.accent,
                label: '${pricing.surge.toStringAsFixed(1).replaceAll('.', ',')}×',
                onChanged: pricing.setSurge,
                onChangeEnd: (v) => store.log('pricing.surge', 'Tarifa dinâmica em ${v.toStringAsFixed(1).replaceAll('.', ',')}×'),
              ),
            ),
            SizedBox(
              width: 70,
              child: Text('${pricing.surge.toStringAsFixed(1).replaceAll('.', ',')}×', textAlign: TextAlign.right, style: ZText.title),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        AdminCard(
          padding: EdgeInsets.zero,
          child: AdminTable(
            minWidth: 900,
            columns: const [('Categoria', 3), ('Tarifa base', 4), ('Por km', 4), ('2 km', 2), ('10 km', 2), ('Praia da Baleia', 3)],
            rows: [
              for (final r in Fixtures.rideTypes)
                [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(r.tagline, style: ZText.caption, overflow: TextOverflow.ellipsis),
                  ]),
                  _Stepper(
                    keyName: 'base_${r.id}',
                    value: pricing.base(r),
                    step: 0.5,
                    onChanged: (v) {
                      pricing.set(r, base: v, perKm: pricing.perKm(r));
                      store.log('pricing.updated', '${r.name}: tarifa base ${BR.money(v)}');
                    },
                  ),
                  _Stepper(
                    keyName: 'km_${r.id}',
                    value: pricing.perKm(r),
                    step: 0.05,
                    onChanged: (v) {
                      pricing.set(r, base: pricing.base(r), perKm: v);
                      store.log('pricing.updated', '${r.name}: ${BR.money(v)} por km');
                    },
                  ),
                  Text(BR.money(r.priceFor(2)), style: const TextStyle(fontFeatures: ZText.tabular)),
                  Text(BR.money(r.priceFor(10)), style: const TextStyle(fontFeatures: ZText.tabular)),
                  Text(BR.money(r.priceFor(Fixtures.place('baleia').distanceKm)), style: const TextStyle(fontWeight: FontWeight.w700, fontFeatures: ZText.tabular)),
                ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text('Os novos preços aparecem na hora no app do cliente aberto ao lado.', style: ZText.foot),
      ]),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.keyName, required this.value, required this.step, required this.onChanged});
  final String keyName;
  final double value;
  final double step;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, double delta, String suffix) => IconButton(
          key: ValueKey('${keyName}_$suffix'),
          visualDensity: VisualDensity.compact,
          onPressed: value + delta < 0 ? null : () => onChanged(((value + delta) * 100).round() / 100),
          icon: Icon(icon, size: 16),
        );
    return Row(children: [
      button(CupertinoIcons.minus, -step, 'minus'),
      Expanded(child: Text(BR.money(value), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontFeatures: ZText.tabular))),
      button(CupertinoIcons.plus, step, 'plus'),
    ]);
  }
}
