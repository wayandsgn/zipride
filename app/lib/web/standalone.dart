import 'package:flutter/material.dart';

import '../admin/admin_app.dart';
import '../admin/admin_store.dart';
import '../core/driver_store.dart';
import '../core/ride_store.dart';
import '../core/theme.dart';
import '../driver/driver_app.dart';
import '../main.dart';
import 'phone_frame.dart';

enum StandaloneKind { rider, driver, admin }

/// One app on its own page, as if it were installed: no demo bar, no links between apps.
/// On a wide screen the phone apps sit in a phone frame; on a phone they fill the screen.
class StandaloneApp extends StatefulWidget {
  const StandaloneApp({super.key, required this.kind});
  final StandaloneKind kind;

  @override
  State<StandaloneApp> createState() => _StandaloneAppState();
}

class _StandaloneAppState extends State<StandaloneApp> {
  late final _rider = RideStore();
  late final _driver = DriverStore();
  late final _admin = AdminStore();

  @override
  Widget build(BuildContext context) {
    final Widget app = switch (widget.kind) {
      StandaloneKind.rider => ItaxApp(store: _rider),
      StandaloneKind.driver => DriverApp(store: _driver),
      StandaloneKind.admin => AdminApp(store: _admin),
    };
    if (widget.kind == StandaloneKind.admin || MediaQuery.sizeOf(context).width < 500) return app;
    final label = widget.kind == StandaloneKind.rider ? 'ITAX' : 'ITAX Motorista';
    return Material(
      color: ZTheme.surface,
      child: Padding(padding: const EdgeInsets.all(16), child: Center(child: PhoneFrame(label: label, child: app))),
    );
  }
}
