import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/models.dart';
import '../core/theme.dart';

/// Pulsing blue "você está aqui" dot.
class PulsingDot extends StatefulWidget {
  const PulsingDot({super.key});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Você está aqui',
      child: SizedBox.square(
        dimension: 64,
        child: Stack(alignment: Alignment.center, children: [
          AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Opacity(
              opacity: 1 - _c.value,
              child: Container(
                width: 64 * (0.3 + 0.7 * _c.value),
                height: 64 * (0.3 + 0.7 * _c.value),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x402978FF)),
              ),
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 3, offset: Offset(0, 1))],
            ),
            alignment: Alignment.center,
            child: Container(width: 15, height: 15, decoration: const BoxDecoration(color: ZTheme.youBlue, shape: BoxShape.circle)),
          ),
        ]),
      ),
    );
  }
}

/// Radar rings drawn on the pickup while the driver search runs.
class RadarPulse extends StatefulWidget {
  const RadarPulse({super.key});

  @override
  State<RadarPulse> createState() => _RadarPulseState();
}

class _RadarPulseState extends State<RadarPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2100))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Stack(alignment: Alignment.center, children: [
          for (var ring = 0; ring < 3; ring++)
            () {
              final t = (_c.value + ring / 3) % 1;
              return Opacity(
                opacity: (1 - t) * 0.9,
                child: Container(
                  width: 200 * (0.1 + 0.9 * t),
                  height: 200 * (0.1 + 0.9 * t),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ZTheme.accent.withValues(alpha: 0.7), width: 2)),
                ),
              );
            }(),
          Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, color: ZTheme.accent.withValues(alpha: 0.18))),
        ]),
      ),
    );
  }
}

/// Top-down vehicle used for traffic and for the matched driver.
class VehicleMarker extends StatelessWidget {
  const VehicleMarker({super.key, this.kind = VehicleKind.car, this.heading = 0, this.highlighted = false});

  final VehicleKind kind;
  final double heading;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final body = kind == VehicleKind.car ? _car() : _moto();
    return Transform.rotate(
      angle: heading * math.pi / 180,
      child: Transform.scale(scale: highlighted ? 1.25 : 1, child: body),
    );
  }

  Widget _car() {
    return Container(
      width: 14,
      height: 26,
      decoration: BoxDecoration(
        color: highlighted ? ZTheme.ink : ZTheme.card,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [BoxShadow(color: const Color(0x4D000000), blurRadius: highlighted ? 5 : 2, offset: const Offset(0, 1))],
      ),
      child: Column(children: [
        const SizedBox(height: 5),
        Container(width: 10, height: 6, decoration: BoxDecoration(color: highlighted ? ZTheme.accent : const Color(0xBFFFFFFF), borderRadius: BorderRadius.circular(2))),
        const Spacer(),
        Container(width: 10, height: 4, decoration: BoxDecoration(color: highlighted ? ZTheme.accent.withValues(alpha: 0.7) : const Color(0x80FFFFFF), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 4),
      ]),
    );
  }

  Widget _moto() {
    return SizedBox(
      width: 12,
      height: 22,
      child: Stack(alignment: Alignment.center, children: [
        Container(width: 6, height: 22, decoration: BoxDecoration(color: ZTheme.ink, borderRadius: BorderRadius.circular(3))),
        Container(width: 9, height: 9, decoration: const BoxDecoration(color: ZTheme.accent, shape: BoxShape.circle)),
      ]),
    );
  }
}

/// Pickup pin: white circle with a black core.
class PickupPin extends StatelessWidget {
  const PickupPin({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: ZTheme.ink,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Color(0x4D000000), blurRadius: 3, offset: Offset(0, 1))],
      ),
      alignment: Alignment.center,
      child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: ZTheme.onInk, shape: BoxShape.circle)),
    );
  }
}

/// Destination pin: white square with a black core, with the place name above.
class DestinationPin extends StatelessWidget {
  const DestinationPin({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        constraints: const BoxConstraints(maxWidth: 190),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: ZTheme.card,
          borderRadius: BorderRadius.circular(99),
          boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 4, offset: Offset(0, 1))],
        ),
        child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      ),
      const SizedBox(height: 4),
      Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(color: ZTheme.ink, borderRadius: BorderRadius.circular(3)),
        alignment: Alignment.center,
        child: Container(width: 8, height: 8, color: ZTheme.onInk),
      ),
    ]);
  }
}

/// Side-view car (or scooter) drawing used in the ride list.
class RideIllustration extends StatelessWidget {
  const RideIllustration({super.key, required this.ride});
  final RideType ride;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 44,
      child: ride.kind == VehicleKind.moto
          ? Icon(CupertinoIcons.speedometer, size: 32, color: ride.color)
          : CustomPaint(painter: _CarPainter(ride.color)),
    );
  }
}

class _CarPainter extends CustomPainter {
  _CarPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final edge = Paint()
      ..color = const Color(0x26000000)
      ..style = PaintingStyle.stroke;
    final cabin = Path()
      ..moveTo(18, 22)
      ..lineTo(24, 10)
      ..lineTo(46, 10)
      ..lineTo(55, 22)
      ..close();
    canvas.drawPath(cabin, Paint()..color = color.withValues(alpha: 0.85));
    canvas.drawPath(cabin, edge);
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(3, 20, 66, 16), const Radius.circular(8));
    canvas.drawRRect(body, Paint()..color = color);
    canvas.drawRRect(body, edge);
    for (final x in [18.0, 54.0]) {
      canvas.drawCircle(Offset(x, 36), 7, Paint()..color = const Color(0xFF111111));
      canvas.drawCircle(Offset(x, 36), 3, Paint()..color = const Color(0xFFBBBBBB));
    }
  }

  @override
  bool shouldRepaint(covariant _CarPainter oldDelegate) => oldDelegate.color != color;
}
