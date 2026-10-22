import 'package:flutter/material.dart';

import '../core/theme.dart';

/// ITAX mark: an "X" drawn as two crossing routes on a green tile, with a white
/// pickup dot at one end and a destination square at the other.
class ItaxMark extends StatelessWidget {
  const ItaxMark({super.key, this.size = 32});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(dimension: size, child: CustomPaint(painter: _MarkPainter()));
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(s * 0.28)), Paint()..color = ZTheme.accent);
    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.13
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(s * 0.27, s * 0.27), Offset(s * 0.73, s * 0.73), stroke);
    canvas.drawLine(Offset(s * 0.73, s * 0.27), Offset(s * 0.27, s * 0.73), stroke);
    canvas.drawCircle(Offset(s * 0.27, s * 0.27), s * 0.1, Paint()..color = Colors.white);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(s * 0.73, s * 0.73), width: s * 0.17, height: s * 0.17), Radius.circular(s * 0.03)),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Mark plus wordmark, used in headers.
class ItaxWordmark extends StatelessWidget {
  const ItaxWordmark({super.key, this.size = 28});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'ITAX',
      excludeSemantics: true,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        ItaxMark(size: size),
        const SizedBox(width: 8),
        Text('ITAX', style: TextStyle(fontSize: size * 0.8, fontWeight: FontWeight.w900, letterSpacing: 0.4, color: ZTheme.ink)),
      ]),
    );
  }
}

/// Brazilian Mercosul plate: blue band with "BRASIL" above the characters.
class MercosulPlate extends StatelessWidget {
  const MercosulPlate(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Placa $text',
      excludeSemantics: true,
      child: Container(
        width: 92,
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 1.2), borderRadius: BorderRadius.circular(4)),
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            height: 11,
            color: const Color(0xFF003399),
            alignment: Alignment.center,
            child: const Text('BRASIL', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
          SizedBox(
            height: 24,
            child: Center(
              child: Text(text, style: const TextStyle(fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: Colors.black)),
            ),
          ),
        ]),
      ),
    );
  }
}
