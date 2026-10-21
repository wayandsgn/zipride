import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../admin_data.dart';
import '../admin_store.dart';
import '../admin_widgets.dart';

/// Suporte: tickets from riders and drivers, with a reply box.
class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  String? _openId;
  final _reply = TextEditingController();

  static const _quick = ['Já estamos verificando, retornamos em instantes.', 'Reembolso feito, cai em até 1 dia útil.', 'Obrigado pelo aviso!'];

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  void _send(AdminStore store, Ticket t, String text) {
    store.reply(t, text);
    _reply.clear();
  }

  @override
  Widget build(BuildContext context) {
    final store = AdminScope.of(context);
    final open = store.tickets.firstWhere((t) => t.id == _openId, orElse: () => store.tickets.first);
    final list = AdminCard(
      padding: const EdgeInsets.all(8),
      child: Column(children: [
        for (final t in store.tickets)
          ListTile(
            key: ValueKey('ticket_${t.id}'),
            selected: t.id == open.id,
            selectedTileColor: ZTheme.accentSoft,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            leading: InitialsAvatar(t.author, size: 36),
            title: Text(t.subject, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('${t.id} · ${t.author} · ${t.role}', maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: t.resolved
                ? const StatusPill('Resolvido', ZTheme.accent)
                : StatusPill(t.priority, t.priority == 'Alta' ? ZTheme.danger : (t.priority == 'Média' ? const Color(0xFFB7791F) : ZTheme.secondary)),
            onTap: () => setState(() => _openId = t.id),
          ),
      ]),
    );
    final thread = AdminCard(
      title: '${open.id} · ${open.subject}',
      trailing: AdminButton(
        open.resolved ? 'Reabrir' : 'Marcar como resolvido',
        key: const ValueKey('resolveTicket'),
        filled: !open.resolved,
        color: ZTheme.accent,
        icon: open.resolved ? CupertinoIcons.arrow_counterclockwise : CupertinoIcons.checkmark_alt,
        onTap: () => store.resolve(open),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('${open.author} · ${open.role}', style: ZText.sub),
        const SizedBox(height: 14),
        for (final m in open.messages)
          Align(
            alignment: m.fromTeam ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: m.fromTeam ? ZTheme.accent : ZTheme.fill, borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(m.text, style: TextStyle(fontSize: 15, color: m.fromTeam ? Colors.white : ZTheme.ink)),
                Text(BR.time(m.time), style: TextStyle(fontSize: 11, color: m.fromTeam ? Colors.white70 : ZTheme.secondary)),
              ]),
            ),
          ),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final q in _quick) ActionChip(label: Text(q, style: const TextStyle(fontSize: 12)), onPressed: () => _send(store, open, q)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: CupertinoTextField(
              key: const ValueKey('ticketReply'),
              controller: _reply,
              placeholder: 'Escreva uma resposta para ${open.author.split(' ').first}…',
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: ZTheme.fill, borderRadius: BorderRadius.circular(12)),
              onSubmitted: (v) => _send(store, open, v),
            ),
          ),
          const SizedBox(width: 8),
          AdminButton('Enviar', key: const ValueKey('sendReply'), icon: CupertinoIcons.paperplane_fill, onTap: () => _send(store, open, _reply.text)),
        ]),
      ]),
    );
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth > 1000;
      return ListView(padding: const EdgeInsets.all(24), children: [
        PageHeader('Suporte', subtitle: '${store.openTickets} chamados abertos · resposta média em 4 min'),
        if (wide)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 400, child: list),
            const SizedBox(width: 14),
            Expanded(child: thread),
          ])
        else ...[list, const SizedBox(height: 14), thread],
      ]);
    });
  }
}
