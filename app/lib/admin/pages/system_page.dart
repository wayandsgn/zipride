import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../admin_store.dart';
import '../admin_widgets.dart';
import 'overview_page.dart';

/// Sistema: for the developers. Service health, app versions, feature flags and the event log.
class SystemPage extends StatelessWidget {
  const SystemPage({super.key});

  static const _services = [
    ('API de corridas', '99,98%', '84 ms'),
    ('Pagamentos Pix', '99,95%', '1,2 s'),
    ('Mapas e rotas', '100%', '120 ms'),
    ('Notificações push', '99,90%', '310 ms'),
  ];

  @override
  Widget build(BuildContext context) {
    final store = AdminScope.of(context);
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth > 1000;
      final health = AdminCard(
        title: 'Serviços',
        child: Column(children: [
          for (final (name, uptime, latency) in _services)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(children: [
                const StatusPill('Operacional', ZTheme.accent),
                const SizedBox(width: 12),
                Expanded(child: Text(name, style: ZText.bodyStrong)),
                Text('$uptime · $latency', style: ZText.sub),
              ]),
            ),
          const Divider(height: 22),
          const Row(children: [
            Expanded(child: Text('Versões em uso', style: ZText.bodyStrong)),
            Text('iOS 1.0 (Itapipoca) · Android 1.0 (Itapipoca) · Web 1.0', style: ZText.sub),
          ]),
        ]),
      );
      final flags = AdminCard(
        title: 'Funções do app',
        padding: const EdgeInsets.fromLTRB(18, 6, 12, 10),
        child: Column(children: [
          for (final f in store.flags.entries)
            Row(children: [
              Expanded(child: Text(f.key, style: ZText.body)),
              CupertinoSwitch(
                key: ValueKey('flag_${f.key}'),
                value: f.value,
                activeTrackColor: f.key == 'Modo manutenção' ? ZTheme.danger : ZTheme.accent,
                onChanged: (v) => store.setFlag(f.key, v),
              ),
            ]),
        ]),
      );
      return ListView(padding: const EdgeInsets.all(24), children: [
        const PageHeader('Sistema', subtitle: 'Ambiente de demonstração · nada aqui afeta usuários reais'),
        if (wide)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: health),
            const SizedBox(width: 14),
            Expanded(child: flags),
          ])
        else ...[health, const SizedBox(height: 14), flags],
        const SizedBox(height: 14),
        AdminCard(
          title: 'Registro de eventos',
          trailing: Text('${store.events.length} eventos', style: ZText.foot),
          child: Column(children: [for (final e in store.events) EventLine(e)]),
        ),
      ]);
    });
  }
}
