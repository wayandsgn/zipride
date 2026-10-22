import 'package:flutter/material.dart';

import '../core/formatters.dart';

/// Draws an iPhone-sized device around an app so it can be used with the mouse in a browser.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.label, required this.child});

  static const screen = Size(390, 844);
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final outer = MediaQuery.of(context);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFB0B0B5))),
      const SizedBox(height: 10),
      Flexible(
        child: FittedBox(
          child: Container(
            width: screen.width + 24,
            height: screen.height + 24,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2D),
              borderRadius: BorderRadius.circular(60),
              boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 40, offset: Offset(0, 18))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: MediaQuery(
                data: outer.copyWith(
                  size: screen,
                  padding: const EdgeInsets.only(top: 54, bottom: 30),
                  viewPadding: const EdgeInsets.only(top: 54, bottom: 30),
                  viewInsets: EdgeInsets.zero,
                ),
                child: Stack(children: [
                  Positioned.fill(child: child),
                  const Positioned(top: 0, left: 0, right: 0, child: IgnorePointer(child: _StatusBar())),
                ]),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Stack(children: [
        Positioned(
          left: 34,
          top: 18,
          child: StreamBuilder<int>(
            stream: Stream.periodic(const Duration(seconds: 20), (i) => i),
            builder: (context, _) => Text(BR.time(DateTime.now()), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
        Align(
          alignment: const Alignment(0, -0.1),
          child: Container(width: 120, height: 34, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20))),
        ),
        const Positioned(
          right: 30,
          top: 19,
          child: Row(children: [
            Icon(Icons.signal_cellular_alt, size: 17),
            SizedBox(width: 4),
            Icon(Icons.wifi, size: 17),
            SizedBox(width: 4),
            Icon(Icons.battery_full, size: 19),
          ]),
        ),
      ]),
    );
  }
}
