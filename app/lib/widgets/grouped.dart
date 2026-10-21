import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../screens/root.dart';
import 'common.dart';

/// A tab page with an iOS large title that collapses into the bar as you scroll.
class LargeTitlePage extends StatelessWidget {
  const LargeTitlePage({super.key, required this.title, required this.children, this.background = ZTheme.surface, this.bottomPadding = tabBarClearance});

  final String title;
  final List<Widget> children;
  final Color background;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: background,
      child: CustomScrollView(slivers: [
        CupertinoSliverNavigationBar(
          largeTitle: Text(title, style: const TextStyle(fontFamily: ZTheme.font, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
          backgroundColor: background.withValues(alpha: 0.92),
          border: null,
          // All tabs live in one route, so their bars must not share a hero.
          transitionBetweenRoutes: false,
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, bottomPadding),
          sliver: SliverList.list(children: children),
        ),
      ]),
    );
  }
}

/// A pushed page with a small centred title and an iOS back chevron.
class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.title, required this.children, this.background = ZTheme.fill});

  final String title;
  final List<Widget> children;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        title: Text(title),
        leading: Pressable(
          key: const ValueKey('back'),
          onTap: () => Navigator.of(context).pop(),
          semanticLabel: 'Voltar',
          child: const Icon(CupertinoIcons.chevron_back, color: ZTheme.youBlue, size: 26),
        ),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: children),
    );
  }
}

/// iOS inset-grouped section: optional header, white rounded card, hairlines between rows.
class GroupSection extends StatelessWidget {
  const GroupSection({super.key, this.header, required this.children});

  final String? header;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (header != null) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 7), child: SectionLabel(header!)),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: ColoredBox(
            color: Colors.white,
            child: Column(children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Padding(padding: EdgeInsets.only(left: 16), child: Divider()),
                children[i],
              ],
            ]),
          ),
        ),
      ]),
    );
  }
}

/// Row with a tinted icon, title, subtitle and an optional chevron.
class NavRow extends StatelessWidget {
  const NavRow({super.key, required this.icon, required this.title, this.subtitle, required this.onTap, this.chevron = true});

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.99,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: ZTheme.accentSoft, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: ZTheme.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ZText.bodyStrong),
              if (subtitle != null) Text(subtitle!, style: ZText.foot),
            ]),
          ),
          if (chevron) const Icon(CupertinoIcons.chevron_forward, size: 17, color: ZTheme.tertiary),
        ]),
      ),
    );
  }
}

/// "Label ........ value" row.
class ValueRow extends StatelessWidget {
  const ValueRow(this.title, this.value, {super.key, this.bold = false});

  final String title;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final weight = bold ? FontWeight.w700 : FontWeight.w400;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: weight, color: bold ? ZTheme.ink : ZTheme.secondary)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: 16, fontWeight: weight, fontFeatures: ZText.tabular)),
        ),
      ]),
    );
  }
}

/// Plain centred text action, e.g. "Sair da conta".
class TextActionRow extends StatelessWidget {
  const TextActionRow(this.label, {super.key, required this.onTap, this.color = ZTheme.youBlue});

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.99,
      child: SizedBox(
        height: 50,
        child: Center(child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color))),
      ),
    );
  }
}

/// iOS-style switch row.
class SwitchRow extends StatelessWidget {
  const SwitchRow(this.title, {super.key, required this.value, required this.onChanged});

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
      child: Row(children: [
        Expanded(child: Text(title, style: ZText.body)),
        CupertinoSwitch(value: value, activeTrackColor: ZTheme.accent, onChanged: onChanged),
      ]),
    );
  }
}
