import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';

/// Press feedback used on every tappable surface: a quick spring scale and dim.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.onTap, required this.child, this.scale = 0.97, this.haptic = true, this.semanticLabel});

  final VoidCallback? onTap;
  final Widget child;
  final double scale;
  final bool haptic;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool value) {
    if (_down != value) setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapCancel: () => _set(false),
        onTapUp: (_) => _set(false),
        onTap: enabled
            ? () {
                if (widget.haptic) HapticFeedback.selectionClick();
                widget.onTap!();
              }
            : null,
        child: AnimatedScale(
          scale: _down ? widget.scale : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: _down ? 0.85 : 1,
            duration: const Duration(milliseconds: 120),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Big black call to action.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, {super.key, required this.onTap, this.color = ZTheme.ink});

  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.45 : 1,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

/// Grey secondary action.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton(this.label, {super.key, required this.onTap, this.color = ZTheme.ink});

  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: ZTheme.fill2, borderRadius: BorderRadius.circular(14)),
        child: Text(label, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

/// The floating white panel used for every bottom card on the map.
class MapPanel extends StatelessWidget {
  const MapPanel({super.key, required this.child, this.padding = const EdgeInsets.fromLTRB(18, 10, 18, 18)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: padding,
      decoration: BoxDecoration(
        color: ZTheme.surface,
        borderRadius: BorderRadius.circular(ZTheme.sheetRadius),
        boxShadow: const [BoxShadow(color: Color(0x24000000), blurRadius: 30, offset: Offset(0, 6))],
      ),
      child: child,
    );
  }
}

class Grabber extends StatelessWidget {
  const Grabber({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(width: 36, height: 5, decoration: BoxDecoration(color: ZTheme.tertiary, borderRadius: BorderRadius.circular(3))),
    );
  }
}

/// Network image with a soft placeholder (initials on a tinted circle) so nothing is ever blank.
class RemoteAvatar extends StatelessWidget {
  const RemoteAvatar({super.key, required this.url, required this.initials, this.size = 56});

  final String url;
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: ZTheme.accentSoft,
      alignment: Alignment.center,
      child: Text(initials, style: TextStyle(fontSize: size * 0.36, fontWeight: FontWeight.w700, color: ZTheme.accent)),
    );
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(2),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, sync) => frame == null && !sync
              ? placeholder
              : AnimatedOpacity(opacity: 1, duration: const Duration(milliseconds: 250), child: child),
          errorBuilder: (context, error, stack) => placeholder,
        ),
      ),
    );
  }
}

/// Small uppercase label above a group.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(), style: ZText.section);
}

/// Round white button floating on the map.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({super.key, required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.9,
      semanticLabel: label,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Color(0x26000000), blurRadius: 10, offset: Offset(0, 2))],
        ),
        child: Icon(icon, size: 20, color: ZTheme.ink),
      ),
    );
  }
}

/// iOS-style alert built in Flutter so it looks the same on Android.
Future<void> showNotice(BuildContext context, String title, String message) {
  return showDialog<void>(
    context: context,
    barrierColor: const Color(0x40000000),
    builder: (context) => _AppleAlert(title: title, message: message, actions: [
      _AlertAction('OK', bold: true, onTap: () => Navigator.of(context).pop()),
    ]),
  );
}

/// iOS-style two-button confirmation. Returns true when the destructive action is chosen.
Future<bool> showConfirm(BuildContext context, {required String title, required String message, required String cancel, required String confirm}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0x40000000),
    builder: (context) => _AppleAlert(title: title, message: message, actions: [
      _AlertAction(cancel, onTap: () => Navigator.of(context).pop(false)),
      _AlertAction(confirm, bold: true, color: ZTheme.danger, onTap: () => Navigator.of(context).pop(true)),
    ]),
  );
  return result ?? false;
}

class _AlertAction {
  const _AlertAction(this.label, {required this.onTap, this.bold = false, this.color = ZTheme.youBlue});
  final String label;
  final VoidCallback onTap;
  final bool bold;
  final Color color;
}

class _AppleAlert extends StatelessWidget {
  const _AppleAlert({required this.title, required this.message, required this.actions});

  final String title;
  final String message;
  final List<_AlertAction> actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: const Color(0xF7FAFAFA),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
                child: Column(children: [
                  Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, height: 1.35)),
                ]),
              ),
              const Divider(),
              IntrinsicHeight(
                child: Row(
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const VerticalDivider(width: 1, thickness: 1, color: ZTheme.hairline),
                      Expanded(
                        child: InkWell(
                          onTap: actions[i].onTap,
                          child: SizedBox(
                            height: 46,
                            child: Center(
                              child: Text(
                                actions[i].label,
                                style: TextStyle(fontSize: 17, color: actions[i].color, fontWeight: actions[i].bold ? FontWeight.w600 : FontWeight.w400),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet with the iOS look: rounded top, grabber, white.
Future<T?> showZSheet<T>(BuildContext context, WidgetBuilder builder, {bool expand = false}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    barrierColor: const Color(0x52000000),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(ZTheme.sheetRadius))),
    builder: (context) => expand
        ? FractionallySizedBox(heightFactor: 0.92, child: builder(context))
        : Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), child: builder(context)),
  );
}
