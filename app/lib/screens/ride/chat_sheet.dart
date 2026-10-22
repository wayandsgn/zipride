import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/fixtures.dart';
import '../../core/formatters.dart';
import '../../core/models.dart';
import '../../core/ride_store.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

/// Chat with the driver: quick replies, free text, typing indicator and canned answers.
class ChatSheet extends StatefulWidget {
  const ChatSheet({super.key});

  @override
  State<ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<ChatSheet> {
  final _draft = TextEditingController();
  final _scroll = ScrollController();
  int _count = 0;

  @override
  void dispose() {
    _draft.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text) {
    StoreScope.read(context).send(text);
    _draft.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    if (store.chat.length != _count) {
      _count = store.chat.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
        }
      });
    }
    return Column(children: [
      const SizedBox(height: 10),
      const Grabber(),
      SizedBox(
        height: 50,
        child: Row(children: [
          const SizedBox(width: 70),
          Expanded(child: Text(Fixtures.driver.name, textAlign: TextAlign.center, style: ZText.headline)),
          SizedBox(
            width: 70,
            child: Pressable(
              key: const ValueKey('chatClose'),
              onTap: () => Navigator.of(context).pop(),
              child: const Text('Fechar', style: TextStyle(color: ZTheme.accent, fontSize: 17, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
      const Divider(),
      Expanded(
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text('Mensagens ficam salvas só durante a corrida.', textAlign: TextAlign.center, style: ZText.caption),
            ),
            for (final m in store.chat) _Bubble(message: m),
            if (store.driverTyping) const _Typing(),
          ],
        ),
      ),
      SizedBox(
        height: 52,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          itemCount: Fixtures.quickReplies.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, i) => Pressable(
            key: ValueKey('quickReply_$i'),
            onTap: () => _send(Fixtures.quickReplies[i]),
            scale: 0.95,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(border: Border.all(color: ZTheme.hairline), borderRadius: BorderRadius.circular(99)),
              child: Text(Fixtures.quickReplies[i], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(14, 0, 14, 12 + MediaQuery.of(context).viewInsets.bottom),
        child: Row(children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(color: ZTheme.fill2, borderRadius: BorderRadius.circular(22)),
              child: TextField(
                key: const ValueKey('chatField'),
                controller: _draft,
                cursorColor: ZTheme.accent,
                textInputAction: TextInputAction.send,
                onChanged: (_) => setState(() {}),
                onSubmitted: _send,
                decoration: const InputDecoration.collapsed(hintText: 'Escreva uma mensagem', hintStyle: TextStyle(color: ZTheme.secondary)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Pressable(
            onTap: _draft.text.trim().isEmpty ? null : () => _send(_draft.text),
            scale: 0.9,
            semanticLabel: 'Enviar',
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: _draft.text.trim().isEmpty ? ZTheme.tertiary : ZTheme.ink, shape: BoxShape.circle),
              child: const Icon(CupertinoIcons.arrow_up, color: ZTheme.onInk, size: 19),
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = !message.fromDriver;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child)),
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.74),
          padding: const EdgeInsets.fromLTRB(14, 9, 14, 7),
          decoration: BoxDecoration(color: mine ? ZTheme.ink : ZTheme.fill2, borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
            Text(message.text, style: TextStyle(fontSize: 16, height: 1.3, color: mine ? ZTheme.onInk : ZTheme.ink)),
            const SizedBox(height: 2),
            Text(BR.time(message.time), style: TextStyle(fontSize: 11, color: mine ? Colors.black54 : ZTheme.secondary)),
          ]),
        ),
      ),
    );
  }
}

class _Typing extends StatefulWidget {
  const _Typing();

  @override
  State<_Typing> createState() => _TypingState();
}

class _TypingState extends State<_Typing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${Fixtures.driver.name} está digitando',
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(color: ZTheme.fill2, borderRadius: BorderRadius.circular(18)),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Row(mainAxisSize: MainAxisSize.min, children: [
              for (var i = 0; i < 3; i++)
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ZTheme.secondary.withValues(alpha: 0.3 + 0.7 * (((_c.value * 3 - i) % 3) < 1 ? 1 : 0)),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
