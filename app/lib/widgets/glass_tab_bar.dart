import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'common.dart';

/// Floating frosted tab bar in the iOS 26 style, shared by the customer and driver apps.
class GlassTabBar extends StatelessWidget {
  const GlassTabBar({super.key, required this.items, required this.selected, required this.onSelect});

  final List<(String, IconData)> items;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(31),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 62,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(31),
            border: Border.all(color: ZTheme.hairline),
          ),
          child: Row(children: [
            for (final (i, (label, icon)) in items.indexed)
              Expanded(
                child: Pressable(
                  onTap: () => onSelect(i),
                  haptic: false,
                  scale: 0.92,
                  semanticLabel: label,
                  child: AnimatedContainer(
                    key: ValueKey('tab_$label'),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: selected == i ? ZTheme.accentSoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(27),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(icon, size: 22, color: selected == i ? ZTheme.accent : const Color(0xFF555555)),
                      const SizedBox(height: 2),
                      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: selected == i ? ZTheme.accent : const Color(0xFF555555))),
                    ]),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
