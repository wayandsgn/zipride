import 'package:flutter/cupertino.dart';

import '../../core/models.dart';
import '../../core/ride_store.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import 'ride_options_panel.dart';

/// Payment method picker: Pix (default), card and cash.
class PaymentSheet extends StatelessWidget {
  const PaymentSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Grabber(),
          const SizedBox(height: 16),
          const Text('Forma de pagamento', style: ZText.title),
          const SizedBox(height: 14),
          for (final m in PaymentMethod.values) ...[PaymentRow(method: m), const SizedBox(height: 8)],
          const SizedBox(height: 8),
          PrimaryButton('Pronto', key: const ValueKey('paymentDone'), onTap: () => Navigator.of(context).pop()),
        ]),
      ),
    );
  }
}

/// One selectable payment method, shared with the wallet.
class PaymentRow extends StatelessWidget {
  const PaymentRow({super.key, required this.method});
  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final selected = store.payment == method;
    return Pressable(
      key: ValueKey('payment_${method.name}'),
      onTap: () => store.selectPayment(method),
      haptic: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ZTheme.card,
          border: Border.all(color: selected ? ZTheme.ink : ZTheme.hairline, width: selected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: selected ? ZTheme.accent : ZTheme.accentSoft, borderRadius: BorderRadius.circular(12)),
            child: Icon(paymentIcon(method), size: 19, color: selected ? ZTheme.onInk : ZTheme.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(method.title, style: ZText.bodyStrong),
              Text(method.subtitle, style: ZText.foot),
            ]),
          ),
          Icon(
            selected ? CupertinoIcons.checkmark_alt_circle_fill : CupertinoIcons.circle,
            size: 24,
            color: selected ? ZTheme.accent : ZTheme.tertiary,
          ),
        ]),
      ),
    );
  }
}
