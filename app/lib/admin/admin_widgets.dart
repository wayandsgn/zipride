import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'admin_data.dart';

/// White card with a hairline border, the base of every admin block.
class AdminCard extends StatelessWidget {
  const AdminCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.title, this.trailing});

  final Widget child;
  final EdgeInsets padding;
  final String? title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    // A Material (not a decorated box) so list tiles inside can paint their highlight.
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: ZTheme.hairline)),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 0),
            child: Row(children: [
              Expanded(child: Text(title!, style: ZText.headline)),
              ?trailing,
            ]),
          ),
        Padding(padding: padding, child: child),
      ]),
    );
  }
}

class KpiCard extends StatelessWidget {
  const KpiCard({super.key, required this.label, required this.value, required this.icon, this.note, this.color = ZTheme.accent});

  final String label;
  final String value;
  final IconData icon;
  final String? note;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: ZText.foot, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(value, key: ValueKey(value), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5, fontFeatures: ZText.tabular)),
        ),
        if (note != null) Text(note!, style: const TextStyle(fontSize: 12, color: ZTheme.accent, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.text, this.color, {super.key});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: ShapeDecoration(color: color.withValues(alpha: 0.12), shape: const StadiumBorder()),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

Color rideColor(RideStatus s) => switch (s) {
      RideStatus.live => ZTheme.youBlue,
      RideStatus.done => ZTheme.accent,
      RideStatus.cancelled => ZTheme.secondary,
      RideStatus.refunded => const Color(0xFFB7791F),
    };

Color driverColor(DriverStatus s) => switch (s) {
      DriverStatus.online => ZTheme.accent,
      DriverStatus.onTrip => ZTheme.youBlue,
      DriverStatus.offline => ZTheme.secondary,
      DriverStatus.review => const Color(0xFFB7791F),
      DriverStatus.blocked => ZTheme.danger,
    };

/// Page title with optional actions on the right.
class PageHeader extends StatelessWidget {
  const PageHeader(this.title, {super.key, this.subtitle, this.actions = const []});
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.end, runSpacing: 10, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
          if (subtitle != null) Text(subtitle!, style: ZText.sub),
        ]),
        Wrap(spacing: 8, children: actions),
      ]),
    );
  }
}

/// Simple table: a header row and tappable rows that scroll sideways on narrow screens.
class AdminTable extends StatelessWidget {
  const AdminTable({super.key, required this.columns, required this.rows, this.onTap, this.minWidth = 820, this.rowKeys});

  final List<(String, int)> columns;
  final List<List<Widget>> rows;
  final void Function(int index)? onTap;
  final double minWidth;
  final List<Key>? rowKeys;

  @override
  Widget build(BuildContext context) {
    Widget line(List<Widget> cells, {bool header = false}) => Row(children: [
          for (var i = 0; i < cells.length; i++)
            Expanded(
              flex: columns[i].$2,
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: cells[i]),
            ),
        ]);
    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth < minWidth ? minWidth : c.maxWidth;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: width,
          child: Column(children: [
            Container(
              color: ZTheme.fill,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: line([for (final c in columns) Text(c.$1.toUpperCase(), style: ZText.section)], header: true),
            ),
            for (var r = 0; r < rows.length; r++) ...[
              if (r > 0) const Divider(),
              _HoverRow(key: rowKeys?[r], onTap: onTap == null ? null : () => onTap!(r), child: line(rows[r])),
            ],
          ]),
        ),
      );
    });
  }
}

class _HoverRow extends StatefulWidget {
  const _HoverRow({super.key, required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<_HoverRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          color: _hover && widget.onTap != null ? const Color(0xFFF7F7FA) : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Small pill-shaped filter used above tables.
class FilterChipZ extends StatelessWidget {
  const FilterChipZ(this.label, {super.key, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: selected ? ZTheme.ink : Colors.white, borderRadius: BorderRadius.circular(99), border: Border.all(color: selected ? ZTheme.ink : ZTheme.hairline)),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : ZTheme.ink)),
      ),
    );
  }
}

/// Compact black or outlined button for desktop pages.
class AdminButton extends StatelessWidget {
  const AdminButton(this.label, {super.key, required this.onTap, this.icon, this.filled = true, this.color = ZTheme.ink});
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : color;
    return Material(
      color: filled ? color : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: filled ? BorderSide.none : const BorderSide(color: ZTheme.hairline)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 16, color: fg), const SizedBox(width: 6)],
            Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 14)),
          ]),
        ),
      ),
    );
  }
}
