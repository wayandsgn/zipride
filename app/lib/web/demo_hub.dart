import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../admin/admin_app.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../driver/driver_app.dart';
import '../main.dart';
import '../widgets/brand.dart';
import 'demo_link.dart';
import 'phone_frame.dart';

enum DemoMode {
  both('Cliente + Motorista'),
  rider('Cliente'),
  driver('Motorista'),
  admin('Painel admin');

  const DemoMode(this.label);
  final String label;
}

/// The page you open in the browser: switch between the three apps, or use
/// the customer and driver apps side by side with the admin panel watching.
class DemoHub extends StatefulWidget {
  const DemoHub({super.key});

  @override
  State<DemoHub> createState() => _DemoHubState();
}

class _DemoHubState extends State<DemoHub> {
  DemoMode _mode = DemoMode.both;
  DemoLink _link = DemoLink();

  /// The stores of the running demo (used by tests).
  DemoLink get link => _link;
  int _generation = 0;

  // Global keys keep each app's state when it moves between layouts.
  late GlobalKey _riderKey = GlobalKey();
  late GlobalKey _driverKey = GlobalKey();

  void _setMode(DemoMode mode) {
    setState(() => _mode = mode);
    _link.driver.setAutoOffers(mode == DemoMode.driver);
  }

  void _restart() {
    final old = _link;
    setState(() {
      Pricing.instance.reset();
      _link = DemoLink();
      _generation++;
      _riderKey = GlobalKey();
      _driverKey = GlobalKey();
    });
    _link.driver.setAutoOffers(_mode == DemoMode.driver);
    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  @override
  void initState() {
    super.initState();
    _link.driver.setAutoOffers(false);
  }

  @override
  Widget build(BuildContext context) {
    final rider = PhoneFrame(label: 'App do cliente', child: ZiprideApp(key: _riderKey, store: _link.rider));
    final driver = PhoneFrame(label: 'App do motorista', child: DriverApp(key: _driverKey, store: _link.driver));
    final Widget body = switch (_mode) {
      DemoMode.both => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Flexible(child: rider),
          const SizedBox(width: 40),
          Flexible(child: driver),
        ]),
      DemoMode.rider => Center(child: rider),
      DemoMode.driver => Center(child: driver),
      DemoMode.admin => const SizedBox.shrink(),
    };
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDF0),
      body: Column(children: [
        _TopBar(mode: _mode, onMode: _setMode, onRestart: _restart),
        Expanded(
          child: Stack(children: [
            if (_mode != DemoMode.admin)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(children: [
                  if (_mode == DemoMode.both) const _Steps(),
                  Expanded(child: body),
                ]),
              ),
            // The admin panel stays alive in the background so it keeps logging events.
            Offstage(
              offstage: _mode != DemoMode.admin,
              child: AdminApp(key: ValueKey('admin_$_generation'), store: _link.admin),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.mode, required this.onMode, required this.onRestart});
  final DemoMode mode;
  final ValueChanged<DemoMode> onMode;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 760;
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        bottom: false,
        child: Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, runSpacing: 10, spacing: 12, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            const ZiprideWordmark(size: 26),
            if (!narrow) ...[
              const SizedBox(width: 10),
              const Text('Demonstração web · Itapipoca, CE', style: ZText.sub),
            ],
          ]),
          CupertinoSlidingSegmentedControl<DemoMode>(
            groupValue: mode,
            onValueChanged: (m) => onMode(m!),
            children: {
              for (final m in DemoMode.values)
                m: Padding(
                  key: ValueKey('mode_${m.name}'),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(m.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
            },
          ),
          TextButton.icon(
            key: const ValueKey('restartDemo'),
            onPressed: onRestart,
            icon: const Icon(CupertinoIcons.arrow_counterclockwise, size: 16),
            label: const Text('Recomeçar'),
          ),
        ]),
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps();

  @override
  Widget build(BuildContext context) {
    const steps = [
      '1. No motorista, toque em "Ficar online"',
      '2. No cliente, escolha um destino e confirme',
      '3. Aceite a corrida no motorista',
      '4. Acompanhe tudo em "Painel admin"',
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 6, children: [
        for (final s in steps)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99)),
            child: Text(s, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
      ]),
    );
  }
}
