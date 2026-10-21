import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/fixtures.dart';
import '../../core/formatters.dart';
import '../../core/ride_store.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

/// End of trip: stars, tip and "Concluir", which adds the trip to Atividade.
class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _stars = 0;
  double _tip = 0;
  bool _custom = false;
  int _customValue = 15;

  double get _chosenTip => _custom ? _customValue.toDouble() : _tip;

  void _finish() {
    final store = StoreScope.read(context);
    final stars = _stars == 0 ? 5 : _stars;
    final tip = _chosenTip;
    Navigator.of(context).pop();
    store.finishRating(stars: stars, tip: tip);
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final fare = store.priceOf(store.selectedRide);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: ZTheme.surface,
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: ListView(padding: const EdgeInsets.fromLTRB(22, 30, 22, 20), children: [
                const Icon(CupertinoIcons.checkmark_circle_fill, size: 32, color: ZTheme.accent),
                const SizedBox(height: 10),
                Text('Você chegou em ${store.destination?.name ?? 'seu destino'}',
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ZTheme.secondary)),
                const SizedBox(height: 16),
                Center(child: RemoteAvatar(url: Fixtures.driver.photoUrl, initials: 'M', size: 84)),
                const SizedBox(height: 14),
                Text('Como foi sua viagem com o ${Fixtures.driver.name}?',
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                const SizedBox(height: 22),
                _starRow(),
                const SizedBox(height: 26),
                _tipSection(),
                const SizedBox(height: 22),
                _summary(fare),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
              child: PrimaryButton(_stars == 0 ? 'Concluir sem avaliar' : 'Concluir', key: const ValueKey('ratingDone'), onTap: _finish),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _starRow() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      for (var value = 1; value <= 5; value++)
        Pressable(
          key: ValueKey('ratingStar_$value'),
          onTap: () => setState(() => _stars = value),
          scale: 0.85,
          semanticLabel: '$value estrela${value > 1 ? 's' : ''}',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: AnimatedScale(
              scale: value == _stars ? 1.15 : 1,
              duration: const Duration(milliseconds: 280),
              curve: Curves.elasticOut,
              child: Icon(
                value <= _stars ? CupertinoIcons.star_fill : CupertinoIcons.star,
                size: 40,
                color: value <= _stars ? ZTheme.sun : ZTheme.tertiary,
              ),
            ),
          ),
        ),
    ]);
  }

  Widget _tipSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Quer deixar uma gorjeta?', style: ZText.headline),
      const SizedBox(height: 12),
      Row(children: [
        for (final value in [2.0, 5.0, 10.0]) ...[
          _chip(BR.money(value), 'tip_${value.round()}', !_custom && _tip == value, () {
            setState(() {
              _custom = false;
              _tip = _tip == value ? 0 : value;
            });
          }),
          const SizedBox(width: 8),
        ],
        _chip('Outro valor', 'tip_other', _custom, () => setState(() => _custom = !_custom)),
      ]),
      AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: _custom
            ? Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Row(children: [
                  Expanded(child: Text('Gorjeta: ${BR.money(_customValue.toDouble())}', style: ZText.bodyStrong)),
                  _stepper(),
                ]),
              )
            : const SizedBox(width: double.infinity),
      ),
      const SizedBox(height: 10),
      const Text('100% da gorjeta vai para o motorista.', style: ZText.foot),
    ]);
  }

  Widget _stepper() {
    Widget button(String label, int delta) => Pressable(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _customValue = (_customValue + delta).clamp(1, 100));
          },
          haptic: false,
          child: SizedBox(width: 46, height: 34, child: Center(child: Text(label, style: const TextStyle(fontSize: 20)))),
        );
    return Container(
      decoration: BoxDecoration(color: ZTheme.fill2, borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [button('−', -1), Container(width: 1, height: 18, color: ZTheme.tertiary), button('+', 1)]),
    );
  }

  Widget _chip(String label, String id, bool selected, VoidCallback onTap) {
    return Expanded(
      child: Pressable(
        key: ValueKey(id),
        onTap: onTap,
        scale: 0.94,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: selected ? Colors.black : ZTheme.fill2, borderRadius: BorderRadius.circular(99)),
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: selected ? Colors.white : ZTheme.ink)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summary(double fare) {
    final store = StoreScope.of(context);
    Widget line(String a, String b, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            Expanded(child: Text(a, style: TextStyle(fontSize: 16, fontWeight: bold ? FontWeight.w800 : FontWeight.w400))),
            Text(b, style: TextStyle(fontSize: 16, fontWeight: bold ? FontWeight.w800 : FontWeight.w400, fontFeatures: ZText.tabular)),
          ]),
        );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: ZTheme.fill, borderRadius: BorderRadius.circular(ZTheme.cardRadius)),
      child: Column(children: [
        line('Viagem ${store.selectedRide.name}', BR.money(fare)),
        line('Gorjeta', BR.money(_chosenTip)),
        const Divider(),
        line('Total no ${store.payment.title}', BR.money(fare + _chosenTip), bold: true),
      ]),
    );
  }
}
