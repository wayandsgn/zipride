import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Original Zipride mark: a "Z" drawn as a route with a pickup dot at its start
/// and a destination square at its end, set in a rounded black tile.
class ZiprideMark extends StatelessWidget {
  const ZiprideMark({super.key, this.size = 32});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(dimension: size, child: CustomPaint(painter: _MarkPainter()));
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(s * 0.28)), Paint()..color = Colors.black);
    final inset = s * 0.24, w = s - inset * 2;
    Offset p(double x, double y) => Offset(inset + w * x, inset + w * y);
    final path = Path()
      ..moveTo(p(0.02, 0.05).dx, p(0.02, 0.05).dy)
      ..lineTo(p(0.95, 0.05).dx, p(0.95, 0.05).dy)
      ..quadraticBezierTo(p(0.55, 0.45).dx, p(0.55, 0.45).dy, p(0.05, 0.95).dx, p(0.05, 0.95).dy)
      ..lineTo(p(0.98, 0.95).dx, p(0.98, 0.95).dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = ZTheme.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.12
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(Offset(s * 0.25, s * 0.27), s * 0.085, Paint()..color = Colors.white);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(s * 0.75, s * 0.73), width: s * 0.15, height: s * 0.15), Radius.circular(s * 0.03)),
      Paint()..color = ZTheme.sun,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Mark plus wordmark, used in headers.
class ZiprideWordmark extends StatelessWidget {
  const ZiprideWordmark({super.key, this.size = 28});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Zipride',
      excludeSemantics: true,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        ZiprideMark(size: size),
        const SizedBox(width: 8),
        Text('zipride', style: TextStyle(fontSize: size * 0.78, fontWeight: FontWeight.w900, letterSpacing: -0.6, color: Colors.black)),
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
              child: Text(text, style: const TextStyle(fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ),
          ),
        ]),
      ),
    );
  }
}
